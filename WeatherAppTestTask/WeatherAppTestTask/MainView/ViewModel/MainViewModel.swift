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
    
    private let locationService = LocationService()
    
    override init() {
        super.init()

        $currentCity
            .dropFirst(2)
            .sink { city in
                self.fetchWeatherForCity(cityName: city)
            }
            .store(in: &cancellables)
    }
    
    func getLocation() {
        locationService.getUserLocation()
            .receive(on: DispatchQueue.main)
            .sink { completion in
                switch completion {
                case .finished: break
                case .failure(let error):
                    switch error {
                    case .authorizationDenied:
                        self.isContentAvailable = false
                        self.isDataReady = false
                        self.dailyForecast = []
                    case .couldNotFetchLocation:
                        self.showAlert(errorMessage: error.localizedDescription)
                    }
                }
            } receiveValue: { currentLocation in
                self.getCurrentCityFromLocation(currentLocation)
            }
            .store(in: &cancellables)
    }
    
    private func getCurrentCityFromLocation(_ currentLocation: CLLocation) {
        CLGeocoder().reverseGeocodeLocation(currentLocation, preferredLocale: Locale(identifier: "en")) { [weak self] (placemarks, error) in
            guard let self = self else { return }
            
            if error != nil {
                self.showAlert(errorMessage: "Can't obtain your current city")
                return
            }
            
            guard let city = placemarks?.first?.locality else {
                self.showAlert(errorMessage: "Can't obtain your current city")
                return
            }
            
            self.currentCity = city
        }
        
        let currentLatitude = currentLocation.coordinate.latitude
        let currentLongitude = currentLocation.coordinate.longitude
        
        self.fetchWeather(latitude: currentLatitude, longitude: currentLongitude)
    }
    
    private func showAlert(errorMessage: String) {
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
                self.showAlert(errorMessage: "Could not get information about this city")
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
                    self?.showAlert(errorMessage: error.localizedDescription)
                }
            } receiveValue: { [weak self] (dailyWeatherModel, hourlyWeatherModel) in
                self?.handleData(dailyWeather: dailyWeatherModel, hourlyWeather: hourlyWeatherModel)
            }
            .store(in: &cancellables)
    }
    
}

