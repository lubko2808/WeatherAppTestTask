//
//  WeatherTypeIconView.swift
//  WeatherAppTestTask
//
//  Created by Lubomyr Chorniak on 19.07.2024.
//

import SwiftUI

struct WeatherTypeIconView: View {
    
    var weatherType: String
    
    var body: some View {
        Image(systemName:  weatherType)
            .resizable()
            .scaledToFit()
            .frame(width: 30, height: 30)
            .foregroundColor(.blue)
    }
    
}
