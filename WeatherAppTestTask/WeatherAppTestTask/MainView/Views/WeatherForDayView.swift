//
//  WeatherForDay.swift
//  WeatherAppTestTask
//
//  Created by Lubomyr Chorniak on 18.07.2024.
//

import SwiftUI

struct WeatherForDayView: View {

    var dailyForecast: DayForecast
    
    var sequenceNumber: Int
    @State private var startAnimation = false
    @State private var offset: CGFloat = -500
    
    var body: some View {
        HStack {
            WeatherTypeIconView(weatherType: dailyForecast.weatherType)
            
            Text(dailyForecast.day)
                .font(.system(.title))
                .foregroundColor(.white)
                .padding(.leading, 7)
            
            Spacer()
            
            Text(dailyForecast.dayAndNightTemp)
                .font(.system(.body))
                .foregroundColor(.gray)
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(Color.white.opacity(0.5))
        .cornerRadius(20)
        .padding(.horizontal)
        .offset(x: offset)
        .animation(.spring(response: 0.8, dampingFraction: 0.6, blendDuration: 0).delay(Double(sequenceNumber) * 0.05), value: offset)
        .onAppear {
            offset = 0
        }
    }
    
}

