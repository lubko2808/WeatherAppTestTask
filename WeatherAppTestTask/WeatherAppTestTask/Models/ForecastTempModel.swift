//
//  ForecastTempModel.swift
//  WeatherAppTestTask
//
//  Created by Lubomyr Chorniak on 18.07.2024.
//

import Foundation

struct ForecastTempModel: Decodable {
    let daily: Daily
    
    struct Daily: Decodable {
        
        let temperature2MMax: [Double]
        let temperature2MMin: [Double]
        
        enum CodingKeys: String, CodingKey {
            case temperature2MMax = "temperature_2m_max"
            case temperature2MMin = "temperature_2m_min"
        }
        
    }
}
