//
//  HTTPClient.swift
//  Humanforce iOS Engineering Challenge
//
//  Created by Greg Delgado on 12/25/24.
//

import Foundation
import Combine

protocol HTTPClient {
    func request<T: Decodable>(
        endpoint: String,
        method: HTTPMethod,
        queryParameters: [String: String],
        body: Data?,
        responseType: T.Type
    ) -> AnyPublisher<T, Error>
}
