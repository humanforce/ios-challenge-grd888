//
//  FavoriteLocationsView.swift
//  Humanforce iOS Engineering Challenge
//
//  Created by Greg Delgado on 12/26/24.
//

import SwiftUI

struct FavoriteLocationsView: View {
    @EnvironmentObject var viewModel: CurrentWeatherViewModel
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            Group {
                if viewModel.favoriteLocations.isEmpty {
                    emptyViewMessage
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    locationList
                }
            }
            .navigationTitle("Favorite Locations")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    closeButton
                }
            }
        }
    }
    
    private var emptyViewMessage: some View {
        VStack(spacing: 16) {
            Text("No Favorites Yet")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("You can add a location to your favorites by tapping the heart icon in the Current Weather screen.")
                .font(.body)
                .foregroundStyle(Color.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)
        }
    }
    
    private var locationList: some View {
        List {
            ForEach(viewModel.favoriteLocations) { location in
                locationRow(
                    for: location,
                    currentLocation: viewModel.currentLocation,
                    selectLocation: selectLocation
                )
                .padding(.vertical, 8)
            }
            .onDelete(perform: deleteLocation)
        }
    }
    
    private var closeButton: some View {
        Button {
            dismiss()
        } label: {
            Image(systemName: "xmark")
                .foregroundStyle(Color.primary)
        }
    }
    
    private func selectLocation(_ location: Location) {
        viewModel.selectLocation(location)
        dismiss()
    }
    
    private func deleteLocation(at offsets: IndexSet) {
        viewModel.favoriteLocations.remove(atOffsets: offsets)
    }
    
    private func locationRow(for location: Location, currentLocation: Location?, selectLocation: @escaping (Location) -> Void) -> some View {
        Button(action: { selectLocation(location) }) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(location.name)
                        .font(.headline)
                    
                    if let state = location.state {
                        Text("\(state), \(location.country ?? "Unknown")")
                            .font(.subheadline)
                            .foregroundStyle(Color.secondary)
                    } else if let country = location.country {
                        Text(country)
                            .font(.subheadline)
                            .foregroundStyle(Color.secondary)
                    } else {
                        Text("Unknown")
                            .font(.subheadline)
                            .foregroundStyle(Color.secondary)
                    }
                    
                    Text("Lat: \(location.lat), Lon: \(location.lon)")
                        .font(.caption)
                        .foregroundStyle(Color.secondary)
                }
                if currentLocation == location {
                    Spacer()
                    Image(systemName: "checkmark")
                        .foregroundStyle(Color.primary)
                }
            }
        }
    }
}

#Preview {
    FavoriteLocationsView()
        .environmentObject(CurrentWeatherViewModel())
}
