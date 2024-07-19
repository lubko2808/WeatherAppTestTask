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
        static let rain = [45, 48, 51, 53, 55, 56, 57, 61, 63, 65, 66, 67, 80, 81, 82]
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
    
    private let dayDict = [0: "Sun", 1: "Mon", 2: "Tue", 3: "Wed", 4: "Thu", 5: "Fri", 6: "Sat"]
    private let degreeSing = "\u{00B0}"
    
    private func getDayAndNightTemp(daily: DailyWeatherModel.Daily) -> [String] {
        let maxTemp = daily.temperature2MMax
        let minTemp = daily.temperature2MMin
        let dayNadNightTemp = zip(maxTemp, minTemp).map { (max, min) in
            "\(max)/\(min)\(degreeSing)"
        }
        return dayNadNightTemp
    }

    private func getWeatherTypesDaily(weatherCodes: [Int]) -> [String] {
        weatherCodes.map { getWeatherType(weatherCode: $0) }
    }
    
    private func getWeatherType(weatherCode: Int) -> String {
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
    
    private func getHourlyTemp(hourlyTempModel: HourlyWeatherModel) -> [String] {
        let currentHour = Date().currentHour
        let hourlyTemps = hourlyTempModel.hourly.temperature2M
        return (0..<24).map { "\(hourlyTemps[currentHour + $0])\(degreeSing)" }
    }
    
    private func getWeatherCodesHourly(weatherCodes: [Int]) -> [String] {
        let currentHour = Date().currentHour
        return (0..<24).map { getWeatherType(weatherCode: weatherCodes[currentHour + $0]) }
    }
    
    private func get24HoursFromNow() -> [String] {
        
        let currentHour = Date().currentHour
        var hours: [String] = []
        for i in 0..<24 {
            let hour = (currentHour + i) % 24
            if hour == currentHour {
                hours.append("Now")
                continue
            }
            hours.append(String(format: "%02d", hour))
        }
        
        return hours
    }
    
    private func getDays() -> [String] {
        let currentDate = Date()
        let calendar = Calendar.current
        let currentDay = calendar.component(.weekday, from: currentDate) - 1
        let maxDaysForForecast = 16
        return (0..<maxDaysForForecast).compactMap { dayDict[ (currentDay + $0) % 7 ] }
    }
    
    func getHourlyForecast(hourlyWeather: HourlyWeatherModel) -> [HourForecaset] {
        let hours = get24HoursFromNow()
        let hourlyWeatherTypes = getWeatherTypesDaily(weatherCodes: hourlyWeather.hourly.weatherCode)
        let hourlyTemp = getHourlyTemp(hourlyTempModel: hourlyWeather)
        
        var hourlyForecast = [HourForecaset]()
        for index in 0..<hours.count {
            hourlyForecast.append(.init(hour: hours[index], weatherType: hourlyWeatherTypes[index], temp: hourlyTemp[index]))
        }
        
        return hourlyForecast
    }
    
    func getDailyForecast(dailyWeather: DailyWeatherModel) -> [DayForecast] {
        let dayAndNightTemp = getDayAndNightTemp(daily: dailyWeather.daily)
        let days = getDays()
        let weatherTypes = getWeatherTypesDaily(weatherCodes: dailyWeather.daily.weatherCode)
        
        var dailyForecast = [DayForecast]()
        for index in 0..<dayAndNightTemp.count {
            dailyForecast.append(.init(weatherType: weatherTypes[index], day: days[index], dayAndNightTemp: dayAndNightTemp[index]))
        }
        return dailyForecast
    }
    
}


extension Date {
    
    var currentHour: Int  {
        return Calendar.current.component(.hour, from: self)
    }
    
}
