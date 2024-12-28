//
//  LocationSearchView.swift
//  Humanforce iOS Engineering Challenge
//
//  Created by Greg Delgado on 12/27/24.
//

import SwiftUI

struct LocationSearchView: View {
    @State private var searchText: String = ""
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var viewModel: CurrentWeatherViewModel
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20.0) {
                if viewModel.didPerformSearch && viewModel.searchResults.isEmpty {
                    emptyMessage
                } else {
                    searchResults
                }
            }
            .font(.title)
            .navigationTitle("Search Location")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    closeButton
                }
            }
        }
        .searchable(text: $searchText, placement: .automatic, prompt: Text("Enter a city name"))
        .onSubmit(of: .search) {
            performSearch()
        }
        .onChange(of: searchText) { _, newValue in
            viewModel.didPerformSearch = false
        }
    }
    
    private var emptyMessage: some View {
        Text("No locations found.")
            .foregroundColor(.gray)
            .padding()
    }
    
    private var searchResults: some View {
        List(viewModel.searchResults) { location in
            Button(action: {
                selectLocation(location)
            }) {
                VStack(alignment: .leading) {
                    Text(location.name)
                        .font(.headline)
                    if let country = location.stateCountry {
                        Text(country)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        .listStyle(PlainListStyle())
    }
    
    private var closeButton: some View {
        Button {
            dismiss()
        } label: {
            Image(systemName: "xmark")
                .foregroundStyle(Color.primary)
        }
    }
    
    private func performSearch() {
        guard !searchText.isEmpty else { return }
        viewModel.searchCity(name: searchText)
    }
    
    private func selectLocation(_ location: Location) {
        viewModel.selectLocation(location)
        dismiss()
    }
}


#Preview {
    LocationSearchView()
        .environmentObject(CurrentWeatherViewModel())
}
