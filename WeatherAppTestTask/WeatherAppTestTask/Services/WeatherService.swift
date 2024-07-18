//
//  WeatherService.swift
//  WeatherAppTestTask
//
//  Created by Lubomyr Chorniak on 18.07.2024.
//

import Foundation
import Combine

class WeatherService {
    
    private let header = (key: "X-RapidAPI-Key", value: "9a79c4044dmsh8b389b0bc50c7d1p18e755jsn08c7c63170a8")
    private var components: URLComponents
    private let jsonDecoder = JSONDecoder()
    
    init() {
        components = URLComponents()
        components.scheme = "https"
        components.host = "api.open-meteo.com"
        components.path = "/v1/forecast"
    }

    
    func fetchCurrentTemp(latitude: Double, longitude: Double) -> AnyPublisher<CurrentTempModel, Error> {
        components.queryItems = [
            URLQueryItem(name: "latitude", value: String(latitude)),
            URLQueryItem(name: "longitude", value: String(longitude)),
            URLQueryItem(name: "current_weather", value: "true"),
        ]
        
        guard let url = components.url else {
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.addValue(header.value, forHTTPHeaderField: header.key)
        return URLSession.shared.dataTaskPublisher(for: urlRequest)
            .receive(on: DispatchQueue.main)
            .transformResponseToError()
            .decode(type: CurrentTempModel.self, decoder: jsonDecoder)
            .eraseToAnyPublisher()
    }
    
    func fetchForecastTemp(latitude: Double, longitude: Double) -> AnyPublisher<ForecastTempModel, Error> {
        components.queryItems = [
            URLQueryItem(name: "latitude", value: String(latitude)),
            URLQueryItem(name: "longitude", value: String(longitude)),
            URLQueryItem(name: "daily", value: "temperature_2m_max"),
            URLQueryItem(name: "daily", value: "temperature_2m_min"),
            URLQueryItem(name: "daily", value: "weathercode"),
            URLQueryItem(name: "forecast_days", value: "16")
        ]
        
        guard let url = components.url else {
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }
    
        var urlRequest = URLRequest(url: url)
        urlRequest.addValue(header.value, forHTTPHeaderField: header.key)
            
        print(urlRequest.url?.absoluteString)
        
        return URLSession.shared.dataTaskPublisher(for: urlRequest)
            .receive(on: DispatchQueue.main)
            .transformResponseToError()
            .decode(type: ForecastTempModel.self, decoder: jsonDecoder)
            .eraseToAnyPublisher()
    }
    
}

