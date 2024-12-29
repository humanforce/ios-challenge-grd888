//
//  TemperatureUnit.swift
//  Humanforce iOS Engineering Challenge
//
//  Created by Greg Delgado on 12/26/24.
//

import Foundation

enum TemperatureUnit: String, CaseIterable {
    case metric
    case imperial
    case standard
    
    var displayName: String {
        switch self {
        case .metric: return "Celsius"
        case .imperial: return "Fahrenheit"
        case .standard: return "Kelvin"
        }
    }
    
    var symbol: String {
        switch self {
        case .metric: return "°C"
        case .imperial: return "°F"
        case .standard: return "K"
        }
    }
    
    static func loadFromDefaults() -> TemperatureUnit {
        if let savedValue = UserDefaults.shared.string(forKey: UserDefaults.Keys.temperatureUnit),
           let unit = TemperatureUnit(rawValue: savedValue) {
            return unit
        }
        return .metric // Default value
    }
    
    func saveToDefaults() {
        UserDefaults.shared.set(self.rawValue, forKey: UserDefaults.Keys.temperatureUnit)
    }
}
