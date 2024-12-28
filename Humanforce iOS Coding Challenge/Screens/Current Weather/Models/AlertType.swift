//
//  AlertType.swift
//  Humanforce iOS Engineering Challenge
//
//  Created by Greg Delgado on 12/28/24.
//

import Foundation

enum AlertType: Identifiable {
    case error(String)
    case authorization(String)

    var id: String {
        switch self {
        case .error(let message): return "error_\(message)"
        case .authorization(let message): return "authorization_\(message)"
        }
    }

    var message: String {
        switch self {
        case .error(let message): return message
        case .authorization(let message): return message
        }
    }
}
