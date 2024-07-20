//
//  APIClient.swift
//  WeatherAppTestTask
//
//  Created by Lubomyr Chorniak on 19.07.2024.
//

import Foundation
import Combine

protocol APIEndpoint {
    var url: URL { get }
    var headers: [(key: String, value: String)]? { get }
}

extension APIEndpoint {
    var headers: [(key: String, value: String)]? {
        return nil
    }
}


class URLSessionAPIClient<EndpointType: APIEndpoint> {
    func request<T: Decodable>(_ endpoint: EndpointType) -> AnyPublisher<T, Error> {
        var urlRequest = URLRequest(url: endpoint.url)

        endpoint.headers?.forEach { urlRequest.addValue($0.value, forHTTPHeaderField: $0.key) }
        
        return URLSession.shared.dataTaskPublisher(for: urlRequest)
            .subscribe(on: DispatchQueue.global(qos: .background))
            .receive(on: DispatchQueue.main)
            .tryMap { data, response -> Data in
                guard let response = response as? HTTPURLResponse,
                        response.statusCode >= 200 && response.statusCode < 300 else {
                    throw URLError(.badServerResponse)
                }
                return data
            }
            .decode(type: T.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
}

enum WeatherEndpoint: APIEndpoint {
    
    case getDailyWeather(latitude: Double, longitude: Double)
    case getHourlyWeather(latitude: Double, longitude: Double)

    var url: URL {
        var components = URLComponents()
        
        components.scheme = "https"
        components.host = "api.open-meteo.com"
        components.path = "/v1/forecast"
        
        
        
        switch self {
        case .getDailyWeather(let latitude, let longitude):
            components.queryItems = [
                URLQueryItem(name: "latitude", value: String(latitude)),
                URLQueryItem(name: "longitude", value: String(longitude)),
                URLQueryItem(name: "daily", value: "temperature_2m_max"),
                URLQueryItem(name: "daily", value: "temperature_2m_min"),
                URLQueryItem(name: "daily", value: "weathercode"),
                URLQueryItem(name: "current_weather", value: "true"),
                URLQueryItem(name: "forecast_days", value: "16")
            ]
        case .getHourlyWeather(let latitude, let longitude):
            components.queryItems = [
                URLQueryItem(name: "latitude", value: String(latitude)),
                URLQueryItem(name: "longitude", value: String(longitude)),
                URLQueryItem(name: "hourly", value: "temperature_2m"),
                URLQueryItem(name: "hourly", value: "weathercode"),
                URLQueryItem(name: "forecast_days", value: "2")
            ]
        }
        
        return components.url!
    }
    
}

enum CityEndpoint: APIEndpoint {
    
    case getCity(prefix: String)
    
    var url: URL {
        var components = URLComponents()
        
        components.scheme = "https"
        components.host = "wft-geo-db.p.rapidapi.com"
        components.path = "/v1/geo/cities"
        
        switch self {
        case .getCity(let prefix):
            components.queryItems = [
                URLQueryItem(name: "namePrefix", value: prefix),
                URLQueryItem(name: "minPopulation", value: "50000"),
                URLQueryItem(name: "limit", value: "10")
            ]
        }
        
        return components.url!
    }
    
    var headers: [(key: String, value: String)]? {
            return [(key: "X-RapidAPI-Key", value: "9a79c4044dmsh8b389b0bc50c7d1p18e755jsn08c7c63170a8")]
    }
    
}

