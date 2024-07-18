//
//  CurrentTempModel.swift
//  WeatherAppTestTask
//
//  Created by Lubomyr Chorniak on 18.07.2024.
//

import Foundation

struct CurrentTempModel: Decodable {
    
    let currentWeather: CurrentWeather
    
    enum CodingKeys: String, CodingKey {
        case currentWeather = "current_weather"
    }
    
    struct CurrentWeather: Decodable {
        let temperature: Double
    }
    
}
