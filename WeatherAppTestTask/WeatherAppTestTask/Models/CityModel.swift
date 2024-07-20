//
//  CityModel.swift
//  WeatherAppTestTask
//
//  Created by Lubomyr Chorniak on 18.07.2024.
//

import Foundation

struct CityModel: Decodable {
    let data: [Data]
    
    struct Data: Decodable {
        let city: String
        let country: String
    }
}
