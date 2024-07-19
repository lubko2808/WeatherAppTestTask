//
//  HourlyWeatherView.swift
//  WeatherAppTestTask
//
//  Created by Lubomyr Chorniak on 19.07.2024.
//

import SwiftUI

struct HourlyWeatherView: View {
    
    var hour: String
    var weatherType: String
    var tempterature: String
    
    var body: some View {
        VStack(alignment: .center) {
            
            Text(hour)
                .foregroundStyle(.white)
                .font(.title3)
            
            WeatherTypeIconView(weatherType: weatherType)
            
            Text(tempterature)
                .foregroundStyle(.white)
                .font(.title3)
            
        }
        .frame(width: 70)
        .padding()
        .background(Color.blue.opacity(0.4))
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
    
}
