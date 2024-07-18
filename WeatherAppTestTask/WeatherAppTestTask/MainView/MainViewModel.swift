//
//  MainViewModel.swift
//  WeatherAppTestTask
//
//  Created by Lubomyr Chorniak on 18.07.2024.
//

import CoreLocation
import Combine

class MainViewModel: NSObject, ObservableObject {
    
    var errorMessage: String? = nil
    @Published var isError = false
    
    @Published var currentCity = ""
    
    private let locationManager = CLLocationManager()
    
    override init() {
        super.init()
        locationManager.requestWhenInUseAuthorization()
        locationManager.delegate = self
        locationManager.requestLocation()
    }
    
    private func handleError(errorMessage: String) {
        self.errorMessage = errorMessage
        self.isError.toggle()
        self.currentCity = ""
    }
    
}

extension MainViewModel: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        guard let currentLocation = locationManager.location else {
            self.handleError(errorMessage: "Can't obtain current location")
            return
        }
        
        CLGeocoder().reverseGeocodeLocation(currentLocation, preferredLocale: Locale(identifier: "en")) { [weak self] (placemarks, error) in
            guard let self = self else { return }
            
            if let error {
                self.handleError(errorMessage: error.localizedDescription)
                return
            }
            
            guard let city = placemarks?.first?.locality else {
                self.handleError(errorMessage: "Can't obtain current city")
                return
            }
            
            self.currentCity = city
        }
        
        
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: any Error) {
        self.handleError(errorMessage: "Location update failed: \(error.localizedDescription)")
    }
    
}
