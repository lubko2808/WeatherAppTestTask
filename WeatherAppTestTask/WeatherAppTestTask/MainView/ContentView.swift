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
            Color.red
                .ignoresSafeArea()
                .navigationBarTitleDisplayMode(.large)
                .navigationTitle(viewModel.currentCity)
            
                .alert("Error", isPresented: $viewModel.isError) {
                    Button("OK", action: {})
                } message: {
                    Text(viewModel.errorMessage ?? "")
                }

        }
        
    }
}

#Preview {
    MainView()
}
