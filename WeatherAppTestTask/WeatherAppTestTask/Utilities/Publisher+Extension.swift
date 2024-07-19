//
//  Publisher+Extension.swift
//  WeatherAppTestTask
//
//  Created by Lubomyr Chorniak on 18.07.2024.
//

import Combine
import Foundation

extension Publisher where Output == (data: Data, response: URLResponse) {
    
    func transformResponseToError() -> AnyPublisher<Data, Error> {
        self
            .tryMap { (data, response) -> Data in
                guard let response = response as? HTTPURLResponse,
                      response.statusCode >= 200 && response.statusCode < 300 else {
                    throw URLError(.badServerResponse)
                }
                return data
            }
            .eraseToAnyPublisher()
    }
}
