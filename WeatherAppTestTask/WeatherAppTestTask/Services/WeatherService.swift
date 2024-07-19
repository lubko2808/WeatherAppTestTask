//
//  WeatherService.swift
//  WeatherAppTestTask
//
//  Created by Lubomyr Chorniak on 18.07.2024.
//

import Foundation
import Combine

final class WeatherService {
    
    private var components: URLComponents
    private let jsonDecoder = JSONDecoder()
    
    init() {
        components = URLComponents()
        components.scheme = "https"
        components.host = "api.open-meteo.com"
        components.path = "/v1/forecast"
    }

    func fetchDailyWeather(latitude: Double, longitude: Double) -> AnyPublisher<DailyWeatherModel, Error> {
        components.queryItems = [
            URLQueryItem(name: "latitude", value: String(latitude)),
            URLQueryItem(name: "longitude", value: String(longitude)),
            URLQueryItem(name: "daily", value: "temperature_2m_max"),
            URLQueryItem(name: "daily", value: "temperature_2m_min"),
            URLQueryItem(name: "daily", value: "weathercode"),
            URLQueryItem(name: "current_weather", value: "true"),
            URLQueryItem(name: "forecast_days", value: "16")
        ]
        
        guard let url = components.url else {
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }
    
        let urlRequest = URLRequest(url: url)

        return URLSession.shared.dataTaskPublisher(for: urlRequest)
            .receive(on: DispatchQueue.main)
            .transformResponseToError()
            .decode(type: DailyWeatherModel.self, decoder: jsonDecoder)
            .eraseToAnyPublisher()
    }
    
    func fetchHourlyWeather(latitude: Double, longitude: Double) -> AnyPublisher<HourlyWeatherModel, Error> {
        components.queryItems = [
            URLQueryItem(name: "latitude", value: String(latitude)),
            URLQueryItem(name: "longitude", value: String(longitude)),
            URLQueryItem(name: "hourly", value: "temperature_2m"),
            URLQueryItem(name: "hourly", value: "weathercode"),
            URLQueryItem(name: "forecast_days", value: "2")
        ]
        
        guard let url = components.url else {
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }
    
        let urlRequest = URLRequest(url: url)
        
        return URLSession.shared.dataTaskPublisher(for: urlRequest)
            .receive(on: DispatchQueue.main)
            .transformResponseToError()
            .decode(type: HourlyWeatherModel.self, decoder: jsonDecoder)
            .eraseToAnyPublisher()
    }
    
}

