//
//  Weather.swift
//  Humanforce iOS Engineering Challenge
//
//  Created by Greg Delgado on 12/25/24.
//

import Foundation

struct CurrentWeather: Codable {
    let coord: Coord
    let weather: [Weather]
    let base: String
    let main: Main
    let visibility: Int
    let wind: Wind
    let clouds: Clouds
    let dt: Int
    let timezone, id: Int
    let name: String
    let cod: Int
}

extension CurrentWeather {
    static var mock: CurrentWeather {
        CurrentWeather(
            coord: Coord(lat: 14.1196, lon: 120.9091),
            weather: [Weather(id: 804, main: "Clouds and Thunder", description: "overcast clouds", icon: "04n")],
            base: "stations",
            main: Main(temp: 19.31, feelsLike: 20.21, tempMin: 19.63, tempMax: 19.63, pressure: 1015, seaLevel: 1015, grndLevel: 987, humidity: 98),
            visibility: 10000,
            wind: Wind(speed: 2.3, deg: 84, gust: 8.39),
            clouds: Clouds(all: 100),
            dt: 1735132614,
            timezone: 28800,
            id: 1699858,
            name: "Mendez-Nuñez",
            cod: 200
        )
    }
}
