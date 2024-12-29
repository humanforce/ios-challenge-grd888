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
    /// Aggregates the daily weather forecasts by calculating the minimum and maximum temperatures for each day.
    ///
    /// The function adjusts the UTC timestamps of the forecast records using the `timezone` offset from the `city` property.
    /// It then groups the records by their local date and computes the daily minimum and maximum temperatures.
    ///
    /// - Returns: A sorted array of `DailyForecast` objects, where each object represents the aggregated forecast for a single day.
    ///            The `date` property is formatted as "yyyy-MM-dd" in the city's local timezone, and the `minTemp` and `maxTemp`
    ///            represent the lowest and highest temperatures for that day.
    ///
    /// Example:
    /// ```swift
    /// let forecasts = fiveDayForecast.aggregatedForecasts()
    /// for forecast in forecasts {
    ///     print("Date: \(forecast.date), Min Temp: \(forecast.minTemp), Max Temp: \(forecast.maxTemp)")
    /// }
    /// ```
    ///
    /// - Complexity: O(n), where `n` is the number of forecast records in the `list`.
    ///
    /// - Note: This function relies on the `timezone` property of the `city` to accurately calculate the local date.
    func aggregatedForecasts() -> [DailyForecast] {
        let timezoneOffset = city.timezone
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.timeZone = TimeZone(secondsFromGMT: timezoneOffset)
        var dailyTemps: [String: (min: Double, max: Double)] = [:]
        for record in list {
            let utcDate = Date(timeIntervalSince1970: TimeInterval(record.dt))
            let dayString = dateFormatter.string(from: utcDate)
            
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
