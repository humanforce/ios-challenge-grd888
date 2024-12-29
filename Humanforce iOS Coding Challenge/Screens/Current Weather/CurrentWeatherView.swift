//
//  CurrentWeatherView.swift
//  Humanforce iOS Engineering Challenge
//
//  Created by Greg Delgado on 12/25/24.
//

import SwiftUI

struct CurrentWeatherView: View {
    @EnvironmentObject var viewModel: CurrentWeatherViewModel
    @State private var showSearch = false
    @State private var showFavorites = false
    @State private var activeAlert: AlertType?

    @State private var animatedTemperature: String = "----"
    @State private var animatedLocationName: String = "--------"

    var body: some View {
        NavigationStack {
            ZStack {
                VStack(spacing: 8) {
                    locationName
                    
                    stateCountry
                    
                    locationCoordinates
                    
                    currentTemperature
                    
                    cloudInfo(
                        with: viewModel.mainDescription,
                        icon: viewModel.weatherIcon
                    )
                    
                    forecastButton
                    
                    Spacer()
                    
                    refreshButton
                }
                .padding(.top, 40)
                .padding(.horizontal, 20)
                .sheet(isPresented: $showSearch) {
                    LocationSearchView()
                }
                .sheet(isPresented: $showFavorites) {
                    FavoriteLocationsView()
                }
                .alert(item: $activeAlert) { alertType in
                    alert(for: alertType)
                }
                .onChange(of: viewModel.errorMessage) { _, message in
                    if let message {
                        activeAlert = .error(message)
                    }
                }
                .onChange(of: viewModel.authorizationErrorMessage) { _, message in
                    if let message {
                        activeAlert = .authorization(message)
                    }
                }
                .onChange(of: viewModel.temperature) { _, newTemperature in
                    withAnimation {
                        animatedTemperature = newTemperature
                    }
                }
                .onChange(of: viewModel.locationName) { _, newName in
                    withAnimation {
                        animatedLocationName = newName
                    }
                }
                .disabled(viewModel.isLoading)
                
                if viewModel.isLoading {
                    Color.black.opacity(0.4)
                        .ignoresSafeArea()
                    
                    VStack {
                        Spacer()
                        ProgressView("Loading...")
                            .progressViewStyle(CircularProgressViewStyle(tint: Color.secondary))
                            .foregroundStyle(Color.secondary)
                            .padding(.bottom, 100)
                    }
                }
            }
            .toolbar {
                WeatherToolbar(
                    showFavorites: $showFavorites,
                    showSearch: $showSearch,
                    onSelectTemperatureUnit: viewModel.selectTemperatureUnit,
                    currentUnit: viewModel.currentTemperatureUnit
                )
            }
        }
    }
    
    private var locationName: some View {
        Text(animatedLocationName)
            .font(.system(size: UIScreen.main.bounds.width > 320 ? 60 : 40))
            .multilineTextAlignment(.center)
            .minimumScaleFactor(0.5)
    }
    
    private var stateCountry: some View {
        HStack(spacing: 8) {
            Button(action: {
                viewModel.toggleFavorite()
            }) {
                Image(systemName: viewModel.isFavorite ? "heart.fill" : "heart")
                    .foregroundColor(viewModel.isFavorite ? .red : .secondary)
                    .symbolEffect(.pulse)
            }
            Text(viewModel.stateCountry)
                .font(.title)
                .foregroundStyle(Color.secondary)
        }
    }
    
    private var locationCoordinates: some View {
        Text(viewModel.coordinates)
            .font(.caption)
            .foregroundStyle(Color.secondary)
    }
    
    private var currentTemperature: some View {
        Text(animatedTemperature)
            .font(.system(size: 84))
            .fontWeight(.thin)
            .contentTransition(.numericText())
    }
    
    private var forecastButton: some View {
        NavigationLink {
            FiveDayForecastView(forecasts: viewModel.fiveDayForecast)
        } label: {
            Text("5 Day Forecast")
        }
    }
    
    private var refreshButton: some View {
        Button(action: {
            viewModel.fetchWeatherData()
        }) {
            Label("", systemImage: "arrow.clockwise.circle.fill")
                .font(.title)
                .padding()
        }
    }
    
    func cloudInfo(with description: String, icon: String) -> some View {
        VStack(spacing: 0) {
            if !icon.isEmpty {
                Image(icon)
                    .resizable()
                    .frame(width: 50, height: 50)
            }
            
            Text(description)
                .font(.title2)
                .foregroundStyle(Color.primary)
                .padding(.bottom, 16)
        }
        .frame(maxWidth: .infinity)
        .background(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color(.lightBlueStart),
                            Color(.lightBlueEnd)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .shadow(color: Color.primary.opacity(0.2), radius: 5, x: 0, y: 5)
                .padding(30)
    }
    
    private func alert(for alertType: AlertType) -> Alert {
        switch alertType {
        case .error:
            return Alert(title: Text("Error"), message: Text(alertType.message))
        case .authorization:
            return Alert(
                title: Text("Location Services Disabled"),
                message: Text(alertType.message),
                primaryButton: .default(Text("Go to Settings")) {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                },
                secondaryButton: .cancel(Text("Dismiss"))
            )
        }
    }
}

#Preview {
    CurrentWeatherView()
        .environmentObject(CurrentWeatherViewModel(
            location: Location.mock,
            weather: CurrentWeather.mock
        ))
        .environmentObject(LocationManager())
}
