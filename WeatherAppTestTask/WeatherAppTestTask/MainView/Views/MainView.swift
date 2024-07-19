//
//  ContentView.swift
//  WeatherAppTestTask
//
//  Created by Lubomyr Chorniak on 18.07.2024.
//

import SwiftUI

struct MainView: View {
    
    @StateObject private var viewModel = MainViewModel()
    
    @State private var chosenCity: String? = nil
    @State private var showCitySearchView = false
    
    var body: some View {
        
        NavigationStack() {
            
            ZStack {
                backgroundView
                    .ignoresSafeArea()
                
                ScrollView {
                    
                    VStack(spacing: 40) {
                            
                        HStack(alignment: .firstTextBaseline) {
                            currentTemp
                            dayAndNightTemp
                        }
                        .padding(.top, 30)
                        .animation(.linear(duration: 0.3), value: viewModel.isDataReady)
                        
                        ScrollView(.horizontal) {
                            HStack {
                                ForEach(0..<viewModel.hourlyTemp.count, id: \.self) { index in
                                    HourlyWeatherView(
                                        hour: viewModel.hours[index],
                                        weatherType: viewModel.hourlyWeatherTypes[index],
                                        tempterature: viewModel.hourlyTemp[index]
                                    )
                                }
                            }
                        }
                        .scrollClipDisabled()
                        .padding(.horizontal)
                        .opacity(viewModel.isDataReady ? 1 : 0)
                        .animation(.easeInOut(duration: 0.3), value: viewModel.isDataReady)
                        
                        VStack(spacing: 15) {
                            ForEach(0..<viewModel.dayAndNightTemp.count, id: \.self) { index in
                                WeatherForDayView(
                                    weatherType: viewModel.weatherTypes[index],
                                    day: viewModel.days[index],
                                    dayAndNightTemp: viewModel.dayAndNightTemp[index],
                                    sequenceNumber: index
                                )
                            }
                        }
                    }
                }
                .scrollIndicators(.never)
            }
            .overlay {
                if !viewModel.isContentAvailable {
                    contentUnavailableView
                }

            }
            .navigationBarTitleDisplayMode(.large)
            .navigationTitle(viewModel.currentCity)
            .navigationBarAppearance()
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        chosenCity = nil
                        showCitySearchView = true
                    } label: {
                        cityButton
                    }
                }
            }

            .alert("Error", isPresented: $viewModel.isError) {
                Button("OK", action: {})
            } message: {
                Text(viewModel.errorMessage ?? "")
            }
            
            .sheet(isPresented: $showCitySearchView) {
                if let chosenCity {
                    viewModel.currentCity = chosenCity
                    viewModel.fetchWeatherForCity(cityName: chosenCity)
                }
            } content: {
                CitySearchView(chosenCity: $chosenCity)
            }
        }
        
    }
    
    
    private var contentUnavailableView: some View {
        VStack {
            Text("Chose City")
                .font(.largeTitle.bold())
                .foregroundStyle(.gray)
            
            Image(.smileIcon)
                .resizable()
                .scaledToFit()
                .frame(width: 200, height: 200)
        }
    }
    
    private var cityButton: some View {
        Text("city")
            .foregroundColor(.black)
            .padding(.horizontal)
            .padding(.vertical, 6)
            .background(.white)
            .cornerRadius(25)
    }
    
    private var currentTemp: some View {
        Text(viewModel.currentTemp)
            .font(.system(size: 100, weight: .medium))
            .fontDesign(.rounded)
            .foregroundColor(.white)
            .opacity(viewModel.isDataReady ? 1 : 0)
            .scaleEffect(viewModel.isDataReady ? 1 : 2)
    }
    
    private var dayAndNightTemp: some View {
        Text(viewModel.dayAndNightTemp.isEmpty ? "" : viewModel.dayAndNightTemp[0])
            .font(.system(size: 25, weight: .medium))
            .fontDesign(.rounded)
            .foregroundColor(.white)
            .opacity(viewModel.isDataReady ? 1 : 0)
            .scaleEffect(viewModel.isDataReady ? 1 : 2)
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


