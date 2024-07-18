//
//  CitiesService.swift
//  WeatherAppTestTask
//
//  Created by Lubomyr Chorniak on 18.07.2024.
//

import Foundation
import Combine

final class CitiesService {
    
    private var components: URLComponents
    private let jsonDecoder = JSONDecoder()
    
    private let header = (key: "X-RapidAPI-Key", value: "9a79c4044dmsh8b389b0bc50c7d1p18e755jsn08c7c63170a8")

    init() {
        components = URLComponents()
        components.scheme = "https"
        components.host = "wft-geo-db.p.rapidapi.com"
        components.path = "/v1/geo/cities"
        components.queryItems = [
            URLQueryItem(name: "minPopulation", value: "50000"),
            URLQueryItem(name: "limit", value: "10"),
            URLQueryItem(name: "namePrefix", value: nil)
        ]
        
    }
    
    func fetchCities(prefix: String) -> AnyPublisher<CityModel, Error> {
        components.queryItems?[2] = URLQueryItem(name: "namePrefix", value: prefix)
        
        guard let url = components.url else {
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.addValue(header.value, forHTTPHeaderField: header.key)
        
        return URLSession.shared.dataTaskPublisher(for: urlRequest)
            .receive(on: DispatchQueue.main)
            .transformResponseToError()
            .decode(type: CityModel.self, decoder: jsonDecoder)
            .eraseToAnyPublisher()
    }
    
    
}
