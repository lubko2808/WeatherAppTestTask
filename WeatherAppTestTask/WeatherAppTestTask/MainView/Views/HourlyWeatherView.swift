//
//  HourlyWeatherView.swift
//  WeatherAppTestTask
//
//  Created by Lubomyr Chorniak on 19.07.2024.
//

import SwiftUI

struct HourlyWeatherView: View {

    let hourlyForecast: HourForecaset
    
    var body: some View {
        VStack(alignment: .center) {
            
            Text(hourlyForecast.hour)
                .foregroundStyle(.white)
                .font(.title3)
            
            WeatherTypeIconView(weatherType: hourlyForecast.weatherType)
            
            Text(hourlyForecast.temp)
                .foregroundStyle(.white)
                .font(.title3)
            
        }
        .frame(width: 70)
        .padding()
        .background(Color.blue.opacity(0.4))
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
    
}
