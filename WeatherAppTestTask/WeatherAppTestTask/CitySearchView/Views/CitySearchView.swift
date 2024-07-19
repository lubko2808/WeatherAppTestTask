//
//  CitySearchView.swift
//  WeatherAppTestTask
//
//  Created by Lubomyr Chorniak on 18.07.2024.
//

import SwiftUI

struct CitySearchView: View {
    
    @Binding var chosenCity: String?

    @StateObject private var viewModel = CitySearchViewModel()
    
    @Environment(\.dismiss) var dismissView
    
    @State private var selectedRow: Int? = nil
    @State private var isGesturesDisabled = false

    var body: some View {
        NavigationStack {
            ZStack {
                backgroundView
                
                VStack {
                    
                    ScrollView {
                        LazyVStack {
                            ForEach(0..<viewModel.cities.count, id: \.self) { index in
                                CityListRowView(
                                    city: viewModel.cities[index],
                                    country: viewModel.countries[index]
                                )
                                
                                .scaleEffect(selectedRow == index ? 1.3 : 1)
                                .onTapGesture {
                                    isGesturesDisabled = true
                                    withAnimation(.easeIn(duration: 0.2)) {
                                        selectedRow = index
                                    }
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                        withAnimation(.easeIn(duration: 0.2)) {
                                            selectedRow = nil
                                        }
                                    }
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                                        chosenCity = viewModel.cities[index]
                                        dismissView()
                                    }
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
                        if viewModel.cities.count == 0 && viewModel.isLoadingData == false {
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
            .disabled(isGesturesDisabled)
            .navigationTitle("Add city")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarAppearance(inlineFontSize: 25)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        chosenCity = nil
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

