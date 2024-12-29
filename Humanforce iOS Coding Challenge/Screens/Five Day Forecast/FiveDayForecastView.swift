//
//  FiveDayForecastView.swift
//  Humanforce iOS Engineering Challenge
//
//  Created by Greg Delgado on 12/26/24.
//

import SwiftUI

struct FiveDayForecastView: View {
    @EnvironmentObject var viewModel: CurrentWeatherViewModel
    
    var forecasts: [DailyForecast] = []
    var formatter = DateFormatter()
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("5-Day Forecast")
                    .font(.largeTitle)
                    .bold()
                    .padding(.top, 20)
                
                ForEach(forecasts, id: \.date) { forecast in
                    forecastRow(
                        for: forecast,
                        symbol: viewModel.currentTemperatureUnit.symbol
                    )
                }
            }
            .padding(.horizontal)
        }
    }
    
    @ViewBuilder
    func forecastRow(for forecast: DailyForecast, symbol: String) -> some View {
        HStack {
            Text(formatDateString(forecast.date))
                .font(.headline)
            
            Spacer()
            
            VStack {
                Text("L: \(forecast.minTemp.roundedToInt()) \(symbol)")
                    .font(.subheadline)
                    .foregroundColor(.blue)
                
                Text("H: \(forecast.maxTemp.roundedToInt()) \(symbol)")
                    .font(.subheadline)
                    .foregroundColor(.red)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(UIColor.systemGray6))
        )
        .shadow(color: .gray.opacity(0.2), radius: 5, x: 0, y: 5)
    }
    
    private func formatDateString(_ dateString: String) -> String {
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "yyyy-MM-dd"
//        inputFormatter.locale = Locale(identifier: "en_US_POSIX")
        
        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = "E - MMM d"
//        outputFormatter.locale = Locale(identifier: "en_US_POSIX")
        
        let date = inputFormatter.date(from: dateString) ?? Date()
        
        return outputFormatter.string(from: date)
    }
}

#Preview {
    FiveDayForecastView(forecasts: [
        DailyForecast(date: "2024-12-26", minTemp: -3.0, maxTemp: 2.0),
        DailyForecast(date: "2024-12-27", minTemp: -2.0, maxTemp: 3.5),
        DailyForecast(date: "2024-12-28", minTemp: -1.0, maxTemp: 4.0),
        DailyForecast(date: "2024-12-29", minTemp: 0.0, maxTemp: 5.0),
        DailyForecast(date: "2024-12-30", minTemp: 1.0, maxTemp: 6.0)
    ])
}
