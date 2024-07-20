//
//  HourlyWeatherModel.swift
//  WeatherAppTestTask
//
//  Created by Lubomyr Chorniak on 19.07.2024.
//

import Foundation

struct HourlyWeatherModel: Decodable {
    
    let hourly: Hourly
    
    struct Hourly: Decodable {
        let temperature2M: [Double]
        let weatherCode: [Int]
        
        enum CodingKeys: String, CodingKey {
            case temperature2M = "temperature_2m"
            case weatherCode = "weathercode"
        }
    }
    
}
