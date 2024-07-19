//
//  CityListRowView.swift
//  WeatherAppTestTask
//
//  Created by Lubomyr Chorniak on 19.07.2024.
//

import SwiftUI

struct CityListRowView: View {
    
    let city: String
    let country: String
    
    var body: some View {
        
        Rectangle()
            .foregroundColor(Color.yellow.opacity(0.8))
            .cornerRadius(20)
            .overlay(alignment: .leading) {
                
                VStack(alignment: .leading) {
                    
                    Text(city)
                        .font(.title)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                    
                    Text(country)
                        .font(.title2)
                        .foregroundColor(Color(uiColor: .lightText))
                }
                .padding(.horizontal)
                
            }
            .frame(height: 90)
    }
}
