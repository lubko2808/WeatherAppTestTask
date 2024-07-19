//
//  CitySearchViewModel.swift
//  WeatherAppTestTask
//
//  Created by Lubomyr Chorniak on 18.07.2024.
//

import Foundation
import Combine

final class CitySearchViewModel: ObservableObject {
    
    private(set) var errorMessage: String? = nil
    @Published var isError = false
    
    private let citiesService = CitiesService()
    
    @Published var textFieldText = ""
    @Published var isLoadingData = false
    @Published var cities: [String] = []
    @Published var countries: [String] = []
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        addTextFieldSubscriber()
    }
    
    private func addTextFieldSubscriber() {
        $textFieldText
            .map { text in
                if text.isEmpty {
                    self.cities = []
                }
                return text
            }
            .debounce(for: .seconds(0.8), scheduler: DispatchQueue.main)
            .sink { [weak self] text in
                if !text.isEmpty {
                    self?.cities = []
                    self?.isLoadingData = true
                    self?.fetchCities(beginnigView: text)
                }
            }
            .store(in: &cancellables)
            
    }
    
    
    func fetchCities(beginnigView prefix: String) {
        citiesService.fetchCities(prefix: prefix)
            .sink { [weak self] completion in
                guard let self = self else { return }
                self.isLoadingData = false
                switch completion {
                case .finished:
                    print("finished")
                case .failure(let error):
                    print("failure")
                    self.errorMessage = error.localizedDescription
                    self.isError.toggle()
                }
            } receiveValue: { cityModel in
                self.handleData(cityModel: cityModel)
            }
            .store(in: &cancellables)

    }
    
    private func handleData(cityModel: CityModel) {
        var tempCities: [String] = []
        var tempCountries: [String] = []
        for cityData in cityModel.data {
            tempCities.append(cityData.city)
            tempCountries.append(cityData.country)
        }
        
        if cities.isEmpty && tempCities.isEmpty { return }
        
        cities = tempCities
        countries = tempCountries
        
    }
    
    
}
