//
//  LocationManager.swift
//  Azimut
//
//  Created by Marcel Mierzejewski on 13/09/2020.
//  Copyright © 2020 Marcel Mierzejewski. All rights reserved.
//

import CoreLocation
import MapKit
import Combine

final class LocationManager: NSObject, CLLocationManagerDelegate, ObservableObject {
    private let locationManager: CLLocationManager
    @Published var userLocation = CLLocation()
    
    init(locationManager: CLLocationManager = .init()) {
        self.locationManager = locationManager
        super.init()
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 1
    }

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .notDetermined, .authorizedWhenInUse:
            locationManager.requestAlwaysAuthorization()
        case .restricted:
            print("Location usage is restricted")
            // Show alert
            break
        case .denied:
            print("Location usage is denied")
            // Show alert
            break
        case .authorizedAlways:
            locationManager.startUpdatingLocation()
        @unknown default:
            break
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }
        
        userLocation = location
        print("Updated current user location", location)
    }
        
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        // show alert
    }
    
    public func startUpdatingLocation() {
        switch CLLocationManager.authorizationStatus() {
        case .notDetermined, .authorizedWhenInUse:
            locationManager.requestAlwaysAuthorization()
        case .restricted:
            print("Location usage is restricted")
            // Show alert
            break
        case .denied:
            print("Location usage is denied")
            // Show alert
            break
        case .authorizedAlways:
            locationManager.startUpdatingLocation()
            locationManager.startUpdatingHeading()
        @unknown default:
            break
        }
    }
}

