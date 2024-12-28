//
//  Location.swift
//  Humanforce iOS Engineering Challenge
//
//  Created by Greg Delgado on 12/25/24.
//

import Foundation

struct Location: Codable, Identifiable, Equatable {
    let name: String
    let lat, lon: Double
    let country, state: String?
    
    var id: String {
        "\(lat)-\(lon)"
    }
}

typealias SearchResults = [Location]

extension Location {
    static var mock: Location {
        .init(name: "Mock Location in the Philippines", lat: 40.7127, lon: -73.998, country: "United States", state: "New York")
    }
    
    var stateCountry: String? {
        var output: String? = nil
        if let state {
            output = state
        }
        if let out = output, let country {
            output = out + ", \(country)"
        } else {
            output = country
        }
        return output
    }
}

extension Location {
    static let userDefaultsKey = "CurrentLocation"
    
    func saveToDefaults() {
        if let data = try? JSONEncoder().encode(self) {
            UserDefaults.standard.set(data, forKey: Location.userDefaultsKey)
        }
    }
    
    static func loadFromDefaults() -> Location? {
        if let data = UserDefaults.standard.data(forKey: userDefaultsKey),
           let location = try? JSONDecoder().decode(Location.self, from: data) {
            return location
        }
        return nil
    }
}
