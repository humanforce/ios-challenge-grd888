//
//  HFWeatherWidget.swift
//  HFWeatherWidget
//
//  Created by Greg Delgado on 12/29/24.
//

import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> WeatherEntry {
        WeatherEntry(
            date: Date(),
            location: Location.mock,
            weather: CurrentWeather.mock,
            unit: TemperatureUnit.metric
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (WeatherEntry) -> ()) {
        let entry = WeatherEntry(
            date: Date(),
            location: Location.mock,
            weather: CurrentWeather.mock,
            unit: TemperatureUnit.metric
        )
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        let currentLocation = Location.loadFromDefaults() ?? Location.mock
        let currentWeather = CurrentWeather.loadFromDefaults() ?? CurrentWeather.mock
        let temperatureUnit = TemperatureUnit.loadFromDefaults()

        let nextUpdate = Date().addingTimeInterval(3600) // 1 hour
        let entry = WeatherEntry(
            date: .now,
            location: currentLocation,
            weather: currentWeather,
            unit: temperatureUnit
        )
        
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        completion(timeline)
    }
}

struct WeatherEntry: TimelineEntry {
    let date: Date
    let location: Location
    let weather: CurrentWeather
    let unit: TemperatureUnit
    
    var currentTemperature: String {
        "\(weather.main.temp.roundedToInt()) \(unit.symbol)"
    }
    var realFeel: String {
        "\(weather.main.feelsLike.roundedToInt()) \(unit.symbol)"
    }
}

struct HFWeatherWidgetEntryView : View {
    @Environment(\.widgetFamily) var family
    var entry: WeatherEntry

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                HStack {
                    Text(entry.location.name)
                        .font(.title3)
                        .fontWeight(.semibold)
                        .minimumScaleFactor(0.6)
                        .lineLimit(1)
                    Spacer()
                }
                
                if let stateCountry = entry.location.stateCountry {
                    HStack {
                        Text(stateCountry)
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundStyle(Color.secondary)
                            .minimumScaleFactor(0.6)
                            .lineLimit(1)
                        Spacer()
                    }
                }
                
                Text(entry.currentTemperature)
                    .font(.system(size: 64, weight: .light))
                    .minimumScaleFactor(0.6)
                    .lineLimit(1)
                
                HStack {
                    Text("Feels like")
                    Text(entry.realFeel)
                }
                .font(.caption2)
                .fontWeight(.medium)
                .foregroundStyle(Color.secondary)
                
            }
            if family == .systemMedium {
                VStack(spacing: 0) {
                    if !entry.weather.weatherIcon.isEmpty {
                        Image(entry.weather.weatherIcon)
                            .resizable()
                            .frame(width: 100, height: 100)
                    }
                    Text(entry.weather.mainDescription)
                        .font(.footnote)
                        .fontWeight(.semibold)
                        .foregroundStyle(Color.secondary)
                        .minimumScaleFactor(0.6)
                        .offset(y: -10)
                }
            }
        }
    }
}

struct HFWeatherWidget: Widget {
    let kind: String = "HFWeatherWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            if #available(iOS 17.0, *) {
                HFWeatherWidgetEntryView(entry: entry)
                    .containerBackground(.widgetBackground.gradient, for: .widget)
            } else {
                HFWeatherWidgetEntryView(entry: entry)
                    .padding()
                    .background()
            }
        }
        .configurationDisplayName("Current Conditions")
        .description("Real-time weather information")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

#Preview(as: .systemMedium) {
    HFWeatherWidget()
} timeline: {
    WeatherEntry(
        date: .now,
        location: Location.mock,
        weather: CurrentWeather.mock,
        unit: TemperatureUnit.metric
    )
}
