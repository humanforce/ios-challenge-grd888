//
//  FiveDayForecastTests.swift
//  HumanForceChallengeTests
//
//  Created by Greg Delgado on 12/29/24.
//

import XCTest
@testable import Humanforce_iOS_Engineering_Challenge

final class FiveDayForecastTests: XCTestCase {

    func testDailyAggregation() throws {
        let jsonString = """
        {
          "cod": "200",
          "message": 0,
          "cnt": 40,
          "list": [
            {
              "dt": 1735484400,
              "main": {
                "temp": 25.73,
                "feels_like": 26.76,
                "temp_min": 25.73,
                "temp_max": 25.86,
                "pressure": 1013,
                "sea_level": 1013,
                "grnd_level": 1012,
                "humidity": 92,
                "temp_kf": -0.13
              },
              "weather": [
                {
                  "id": 500,
                  "main": "Rain",
                  "description": "light rain",
                  "icon": "10n"
                }
              ],
              "clouds": {
                "all": 100
              },
              "wind": {
                "speed": 4.88,
                "deg": 69,
                "gust": 9.89
              },
              "visibility": 10000,
              "pop": 0.63,
              "rain": {
                "3h": 0.42
              },
              "sys": {
                "pod": "n"
              },
              "dt_txt": "2024-12-29 15:00:00"
            },
            {
              "dt": 1735495200,
              "main": {
                "temp": 25.69,
                "feels_like": 26.61,
                "temp_min": 24.6,
                "temp_max": 25.69,
                "pressure": 1012,
                "sea_level": 1012,
                "grnd_level": 1010,
                "humidity": 88,
                "temp_kf": 0.09
              },
              "weather": [
                {
                  "id": 500,
                  "main": "Rain",
                  "description": "light rain",
                  "icon": "10n"
                }
              ],
              "clouds": {
                "all": 92
              },
              "wind": {
                "speed": 4,
                "deg": 63,
                "gust": 8.06
              },
              "visibility": 10000,
              "pop": 0.55,
              "rain": {
                "3h": 0.11
              },
              "sys": {
                "pod": "n"
              },
              "dt_txt": "2024-12-29 18:00:00"
            },
            {
              "dt": 1735506000,
              "main": {
                "temp": 25.64,
                "feels_like": 26.45,
                "temp_min": 25.6,
                "temp_max": 28.64,
                "pressure": 1012,
                "sea_level": 1012,
                "grnd_level": 1011,
                "humidity": 84,
                "temp_kf": 0.04
              },
              "weather": [
                {
                  "id": 804,
                  "main": "Clouds",
                  "description": "overcast clouds",
                  "icon": "04n"
                }
              ],
              "clouds": {
                "all": 89
              },
              "wind": {
                "speed": 3.62,
                "deg": 74,
                "gust": 6.83
              },
              "visibility": 10000,
              "pop": 0.31,
              "sys": {
                "pod": "n"
              },
              "dt_txt": "2024-12-29 21:00:00"
            }
          ],
          "city": {
            "id": 1701968,
            "name": "Mandaluyong City",
            "coord": {
              "lat": 14.5776,
              "lon": 121.0337
            },
            "country": "PH",
            "population": 0,
            "timezone": 28800,
            "sunrise": 1735424378,
            "sunset": 1735464953
          }
        }
        """
        
        let jsonData = jsonString.data(using: .utf8)!
        let fiveDay = try JSONDecoder().decode(FiveDayForecast.self, from: jsonData)
        
        let forecasts = fiveDay.aggregatedForecasts()
        XCTAssertEqual(forecasts.count, 2)
        XCTAssertEqual(forecasts[0].date, "2024-12-29")
        XCTAssertEqual(forecasts[0].maxTemp, 25.86)
        XCTAssertEqual(forecasts[0].minTemp, 25.73)
        
        XCTAssertEqual(forecasts[1].date, "2024-12-30")
        XCTAssertEqual(forecasts[1].maxTemp, 28.64)
        XCTAssertEqual(forecasts[1].minTemp, 24.6)
    }
}

