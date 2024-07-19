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
                    cityTextField
                    
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
                    .scrollIndicators(.never)
                    .overlay {
                        if viewModel.cities.count == 0 && viewModel.isLoadingData == false {
                            Image(uiImage: UIImage(resource: .unavailable))
                                .resizable()
                                .scaledToFit()
                        }
                    }
                }
            }
            .disabled(isGesturesDisabled)
            .navigationTitle("Add city")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarAppearance(fontSize: 25)
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
        
    }

    
    private var cityTextField: some View {
        TextField(
            "",
            text: $viewModel.textFieldText,
            prompt: Text("enter the name of the city").foregroundStyle(.blue)
        )
            .foregroundColor(.white)
            .font(.title)
            .frame(height: 46)
            .padding(.horizontal)
            .padding(.vertical, 5)
            .overlay {
                RoundedRectangle(cornerRadius: 20)
                    .stroke(.white, lineWidth: 3)
            }
            .cornerRadius(20)
            .padding()
    }
    
    private var backgroundView: some View {
        LinearGradient(
            gradient: Gradient(colors: [.blue.opacity(0.6), Color.whiteBlue]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing)
        .ignoresSafeArea()
        
//        Color.teal
//            .opacity(0.8)
//            .ignoresSafeArea()
//            .blur(radius: 10)
    }
    
}

