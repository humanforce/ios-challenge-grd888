//
//  UserDefaults+Extensions.swift
//  Humanforce iOS Engineering Challenge
//
//  Created by Greg Delgado on 12/29/24.
//

import Foundation

extension UserDefaults {
    static var shared: UserDefaults {
        return UserDefaults(suiteName: "group.org.gdelgado.weatherwidget")!
    }
    
    enum Keys {
        static let currentLocation = "currentLocation"
        static let currentWeather = "currentWeather"
        static let temperatureUnit = "temperatureUnit"
    }
}
