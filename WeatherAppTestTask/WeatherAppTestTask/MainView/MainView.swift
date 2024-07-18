//
//  ContentView.swift
//  WeatherAppTestTask
//
//  Created by Lubomyr Chorniak on 18.07.2024.
//

import SwiftUI

struct MainView: View {
    
    @StateObject private var viewModel = MainViewModel()
    
    @State private var path = NavigationPath()
    
    var body: some View {
        
        NavigationStack(path: $path) {
            
            ZStack {
                backgroundView
                    .ignoresSafeArea()
                
                ScrollView {
                    
                    VStack(spacing: 60) {
 
                        HStack(alignment: .firstTextBaseline) {
                            currentTemp
                            dayAndNightTemp
                        }
                        
                        VStack(spacing: 15) {
                            ForEach(0..<viewModel.dayAndNightTemp.count, id: \.self) { index in
                                WeatherForDay(weatherType: viewModel.weatherTypes[index], day: viewModel.days[index], dayAndNightTemp: viewModel.dayAndNightTemp[index])
                            }
                        }
                    }
                }
            }
            .navigationBarTitleDisplayMode(.large)
            .navigationTitle(viewModel.currentCity)
            .toolbarBackground(.hidden)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    NavigationLink(value: "CitySearchView") {
                        cityButton
                    }
                }
            }

            .alert("Error", isPresented: $viewModel.isError) {
                Button("OK", action: {})
            } message: {
                Text(viewModel.errorMessage ?? "")
            }
            
            .navigationDestination(for: String.self) { _ in
                
                CitySearchView()
                
            }

        }
        
    }
    
    var cityButton: some View {
        Text("city")
            .foregroundColor(.black)
            .padding(.horizontal)
            .padding(.vertical, 6)
            .background(.white)
            .cornerRadius(25)
    }
    
    var currentTemp: some View {
        Text(viewModel.currentTemp)
            .font(.system(size: 100, weight: .medium))
            .fontDesign(.rounded)
            .foregroundColor(.white)
    }
    
    var dayAndNightTemp: some View {
        Text(viewModel.dayAndNightTemp.isEmpty ? "" : viewModel.dayAndNightTemp[0])
            .font(.system(size: 25, weight: .medium))
            .fontDesign(.rounded)
            .foregroundColor(.white)
    }
    
    private var backgroundView: some View {
        LinearGradient(
            gradient: Gradient(colors: [.blue.opacity(0.6), Color.whiteBlue]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing)
    }

    
}



#Preview {
    MainView()
}

extension Color {
    
    static let myColor = Color.white
    
}
