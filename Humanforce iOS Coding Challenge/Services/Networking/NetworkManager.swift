//
//  NetworkManager.swift
//  Humanforce iOS Engineering Challenge
//
//  Created by Greg Delgado on 12/25/24.
//

import Foundation
import Combine

final class NetworkManager: HTTPClient {
    static let shared = NetworkManager()
    
    private let session: URLSession
        
    // Public initializer for testing purposes
    init(session: URLSession = .shared) {
        self.session = session
    }
    
    func request<T: Decodable>(
        endpoint: String,
        method: HTTPMethod = .GET,
        queryParameters: [String: String] = [:],
        body: Data? = nil,
        responseType: T.Type
    ) -> AnyPublisher<T, Error> {
        guard var components = URLComponents(string: endpoint) else {
            return Fail(error: NetworkError.badURL).eraseToAnyPublisher()
        }
        
        if method == .GET {
            components.queryItems = queryParameters.asQueryItems()
        }
        
        guard let url = components.url else {
            return Fail(error: NetworkError.badURL).eraseToAnyPublisher()
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        if let body = body, method != .GET {
            request.httpBody = body
        }
        return session.dataTaskPublisher(for: request)
            .tryMap { result in
                guard let httpResponse = result.response as? HTTPURLResponse else {
                    throw NetworkError.unknown
                }
                
                switch httpResponse.statusCode {
                case 200...299:
                    return result.data
                case 401:
                    throw NetworkError.unauthorized
                case 404:
                    throw NetworkError.notFound
                case 500...599:
                    throw NetworkError.serverError
                default:
                    throw NetworkError.unknown
                }
            }
            .decode(type: T.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
}
