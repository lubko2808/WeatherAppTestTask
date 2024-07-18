//
//  WeatherDataFormatter.swift
//  WeatherAppTestTask
//
//  Created by Lubomyr Chorniak on 18.07.2024.
//

import Foundation

struct WeatherDataFormatter {
    
    enum WeatherInterpretCodes {
        static let sunny = [0, 1]
        static let partlyCloudy = [2]
        static let cloudy = [3]
        static let rain = [51, 53, 55, 56, 57, 61, 63, 65, 66, 67, 80, 81, 82]
        static let snow = [71, 73, 75, 77, 85, 86]
        static let thunderstorm = [95, 96, 99]
    }
    
    enum WeatherIcon: String {
        case sunny = "sun.max.fill"
        case partlyCloudy = "cloud.sun.fill"
        case cloudy = "cloud.fill"
        case rain = "cloud.rain.fill"
        case snow = "cloud.snow.fill"
        case thunderstorm = "cloud.bolt.rain.fill"
        case unknown = "xmark"
    }
    
    private let degreeSing = "\u{00B0}"
    
    func getDayAndNightTemp(forecastTempModel: ForecastTempModel) -> [String] {
        let maxTemp = forecastTempModel.daily.temperature2MMax
        let minTemp = forecastTempModel.daily.temperature2MMin
        let dayNadNightTemp = zip(maxTemp, minTemp).map { (max, min) in
            "\(max)/\(min)\(degreeSing)"
        }
        return dayNadNightTemp
    }
    
    func getWeatherTypes(weatherCodes: [Int]) -> [String] {
        
        let weatherIcons = weatherCodes.map { weatherCode in
            switch weatherCode {
            case let code where WeatherInterpretCodes.sunny.contains { $0 == code }: return WeatherIcon.sunny.rawValue
            case let code where WeatherInterpretCodes.partlyCloudy.contains { $0 == code }: return WeatherIcon.partlyCloudy.rawValue
            case let code where WeatherInterpretCodes.cloudy.contains { $0 == code }: return WeatherIcon.cloudy.rawValue
            case let code where WeatherInterpretCodes.rain.contains { $0 == code }: return WeatherIcon.rain.rawValue
            case let code where WeatherInterpretCodes.snow.contains { $0 == code }: return WeatherIcon.snow.rawValue
            case let code where WeatherInterpretCodes.thunderstorm.contains { $0 == code }: return WeatherIcon.thunderstorm.rawValue
            default: return WeatherIcon.unknown.rawValue
            }
        }
        
        return weatherIcons
    }
    
    func getDays() -> [String] {
        let dayDict = [0: "Sun", 1: "Mon", 2: "Tue", 3: "Wed", 4: "Thu", 5: "Fri", 6: "Sat"]
        let currentDate = Date()
        let calendar = Calendar.current
        let currentDay = calendar.component(.weekday, from: currentDate) - 1
        
        return (0..<16).compactMap { dayDict[ (currentDay + $0) % 7 ] }
    }
    
}
