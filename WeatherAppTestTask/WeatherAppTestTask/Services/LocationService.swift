//
//  LocationService.swift
//  WeatherAppTestTask
//
//  Created by Lubomyr Chorniak on 20.07.2024.
//

import Combine
import CoreLocation

class LocationService: NSObject {
    
    var isAuthorized = false

    enum LocationError: LocalizedError {
        case authorizationDenied
        case couldNotFetchLocation
        
        var errorDescription: String? {
            switch self {
            case .authorizationDenied:
                return nil
            case .couldNotFetchLocation:
                return "Could not fetch your location"
            }
        }
    }
    
    private var locationPromise: ((Result<CLLocation, LocationError>) -> Void)?
    private let locationManager = CLLocationManager()
    
    override init() {
        super.init()
        locationManager.delegate = self
    }
    
    func getUserLocation() -> Future<CLLocation, LocationError> {
        return Future { promise in
            self.locationPromise = promise
            self.startLocationServices()
        }
    }

    func startLocationServices() {
        if locationManager.authorizationStatus == .authorizedAlways || locationManager.authorizationStatus == .authorizedWhenInUse {
            locationManager.startUpdatingLocation()
            isAuthorized = true
        } else {
            isAuthorized = false
            locationManager.requestWhenInUseAuthorization()
        }
    }
    
}

extension LocationService: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            locationPromise?(.success(location))
        } else {
            locationPromise?(.failure(LocationError.couldNotFetchLocation))
        }
        locationPromise = nil
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: any Error) {
        locationPromise?(.failure(LocationError.couldNotFetchLocation))
        locationPromise = nil
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedAlways, .authorizedWhenInUse:
            isAuthorized = true
            manager.requestLocation()
        case .notDetermined:
            isAuthorized = false
            manager.requestWhenInUseAuthorization()
        case .denied:
            isAuthorized = false
            locationPromise?(.failure(LocationError.authorizationDenied))
        default:
            isAuthorized = true
            startLocationServices()
        }
    }
    
}
