//
//  WeatherToolbar.swift
//  Humanforce iOS Engineering Challenge
//
//  Created by Greg Delgado on 12/28/24.
//

import SwiftUI

struct WeatherToolbar: ToolbarContent {
    @Binding var showFavorites: Bool
    @Binding var showSearch: Bool
    let onSelectTemperatureUnit: (TemperatureUnit) -> Void
    let currentUnit: TemperatureUnit

    var body: some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            Menu {
                ForEach(TemperatureUnit.allCases, id: \.self) { unit in
                    Button {
                        onSelectTemperatureUnit(unit)
                    } label: {
                        HStack {
                            Text(unit.displayName)
                            if currentUnit == unit {
                                Image(systemName: "checkmark")
                            }
                        }
                    }
                }
            } label: {
                Image(systemName: "gearshape")
                    .symbolRenderingMode(.hierarchical)
            }
        }
        
        ToolbarItem(placement: .topBarTrailing) {
            HStack {
                Button { showFavorites = true } label: {
                    Image(systemName: "heart")
                        .symbolRenderingMode(.hierarchical)
                }
                Button { showSearch = true } label: {
                    Image(systemName: "plus.circle")
                        .symbolRenderingMode(.hierarchical)
                }
            }
        }
    }
}
