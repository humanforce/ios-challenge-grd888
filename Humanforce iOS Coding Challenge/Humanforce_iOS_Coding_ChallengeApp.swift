//
//  Humanforce_iOS_Coding_ChallengeApp.swift
//  Humanforce iOS Coding Challenge
//
//  Created by Lachlan on 2/12/2024.
//

import SwiftUI

@main
struct Humanforce_iOS_Coding_ChallengeApp: App {
    @StateObject private var viewModel = CurrentWeatherViewModel()
    
    var body: some Scene {
        WindowGroup {
            CurrentWeatherView()
                .environmentObject(viewModel)
        }
    }
}
