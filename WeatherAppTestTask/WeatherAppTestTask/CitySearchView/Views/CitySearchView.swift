//
//  CitySearchView.swift
//  WeatherAppTestTask
//
//  Created by Lubomyr Chorniak on 18.07.2024.
//

import SwiftUI

struct CitySearchView: View {
    
    @Binding var chosenCity: String

    @StateObject private var viewModel = CitySearchViewModel()
    
    @Environment(\.dismiss) var dismissView

    var body: some View {
        NavigationStack {
            ZStack {
                backgroundView
                
                VStack {
                    
                    ScrollView {
                        LazyVStack {
                            ForEach(0..<viewModel.cityData.count, id: \.self) { index in
                                CityListRowView(cityData: viewModel.cityData[index])
                                .onTapGesture {
                                    chosenCity = viewModel.cityData[index].city
                                    dismissView()
                                }
                                .padding(.vertical, 7)
        
                            }
                        }
                        .padding(.horizontal)
                    }
                    .clipped()
                    .ignoresSafeArea(.container, edges: .bottom)
                
                    .scrollIndicators(.never)
                    .overlay {
                        if viewModel.cityData.count == 0 && viewModel.isLoadingData == false {
                            Image(uiImage: UIImage(resource: .unavailable))
                                .resizable()
                                .scaledToFit()
                        }
                    }
                    .overlay {
                        if viewModel.isLoadingData {
                            ZStack {
                                Color.black.opacity(0.1)
                                    .ignoresSafeArea()
                                
                                ProgressView()
                            }
                        }
                    }
                }
            }
            .navigationTitle("Add city")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarAppearance(inlineFontSize: 25)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        dismissView()
                    } label: {
                        Text("cancel")
                            .foregroundColor(.white)
                            .font(.system(size: 22))
                    }
                }
            }
            .alert("Error", isPresented: $viewModel.isError) {
                Button("OK", action: {})
            } message: {
                Text(viewModel.errorMessage ?? "")
            }
        }
        .searchable(text: $viewModel.textFieldText, prompt: "enter the name of the city")
        
    }

    private var backgroundView: some View {
        LinearGradient(
            gradient: Gradient(colors: [.blue.opacity(0.6), Color.whiteBlue, .blue.opacity(0.6)]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing)
        .ignoresSafeArea()
    }
    
}

