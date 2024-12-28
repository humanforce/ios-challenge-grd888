//
//  Weather.swift
//  Humanforce iOS Engineering Challenge
//
//  Created by Greg Delgado on 12/25/24.
//

import Foundation

struct Weather: Codable {
    let id: Int
    let main, description, icon: String
}
