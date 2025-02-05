//
//  HourlyTempModel.swift
//  WeatherAppTestTask
//
//  Created by Lubomyr Chorniak on 19.07.2024.
//

import Foundation

struct DailyWeatherModel: Decodable {

    let currentWeather: CurrentWeather
    let daily: Daily
    
    enum CodingKeys: String, CodingKey {
        case daily
        case currentWeather = "current_weather"
    }

    struct Daily: Decodable {
        
        let temperature2MMax: [Double]
        let temperature2MMin: [Double]
        let weatherCode: [Int]
        
        enum CodingKeys: String, CodingKey {
            case temperature2MMax = "temperature_2m_max"
            case temperature2MMin = "temperature_2m_min"
            case weatherCode = "weathercode"
        }
        
    }
    
    struct CurrentWeather: Decodable {
        let temperature: Double
    }
}
