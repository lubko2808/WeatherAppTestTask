//
//  APIClient.swift
//  WeatherAppTestTask
//
//  Created by Lubomyr Chorniak on 19.07.2024.
//

import Foundation
import Combine

class APIClient {
    
    private let jsonDecoder = JSONDecoder()
    
    enum Endpoint {
        case dailyWeather(latitude: Double, longitude: Double)
        case hourlyWeather(latitude: Double, longitude: Double)
        case city(prefix: String)
        
        var headers: [(key: String, value: String)]? {
            switch self {
            case .city:
                return [(key: "X-RapidAPI-Key", value: "9a79c4044dmsh8b389b0bc50c7d1p18e755jsn08c7c63170a8")]
            default: return nil
            }
        }
        
        var url: URL {
            var components = URLComponents()
            
            switch self {
            case .dailyWeather(let latitude, let longitude):
                components.scheme = "https"
                components.host = "api.open-meteo.com"
                components.path = "/v1/forecast"
                components.queryItems = [
                    URLQueryItem(name: "latitude", value: String(latitude)),
                    URLQueryItem(name: "longitude", value: String(longitude)),
                    URLQueryItem(name: "daily", value: "temperature_2m_max"),
                    URLQueryItem(name: "daily", value: "temperature_2m_min"),
                    URLQueryItem(name: "daily", value: "weathercode"),
                    URLQueryItem(name: "current_weather", value: "true"),
                    URLQueryItem(name: "forecast_days", value: "16")
                ]
            case .hourlyWeather(let latitude, let longitude):
                components.scheme = "https"
                components.host = "api.open-meteo.com"
                components.path = "/v1/forecast"
                components.queryItems = [
                    URLQueryItem(name: "latitude", value: String(latitude)),
                    URLQueryItem(name: "longitude", value: String(longitude)),
                    URLQueryItem(name: "hourly", value: "temperature_2m"),
                    URLQueryItem(name: "hourly", value: "weathercode"),
                    URLQueryItem(name: "forecast_days", value: "2")
                ]
            case .city(let prefix):
                components.scheme = "https"
                components.host = "wft-geo-db.p.rapidapi.com"
                components.path = "/v1/geo/cities"
                components.queryItems = [
                    URLQueryItem(name: "namePrefix", value: prefix),
                    URLQueryItem(name: "minPopulation", value: "50000"),
                    URLQueryItem(name: "limit", value: "10")
                ]
            }
            
            return components.url!
        }
    }
    
}

extension APIClient {
    
    func fetch<Response: Decodable>(_ endpoint: Endpoint) -> AnyPublisher<Response, Error>  {
        var urlRequest = URLRequest(url: endpoint.url)
        
        if let headers = endpoint.headers {
            for header in headers {
                urlRequest.addValue(header.value, forHTTPHeaderField: header.key)
            }
        }
        
        return URLSession.shared.dataTaskPublisher(for: urlRequest)
            .receive(on: DispatchQueue.main)
            .tryMap { (data, response) -> Data in
                guard let response = response as? HTTPURLResponse,
                        response.statusCode >= 200 && response.statusCode < 300 else {
                    throw URLError(.badServerResponse)
                }

                return data
            }
            .decode(type: Response.self, decoder: JSONDecoder())
            .eraseToAnyPublisher()
    }
}
