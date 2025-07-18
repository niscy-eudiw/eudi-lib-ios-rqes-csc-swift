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

final actor InfoService: InfoServiceType {
    
    init() {}

    func getInfo(request: InfoServiceRequest? = nil, rsspUrl: String) async throws -> InfoServiceResponse {
        
        let req = request ?? InfoServiceRequest(lang: "en-US")

        guard let lang = req.lang else {
            throw InfoServiceError.invalidLanguage
        }

        return try await InfoClient.makeRequest(for: req, rsspUrl: rsspUrl).get()
    }

    
}
