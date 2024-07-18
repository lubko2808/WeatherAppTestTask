//
//  WeatherForDay.swift
//  WeatherAppTestTask
//
//  Created by Lubomyr Chorniak on 18.07.2024.
//

import SwiftUI

struct WeatherForDay: View {

    var weatherType: String
    var day: String
    var dayAndNightTemp: String
    
    var body: some View {
        HStack {
            Image(systemName:  weatherType)
                .resizable()
                .scaledToFit()
                .frame(width: 30, height: 30)
                .foregroundColor(.blue)
            
            Text(day)
                .font(.system(.title))
                .foregroundColor(.white)
                .padding(.leading, 7)
            
            Spacer()
            
            Text(dayAndNightTemp)
                .font(.system(.body))
                .foregroundColor(.gray)
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(Color.white.opacity(0.5))
        .cornerRadius(20)
        .padding(.horizontal)
//        .offset(x: offset)
//        .animation(.spring(response: 0.8, dampingFraction: 0.6, blendDuration: 0).delay(Double(sequenceNumber) * 0.05), value: offset)
//        .onAppear {
//            offset = 0
//            print("WeatherForDay has appeared")
//        }
//        .onDisappear {
//            offset = -500
//            print("WeatherForDay has disappeared")
//        }
    }
    
}
