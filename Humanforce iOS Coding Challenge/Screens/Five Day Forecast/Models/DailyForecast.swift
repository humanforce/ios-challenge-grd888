//
//  DailyForecast.swift
//  Humanforce iOS Engineering Challenge
//
//  Created by Greg Delgado on 12/25/24.
//

import Foundation

struct DailyForecast: Identifiable {
    let id = UUID()
    let date: String
    let minTemp: Double
    let maxTemp: Double
}
