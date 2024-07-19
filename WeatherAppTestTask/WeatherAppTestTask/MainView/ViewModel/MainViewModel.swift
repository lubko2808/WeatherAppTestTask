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
    
    @Published var hours: [String] = []
    @Published var hourlyWeatherTypes: [String] = []
    @Published var hourlyTemp: [String] = []
    
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
    }

    
    private func handleData(dailyWeather: DailyWeatherModel, hourlyWeather: HourlyWeatherModel) {
        let dayAndNightTemp = weatherDataFormatter.getDayAndNightTemp(daily: dailyWeather.daily)
        let currentTemp = String(dailyWeather.currentWeather.temperature)
        let days = weatherDataFormatter.getDays()
        let weatherTypes = weatherDataFormatter.getWeatherTypesDaily(weatherCodes: dailyWeather.daily.weatherCode)
        
        let hours = weatherDataFormatter.get24HoursFromNow()
        let hourlyWeatherTypes = weatherDataFormatter.getWeatherTypesDaily(weatherCodes: hourlyWeather.hourly.weatherCode)
        let hourlyTemp = weatherDataFormatter.getHourlyTemp(hourlyTempModel: hourlyWeather)
        
        self.hours = hours
        self.hourlyWeatherTypes = hourlyWeatherTypes
        self.hourlyTemp = hourlyTemp
        self.dayAndNightTemp = dayAndNightTemp
        self.currentTemp = currentTemp
        self.days = days
        self.weatherTypes = weatherTypes

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            self.isDataReady = true
        }
    }

    private func geocoder(city: String, completion: @escaping(Double, Double) -> Void) {
        let geocoder = CLGeocoder()
        
        var latitude: Double = 0
        var longitude: Double = 0
        
        geocoder.geocodeAddressString(city, completionHandler: { [weak self] (placemarks, error) in
            guard let self = self else { return }
            
            if let error {
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
            
            self.weatherService.fetchDailyWeather(latitude: latitude, longitude: longitude)
                .zip(weatherService.fetchHourlyWeather(latitude: latitude, longitude: longitude))
                .sink { completion in
                    switch completion {
                    case .finished:
                        print("finished")
                    case .failure(let error):
                        self.handleError(errorMessage: error.localizedDescription)
                    }
                } receiveValue: { (dailyWeahterModel, hourlyWeatherModel) in
                    self.handleData(dailyWeather: dailyWeahterModel, hourlyWeather: hourlyWeatherModel)
                }
                .store(in: &cancellables)

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
        
        weatherService.fetchDailyWeather(latitude: currentLatitude, longitude: currentLongitude)
            .zip(weatherService.fetchHourlyWeather(latitude: currentLatitude, longitude: currentLongitude))
            .sink { [weak self] completion in
                switch completion {
                case .finished:
                    print("finished")
                case .failure(let error):
                    self?.handleError(errorMessage: error.localizedDescription)
                }
            } receiveValue: { [weak self] (dailyWeatherModel, hourlyWeatherModel) in
                self?.handleData(dailyWeather: dailyWeatherModel, hourlyWeather: hourlyWeatherModel)
            }
            .store(in: &cancellables)
        
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: any Error) {
        print("didFailWithError")
        self.handleError(errorMessage: "Location update failed: \(error.localizedDescription)")
    }
    
    
}
