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

/// A view model for managing the current weather, favorite locations, and forecasts.
///
/// This view model interacts with location services and a weather provider to fetch and display current weather
/// information, 5-day forecasts, and search results for user-specified locations. It also allows users to manage
/// favorite locations and select temperature units.
///
/// - Note: This class is marked as `@MainActor` to ensure all UI updates are performed on the main thread.
@MainActor
class CurrentWeatherViewModel: ObservableObject {
    // MARK: - Published Properties
    
    /// The current location selected by the user or detected via location services.
    ///
    /// When updated, the location is saved to user defaults and triggers a reload of all widgets' timelines.
    @Published var currentLocation: Location? {
        didSet {
            currentLocation?.saveToDefaults()
            WidgetCenter.shared.reloadAllTimelines()
        }
    }
    
    /// A list of the user's favorite locations.
    ///
    /// When updated, the list is saved persistently.
    @Published var favoriteLocations: [Location] = [] {
        didSet {
            Location.saveFavoriteLocations(favoriteLocations)
        }
    }
    
    /// The current weather data for the selected location.
    ///
    /// When updated, the weather is saved to user defaults and triggers a reload of all widgets' timelines.
    @Published var currentWeather: CurrentWeather? {
        didSet {
            currentWeather?.saveToDefaults()
            WidgetCenter.shared.reloadAllTimelines()
        }
    }
    
    /// The 5-day weather forecast for the selected location.
    @Published var fiveDayForecast: [DailyForecast] = []
    
    /// The current temperature unit (e.g., Celsius or Fahrenheit) selected by the user.
    ///
    /// When updated, the temperature unit is saved to user defaults and triggers a reload of all widgets' timelines.
    @Published var currentTemperatureUnit: TemperatureUnit {
        didSet {
            currentTemperatureUnit.saveToDefaults()
            WidgetCenter.shared.reloadAllTimelines()
        }
    }
    
    /// The results of a location search query.
    @Published var searchResults: [Location] = []
    
    /// The error message to display when an operation fails.
    @Published var errorMessage: String?
    
    /// The error message to display when location authorization fails.
    @Published var authorizationErrorMessage: String?
    
    /// A flag indicating whether a data-fetching operation is in progress.
    @Published var isLoading = false
    
    /// A flag indicating whether a location search was performed.
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
    
    // MARK: - Computed Properties
        
    /// Whether the current location is in the user's list of favorites.
    var isFavorite: Bool {
        guard let currentLocation else { return false }
        return favoriteLocations.contains(currentLocation)
    }
    
    /// The name of the current location.
    var locationName: String {
        currentLocation?.name ?? "-------"
    }
    
    /// The state and country of the current location.
    var stateCountry: String {
        currentLocation?.stateCountry ?? "-------"
    }
    
    /// The coordinates of the current location in LAT/LON format.
    var coordinates: String {
        guard let currentLocation else { return "---" }
        return "LAT:\(currentLocation.lat), LON:\(currentLocation.lon)"
    }
    
    /// The current temperature formatted with the selected temperature unit.
    var temperature: String {
        guard let currentWeather else { return "---" }
        let temp = currentWeather.main.temp.roundedToInt()
        return "\(temp) \(currentTemperatureUnit.symbol)"
    }
    
    /// A short description of the current weather (e.g., "Rain", "Clear").
    var mainDescription: String {
        guard let currentWeather else { return "---" }
        return currentWeather.weather.first?.main ?? "---"
    }
    
    /// The icon representing the current weather conditions.
    var weatherIcon: String {
        return currentWeather?.weather.first?.icon ?? ""
    }
    
    /// The current humidity as a percentage.
    var humidity: String {
        "\(currentWeather?.main.humidity ?? 0) %"
    }
    /// The "feels like" temperature formatted with the selected temperature unit.
    var feelsLike: String {
        "\(currentWeather?.main.feelsLike.roundedToInt() ?? 0) \(currentTemperatureUnit.symbol)"
    }
    private let weatherProvider: WeatherProvider
    private let locationManager: LocationManager
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Public Methods
    
    /// Fetches the current weather data and 5-day forecast for the current location.
    ///
    /// This method uses the `weatherProvider` to fetch data from an external API, then updates the
    /// `currentWeather` and `fiveDayForecast` properties with the retrieved values.
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
    
    /// Searches for locations matching the specified city name.
    ///
    /// - Parameter name: The name of the city to search for.
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
    
    /// Selects a location and fetches weather data for it.
    ///
    /// - Parameter location: The location to set as the current location.
    func selectLocation(_ location: Location) {
        currentLocation = location
        fetchWeatherData()
    }

    /// Updates the current temperature unit and refreshes the weather data.
    ///
    /// - Parameter unit: The temperature unit to set (e.g., Celsius or Fahrenheit).
    func selectTemperatureUnit(_ unit: TemperatureUnit) {
        currentTemperatureUnit = unit
        fetchWeatherData()
    }

    /// Toggles the current location's favorite status.
    ///
    /// If the location is already a favorite, it will be removed from the list of favorites. Otherwise, it will
    /// be added to the list.
    func toggleFavorite() {
        if let location = currentLocation {
            if let index = favoriteLocations.firstIndex(of: location) {
                favoriteLocations.remove(at: index)
            } else {
                favoriteLocations.append(location)
            }
        }
    }
    
    /// Observes changes to the user's current location and retrieves detailed location information.
    /// Updates the current location state or handles errors if the fetch operation fails.
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
    
    /// Subscribes to the authorization status publisher and observes changes in location services authorization.
    /// If the status is `.denied` or `.restricted`, it updates the `authorizationErrorMessage` with a message
    /// prompting the user to enable location services in Settings.
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
