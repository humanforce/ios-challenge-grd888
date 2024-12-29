//
//  NetworkError.swift
//  Humanforce iOS Engineering Challenge
//
//  Created by Greg Delgado on 12/25/24.
//

import Foundation

enum NetworkError: Error, LocalizedError {
    case badURL
    case decodingError
    case unknown
    case unauthorized
    case notFound
    case serverError

    var errorDescription: String? {
        switch self {
        case .badURL:
            return "The URL provided was invalid. Please try again."
        case .decodingError:
            return "We encountered an issue while processing the data. Please try again later."
        case .unknown:
            return "An unknown error occurred. Please try again."
        case .unauthorized:
            return "You are not authorized to perform this action. Please check your credentials."
        case .notFound:
            return "The requested resource could not be found. Please try a different search."
        case .serverError:
            return "The server encountered an error. Please try again later."
        }
    }
}
