//
//  MainViewModel.swift
//  WeatherAppTestTask
//
//  Created by Lubomyr Chorniak on 18.07.2024.
//

import CoreLocation
import Combine

class MainViewModel: NSObject, ObservableObject {
    
    private let weatherService = WeatherService()
    private let weatherDataFormatter = WeatherDataFormatter()
    
    var errorMessage: String? = nil
    @Published var isError = false
    
    @Published var isDataReady = false
    
    @Published var currentCity = ""
    
    @Published var currentTemp = ""
    @Published var weatherTypes: [String] = []
    @Published var days: [String] = []
    @Published var dayAndNightTemp: [String] = []
    
    private let locationManager = CLLocationManager()
    
    private var cancellables = Set<AnyCancellable>()

    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
       
    }
    
    private func handleError(errorMessage: String) {
        self.errorMessage = errorMessage
        self.isError.toggle()
//        self.currentCity = ""
    }
    
    
    
    private func handleData(forecastTempModel: ForecastTempModel, currentTempModel: CurrentTempModel) {
        print(forecastTempModel.daily.weatherCode)
        let dayAndNightTemp = weatherDataFormatter.getDayAndNightTemp(forecastTempModel: forecastTempModel)
        let currentTemp = String(currentTempModel.currentWeather.temperature)
        let days = weatherDataFormatter.getDays()
        let weatherTypes = weatherDataFormatter.getWeatherTypes(weatherCodes: forecastTempModel.daily.weatherCode)

        self.dayAndNightTemp = dayAndNightTemp
        self.currentTemp = currentTemp
        self.days = days
        self.weatherTypes = weatherTypes
        
        isDataReady = true
    }
    
    private func geocoder(city: String, completion: @escaping(Double, Double) -> Void) {
        let geocoder = CLGeocoder()
        
        var latitude: Double = 0
        var longitude: Double = 0
        
        geocoder.geocodeAddressString(city, completionHandler: { [weak self] (placemarks, error) in
            guard let self = self else { return }
            
            if let error = error {
                self.handleError(errorMessage: "Could not get information about this city")
                return
            }
            
            if let placemark = placemarks?.first, let location = placemark.location {
                latitude = location.coordinate.latitude
                longitude = location.coordinate.longitude
                completion(latitude, longitude)
            }
        })
    }
    
    func fetchWeatherForCity(cityName: String) {
        
        geocoder(city: cityName) { [weak self] latitude, longitude in
            guard let self = self else { return }
            
            self.weatherService.fetchForecastTemp(latitude: latitude, longitude: longitude)
                .zip(weatherService.fetchCurrentTemp(latitude: latitude, longitude: longitude))
                .sink { completion in
                    switch completion {
                    case .finished:
                        print("finished")
                    case .failure(let error):
                        self.handleError(errorMessage: error.localizedDescription)
                    }
                } receiveValue: { (forecastTempModel, currentTempModel) in
                    self.handleData(forecastTempModel: forecastTempModel, currentTempModel: currentTempModel)
                }
                .store(in: &self.cancellables)
        }
    }
    
}

// MARK: - CLLocationManagerDelegate
extension MainViewModel: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        guard let currentLocation = locationManager.location else {
            self.handleError(errorMessage: "Can't obtain current location")
            return
        }
        
        CLGeocoder().reverseGeocodeLocation(currentLocation, preferredLocale: Locale(identifier: "en")) { [weak self] (placemarks, error) in
            guard let self = self else { return }
            
            if let error {
                print("error: \(error.localizedDescription)")
                self.handleError(errorMessage: error.localizedDescription)
                return
            }
            
            guard let city = placemarks?.first?.locality else {
                self.handleError(errorMessage: "Can't obtain current city")
                return
            }
            
            self.currentCity = city
        }
        
        let currentLatitude = currentLocation.coordinate.latitude
        let currentLongitude = currentLocation.coordinate.longitude
        
        weatherService.fetchForecastTemp(latitude: currentLatitude, longitude: currentLongitude)
            .zip(weatherService.fetchCurrentTemp(latitude: currentLatitude, longitude: currentLongitude))
            .sink { [weak self] completion in
                switch completion {
                case .finished:
                    print("finished")
                case .failure(let error):
                    self?.handleError(errorMessage: error.localizedDescription)
                }
            } receiveValue: { [weak self] (forecastTempModel, currentTempModel) in
                self?.handleData(forecastTempModel: forecastTempModel, currentTempModel: currentTempModel)
            }
            .store(in: &cancellables)

    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: any Error) {
        print("didFailWithError")
        self.handleError(errorMessage: "Location update failed: \(error.localizedDescription)")
    }
    
    
}
