//
//  FiveDayForecast.swift
//  Humanforce iOS Engineering Challenge
//
//  Created by Greg Delgado on 12/25/24.
//

import Foundation

struct FiveDayForecast: Codable {
    let list: [Forecast]
    let city: City
    
    struct City: Codable {
        let name: String
        let coord: Coord
        let country: String
        let timezone, sunrise, sunset: Int
    }
}
