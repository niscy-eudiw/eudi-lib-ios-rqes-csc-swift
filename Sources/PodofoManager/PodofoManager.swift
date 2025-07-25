/*
 * Copyright (c) 2023 European Commission
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
import Foundation
import PoDoFo

public actor PodofoManager {
    
    private var podofoSessions: [PodofoSession] = []
    
    public init() {}
    
    public func calculateDocumentHashes(request: CalculateHashRequest, tsaUrl: String) async throws -> DocumentDigests {
        podofoSessions.removeAll()
        var hashes: [String] = []
        var c = 1
        
        try validateTsaUrlRequirement(
            for: request.documents,
            tsaUrl: tsaUrl
        )
        
        for doc in request.documents {
            
            do {
                let podofoWrapper = try PodofoWrapper(
                    conformanceLevel: doc.conformanceLevel.rawValue,
                    hashAlgorithm:    request.hashAlgorithmOID.rawValue,
                    inputPath:        doc.documentInputPath,
                    outputPath:       doc.documentOutputPath,
                    certificate:      request.endEntityCertificate,
                    chainCertificates: request.certificateChain
                )
                let session = PodofoSession(id: "\(c)", session: podofoWrapper)
                c += 1
                let hashOptional = podofoWrapper.calculateHash()
                if let hash = hashOptional {
                    hashes.append(hash)
                    podofoSessions.append(session)
                } else {
                    throw CalculateHashError.hashCalculationError(documentPath: doc.documentInputPath)
                }
            } catch {
                print("Failed to calculate hash for \(doc.documentInputPath): \(error)")
            }
        }
        
        let documentDigest = DocumentDigests(
            hashes: hashes
        )
        return documentDigest
    }

    public func createSignedDocuments(signatures: [String], tsaUrl: String) async throws {
        defer { podofoSessions.removeAll() }
        
        guard signatures.count == podofoSessions.count else {
            throw SigningError.mismatch(
                countSessions: podofoSessions.count,
                countSignatures: signatures.count
            )
        }
        
        let tsService = TimestampService()

        for i in 0..<podofoSessions.count {
            let sessionWrapper = podofoSessions[i]
            let signedHash     = signatures[i]
            sessionWrapper.session.printState()
            
            
            if tsaUrl != "" {
                let tsRequest = TimestampRequest(
                    signedHash: signedHash,
                    tsaUrl: tsaUrl
                )
                let tsResponse = try await tsService.requestTimestamp(request: tsRequest)

                sessionWrapper.session.finalizeSigning(withSignedHash: signedHash, tsr: tsResponse.base64Tsr)
                
            } else {
                sessionWrapper.session.finalizeSigning(withSignedHash: signedHash, tsr: "")
            }
            

        }
    }
    
    private func validateTsaUrlRequirement(for docs: [CalculateHashRequest.Document], tsaUrl: String
    ) throws {
        for doc in docs {
            if doc.conformanceLevel != .ADES_B_B && tsaUrl.isEmpty {
                throw CalculateHashError.missingTsaURL(conformanceLevel: doc.conformanceLevel.rawValue )
            }
        }
    }
}
