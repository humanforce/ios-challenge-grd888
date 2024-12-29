//
//  File.swift
//  Humanforce iOS Engineering Challenge
//
//  Created by Greg Delgado on 12/29/24.
//

import Foundation
import Combine

protocol WeatherProvider {
    func fetchCurrentWeather(lat: Double, lon: Double, unit: TemperatureUnit) -> AnyPublisher<CurrentWeather, Error>
    func fetch5DayForecast(lat: Double, lon: Double, unit: TemperatureUnit) -> AnyPublisher<FiveDayForecast, Error>
    func fetchCoordinates(for cityName: String) -> AnyPublisher<[Location], Error>
    func fetchLocation(lat: Double, lon: Double) -> AnyPublisher<[Location], Error>
}
