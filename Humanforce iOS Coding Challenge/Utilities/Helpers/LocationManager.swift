//
//  LocationManager.swift
//  Humanforce iOS Engineering Challenge
//
//  Created by Greg Delgado on 12/26/24.
//

import CoreLocation
import os

final class LocationManager: NSObject, ObservableObject {
    private let locationManager: CLLocationManager

    @Published var currentLocation: CLLocation?
    @Published var locationError: Error?
    @Published var authorizationStatus: CLAuthorizationStatus? 
    
    override init() {
        locationManager = CLLocationManager()
        super.init()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
    }

    func requestLocation() {
        Logger().info("LOCATION: Requesting Location Update")
        locationManager.requestLocation()
    }
    
    func startUpdatingLocation() {
        locationManager.startUpdatingLocation()
    }
    
    func stopUpdatingLocation() {
        locationManager.stopUpdatingLocation()
    }
}

extension LocationManager: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        Logger().info("LOCATION: New Location Update: \(location)")
        DispatchQueue.main.async {
            self.stopUpdatingLocation()
            self.currentLocation = location
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        Logger().error("LOCATION ERROR: \(error.localizedDescription)")
        DispatchQueue.main.async {
            self.locationError = error
        }
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse, .authorizedAlways:
            locationManager.requestLocation()
        case .denied, .restricted:
            stopUpdatingLocation()
        @unknown default:
            Logger().error("Unhandled authorization status: \(manager.authorizationStatus.rawValue)")
        }
        authorizationStatus = manager.authorizationStatus
    }
}
