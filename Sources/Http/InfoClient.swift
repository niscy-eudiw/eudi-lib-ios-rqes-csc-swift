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

final actor InfoClient{
    static func makeRequest(for request: InfoServiceRequest, rsspUrl: String) async throws -> Result<InfoServiceResponse, ClientError> {
        let url = try rsspUrl.appendingEndpoint("/info").get()

        let urlRequest = try createUrlRequest(with: url, request: request)

        let (data, response) = try await URLSession.shared.data(for: urlRequest)
 
        guard let httpResponse = response as? HTTPURLResponse else {
            throw ClientError.invalidResponse
        }
        return handleResponse(data, response, ofType: InfoServiceResponse.self)
        
    }
    

    private static func createUrlRequest(with url: URL, request: InfoServiceRequest) throws -> URLRequest {
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let jsonData = try JSONEncoder().encode(request)
        urlRequest.httpBody = jsonData
        
        return urlRequest
    }
}
