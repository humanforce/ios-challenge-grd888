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

extension FiveDayForecast {
    func aggregatedForecasts() -> [DailyForecast] {
        let timezoneOffset = city.timezone
        let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.timeZone = TimeZone(secondsFromGMT: timezoneOffset)
        var dailyTemps: [String: (min: Double, max: Double)] = [:]
        for record in list {
            let adjustedDate = Date(timeIntervalSince1970: TimeInterval(record.dt + timezoneOffset))
            let dayString = dateFormatter.string(from: adjustedDate)
            
            if let currentTemps = dailyTemps[dayString] {
                dailyTemps[dayString] = (
                    min: min(currentTemps.min, record.main.tempMin),
                    max: max(currentTemps.max, record.main.tempMax)
                )
            } else {
                dailyTemps[dayString] = (min: record.main.tempMin, max: record.main.tempMax)
            }
        }
        
        let dailyForecasts = dailyTemps.map { date, temps in
            DailyForecast(date: date, minTemp: temps.min, maxTemp: temps.max)
        }
        return dailyForecasts.sorted { $0.date < $1.date }
    }
}
