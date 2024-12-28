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
    
    static let userDefaultsKey = "TemperatureUnit"
        
    static func loadFromDefaults() -> TemperatureUnit {
        if let savedValue = UserDefaults.standard.string(forKey: userDefaultsKey),
           let unit = TemperatureUnit(rawValue: savedValue) {
            return unit
        }
        return .metric // Default value
    }
    
    func saveToDefaults() {
        UserDefaults.standard.set(self.rawValue, forKey: TemperatureUnit.userDefaultsKey)
    }
}
