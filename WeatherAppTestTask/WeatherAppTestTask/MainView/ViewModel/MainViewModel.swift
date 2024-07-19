//
//  MainViewModel.swift
//  WeatherAppTestTask
//
//  Created by Lubomyr Chorniak on 18.07.2024.
//

import CoreLocation
import Combine

struct HourForecaset {
    let hour: String
    let weatherType: String
    let temp: String
}

struct DayForecast {
    let weatherType: String
    let day: String
    let dayAndNightTemp: String
}

class MainViewModel: NSObject, ObservableObject {
    
    private let apiClinet = APIClient()
    private let weatherDataFormatter = WeatherDataFormatter()
    private let locationManager = CLLocationManager()
    
    var isAuthorized = false
    var errorMessage: String? = nil
    @Published var isError = false
    
    @Published var isDataReady = false
    @Published var isContentAvailable = true
    
    @Published var currentCity = ""
    @Published var currentTemp = ""
    @Published var todaysDayAndNightTemp: String? = ""
    
    @Published var hourlyForecast: [HourForecaset] = []
    @Published var dailyForecast: [DayForecast] = []
    
    private var cancellables = Set<AnyCancellable>()

    override init() {
        super.init()
        locationManager.delegate = self
        startLocationServices()
        
        $currentCity
            .dropFirst(2)
            .sink { city in
                print("here")
                print(city)
                self.fetchWeatherForCity(cityName: city)
            }
            .store(in: &cancellables)
        
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

    
    private func handleError(errorMessage: String) {
        self.errorMessage = errorMessage
        self.isError = true
        isContentAvailable = false
        isDataReady = false
        self.dailyForecast = []
    }

    private func handleData(dailyWeather: DailyWeatherModel, hourlyWeather: HourlyWeatherModel) {
        currentTemp = String(dailyWeather.currentWeather.temperature)
        dailyForecast = weatherDataFormatter.getDailyForecast(dailyWeather: dailyWeather)
        hourlyForecast = weatherDataFormatter.getHourlyForecast(hourlyWeather: hourlyWeather)
        todaysDayAndNightTemp = dailyForecast.first?.dayAndNightTemp

        self.isContentAvailable = true
        self.isDataReady = true
    }

    private func geocoder(city: String, completion: @escaping(Double, Double) -> Void) {
        let geocoder = CLGeocoder()
        
        var latitude: Double = 0
        var longitude: Double = 0
        
        geocoder.geocodeAddressString(city, completionHandler: { [weak self] (placemarks, error) in
            guard let self = self else { return }
            
            if error != nil {
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
            self.fetchWeather(latitude: latitude, longitude: longitude)
        }
    }
    
    private func fetchWeather(latitude: Double, longitude: Double) {
        apiClinet.fetch(.dailyWeather(latitude: latitude, longitude: longitude))
            .zip(apiClinet.fetch(.hourlyWeather(latitude: latitude, longitude: longitude)))
            .sink { [weak self] completion in
                switch completion {
                case .finished: break
                case .failure(let error):
                    self?.handleError(errorMessage: error.localizedDescription)
                }
            } receiveValue: { [weak self] (dailyWeatherModel, hourlyWeatherModel) in
                self?.handleData(dailyWeather: dailyWeatherModel, hourlyWeather: hourlyWeatherModel)
            }
            .store(in: &cancellables)
    }
    
}

// MARK: - CLLocationManagerDelegate
extension MainViewModel: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let currentLocation = locationManager.location else {
            self.handleError(errorMessage: "Can't obtain current location")
            return
        }
//        locationManager.stopUpdatingLocation()
        
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
        
        fetchWeather(latitude: currentLatitude, longitude: currentLongitude)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: any Error) {
        print(error.localizedDescription)
        isContentAvailable = false
        isDataReady = false
        self.dailyForecast = []
        self.handleError(errorMessage: "Could not fetch your location")
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
        default:
            isAuthorized = true
            startLocationServices()
        }
    }
    
}
