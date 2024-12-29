//
//  CurrentWeatherViewModel.swift
//  Humanforce iOS Engineering Challenge
//
//  Created by Greg Delgado on 12/25/24.
//

import Foundation
import Combine
import CoreLocation
import WidgetKit

@MainActor
class CurrentWeatherViewModel: ObservableObject {
    @Published var currentLocation: Location? {
        didSet {
            currentLocation?.saveToDefaults()
            WidgetCenter.shared.reloadAllTimelines()
        }
    }
    @Published var favoriteLocations: [Location] = [] {
        didSet {
            Location.saveFavoriteLocations(favoriteLocations)
        }
    }
    @Published var currentWeather: CurrentWeather? {
        didSet {
            currentWeather?.saveToDefaults()
            WidgetCenter.shared.reloadAllTimelines()
        }
    }
    @Published var fiveDayForecast: [DailyForecast] = []
    @Published var currentTemperatureUnit: TemperatureUnit {
        didSet {
            currentTemperatureUnit.saveToDefaults()
            WidgetCenter.shared.reloadAllTimelines()
        }
    }
    @Published var searchResults: [Location] = []
    @Published var errorMessage: String?
    @Published var authorizationErrorMessage: String?
    @Published var isLoading = false
    @Published var didPerformSearch = false
    
    init(locationManager: LocationManager = LocationManager(),
         weatherProvider: WeatherProvider = WeatherService(
            httpClient: NetworkManager.shared),
         location: Location? = nil,
         weather: CurrentWeather? = nil) {
        self.locationManager = locationManager
        self.weatherProvider = weatherProvider
        self.currentLocation = location
        self.currentWeather = weather
        self.currentTemperatureUnit = TemperatureUnit.loadFromDefaults()
        self.favoriteLocations = Location.loadFavoriteLocations()
        
        observeLocation()
        observeAuthorizationStatus()
    }
    var isFavorite: Bool {
        guard let currentLocation else { return false }
        return favoriteLocations.contains(currentLocation)
    }
    var locationName: String {
        currentLocation?.name ?? "-------"
    }
    var stateCountry: String {
        currentLocation?.stateCountry ?? "-------"
    }
    var coordinates: String {
        guard let currentLocation else { return "---" }
        return "LAT:\(currentLocation.lat), LON:\(currentLocation.lon)"
    }
    var temperature: String {
        guard let currentWeather else { return "---" }
        let temp = currentWeather.main.temp.roundedToInt()
        return "\(temp) \(currentTemperatureUnit.symbol)"
    }
    var mainDescription: String {
        guard let currentWeather else { return "---" }
        return currentWeather.weather.first?.main ?? "---"
    }
    var weatherIcon: String {
        return currentWeather?.weather.first?.icon ?? ""
    }
    var humidity: String {
        "\(currentWeather?.main.humidity ?? 0) %"
    }
    var feelsLike: String {
        "\(currentWeather?.main.feelsLike.roundedToInt() ?? 0) \(currentTemperatureUnit.symbol)"
    }
    private let weatherProvider: WeatherProvider
    private let locationManager: LocationManager
    private var cancellables = Set<AnyCancellable>()
    
    func fetchWeatherData() {
        guard let currentLocation else { return }
        
        let lat = currentLocation.lat
        let lon = currentLocation.lon
        let unit = currentTemperatureUnit
        
        let currentWeatherPublisher =
        weatherProvider.fetchCurrentWeather(lat: lat, lon: lon, unit: unit)
        
        let fiveDayForecastPublisher =
        weatherProvider.fetch5DayForecast(lat: lat, lon: lon, unit: unit)
                .map { $0.aggregatedForecasts() }

        isLoading = true
        currentWeatherPublisher.zip(fiveDayForecastPublisher)
            .sink(receiveCompletion: { [weak self] completion in
                guard let self else { return }
                isLoading = false
                if case let .failure(error) = completion {
                    handleError(error: error)
                }
            }, receiveValue: { currentWeather, dailyForecasts in
                self.currentWeather = currentWeather
                self.fiveDayForecast = dailyForecasts
            })
            .store(in: &cancellables)
    }
    
    func searchCity(name: String) {
        guard !name.isEmpty else { return }
        isLoading = true
        didPerformSearch = false
        weatherProvider.fetchCoordinates(for: name)
            .sink { [weak self] completion in
                guard let self else { return }
                self.isLoading = false
                self.didPerformSearch = true
                if case let .failure(error) = completion {
                    handleError(error: error)
                }
            } receiveValue: { [weak self] locations in
                guard let self else { return }
                self.searchResults = locations
            }
            .store(in: &cancellables)
    }
    
    func selectLocation(_ location: Location) {
        currentLocation = location
        fetchWeatherData()
    }
    
    func selectTemperatureUnit(_ unit: TemperatureUnit) {
        currentTemperatureUnit = unit
        fetchWeatherData()
    }
    
    func toggleFavorite() {
        if let location = currentLocation {
            if let index = favoriteLocations.firstIndex(of: location) {
                favoriteLocations.remove(at: index)
            } else {
                favoriteLocations.append(location)
            }
        }
    }
    
    private func observeLocation() {
        isLoading = true
        locationManager.$currentLocation
            .compactMap { $0 }
            .flatMap { [weak self] location -> AnyPublisher<[Location], Error> in
                guard let self else {
                    return Fail(error: NSError(domain: "Self is nil", code: -1))
                        .eraseToAnyPublisher()
                }
                let lat = location.coordinate.latitude
                let lon = location.coordinate.longitude
                return self.weatherProvider.fetchLocation(lat: lat, lon: lon)
            }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                guard let self else { return }
                isLoading = false
                if case .failure(let error) = completion {
                    handleError(error: error)
                }
            } receiveValue: { [weak self] locations in
                guard let self else { return }
                if let location = locations.first {
                    selectLocation(location)
                }
            }
            .store(in: &cancellables)
        
        locationManager.$locationError.sink { [weak self] error in
            guard let self else { return }
            if let locationError = error as? CLError {
                switch locationError.code {
                case .locationUnknown:
                    errorMessage = "Your location could not be determined at this time."
                case .denied:
                    errorMessage = "Location services are disabled. Please enable them in Settings to use the app."
                case .network:
                    errorMessage = "A network error occurred while determining your location. Check your connection."
                default:
                    errorMessage = "An unexpected error occurred: \(locationError.localizedDescription)"
                }
            } else {
                errorMessage = error?.localizedDescription ?? "An unknown location error occurred."
            }
        }.store(in: &cancellables)        
    }
    
    private func observeAuthorizationStatus() {
        locationManager.$authorizationStatus
            .sink { [weak self] status in
                guard let self, let status else { return }
                if status == .denied || status == .restricted {
                    DispatchQueue.main.async {
                        self.authorizationErrorMessage = "Location services are disabled. Please enable them in Settings to use the app."
                    }
                }
            }
            .store(in: &cancellables)
    }
    
    private func handleError(error: Error) {
        if let networkError = error as? NetworkError {
            errorMessage = networkError.errorDescription
        } else {
            errorMessage = "An unexpected error occurred: \(error.localizedDescription)"
        }
    }
}
