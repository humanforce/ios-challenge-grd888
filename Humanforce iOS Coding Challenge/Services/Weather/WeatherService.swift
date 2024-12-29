//
//  WeatherService.swift
//  Humanforce iOS Engineering Challenge
//
//  Created by Greg Delgado on 12/25/24.
//

import Foundation
import Combine
import os

enum OpenWeatherMapUrl {
    static let dataBase = "https://api.openweathermap.org/data/2.5"
    static let geoBase = "https://api.openweathermap.org/geo/1.0"
}

final class WeatherService {
    private let apiKey = APIKeyManager.weatherAPIKey

    private let httpClient: HTTPClient
    
    init(httpClient: HTTPClient) {
        self.httpClient = httpClient
    }
    
    func fetchCurrentWeather(lat: Double, lon: Double, unit: TemperatureUnit) -> AnyPublisher<CurrentWeather, Error> {
        let endpoint = "\(OpenWeatherMapUrl.dataBase)/weather"
        let parameters = [
            "lat": "\(lat)",
            "lon": "\(lon)",
            "units": unit.rawValue,
            "appid": apiKey
        ]
        Logger().info("REQUEST: Current Weather")
        return httpClient.request(
            endpoint: endpoint,
            method: .GET,
            queryParameters: parameters,
            body: nil,
            responseType: CurrentWeather.self
        )
    }

    func fetch5DayForecast(lat: Double, lon: Double, unit: TemperatureUnit) -> AnyPublisher<FiveDayForecast, Error> {
        let endpoint = "\(OpenWeatherMapUrl.dataBase)/forecast"
        let parameters = [
            "lat": "\(lat)",
            "lon": "\(lon)",
            "units": unit.rawValue,
            "appid": apiKey
        ]
        Logger().info("REQUEST: 5 day forecast")
        return httpClient.request(
            endpoint: endpoint,
            method: .GET,
            queryParameters: parameters,
            body: nil,
            responseType: FiveDayForecast.self
        )
    }

    func fetchCoordinates(for cityName: String) -> AnyPublisher<[Location], Error> {
        let endpoint = "\(OpenWeatherMapUrl.geoBase)/direct"
        let parameters = [
            "q": cityName,
            "limit": "5",
            "appid": apiKey
        ]
        Logger().info("REQUEST: Direct Geo")
        return httpClient.request(
            endpoint: endpoint,
            method: .GET,
            queryParameters: parameters,
            body: nil,
            responseType: [Location].self
        )
    }
    
    func fetchLocation(lat: Double, lon: Double) -> AnyPublisher<[Location], Error> {
        let endpoint = "\(OpenWeatherMapUrl.geoBase)/reverse"
        let parameters = [
            "lat": String(lat),
            "lon": String(lon),
            "appid": apiKey
        ]
        Logger().info("REQUEST: Reverse Geo")
        return httpClient.request(
            endpoint: endpoint,
            method: .GET,
            queryParameters: parameters,
            body: nil,
            responseType: [Location].self
        )
    }
}

