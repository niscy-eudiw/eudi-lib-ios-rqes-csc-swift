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
import XCTest
@testable import RQES_LIBRARY

final class InfoServiceTests: XCTestCase {

    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }

    func testInvokeInfoService() async throws {
        let request = InfoServiceRequest(lang: "en-US")

        do {
            let rqes = await RQES()
            let response = try await rqes.getInfo(request: request)

            JSONUtils.prettyPrintResponseAsJSON(response)
        } catch {
            if let localizedError = error as? LocalizedError {
                print("Error: \(localizedError.errorDescription ?? "Unknown error")")
            } else {
                XCTFail("Unexpected error type: \(error)")
            }
            //XCTAssertEqual(error as? InfoServiceError, InfoServiceError.invalidLanguage)
        }
    }
    func prettyPrintResponseAsJSON(_ response: InfoServiceResponse) {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted

        do {
            let jsonData = try encoder.encode(response)
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                print("Pretty Printed JSON Response:")
                print(jsonString)
            }
        } catch {
            print("Failed to encode InfoServiceResponse to JSON: \(error)")
        }
    }
}