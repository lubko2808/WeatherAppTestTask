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

    private let apiClient = URLSessionAPIClient<CityEndpoint>()
    
    @Published var textFieldText = ""
    @Published var isLoadingData = false
    
    @Published var cityData: [CityModel.Data] = []
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        addTextFieldSubscriber()
    }
    
    private func addTextFieldSubscriber() {
        $textFieldText
            .map { text in
                self.cityData = []
                if text.isEmpty {
                    self.isLoadingData = false
                } else {
                    self.isLoadingData = true
                }
                return text
            }
            .debounce(for: .seconds(0.8), scheduler: DispatchQueue.main)
            .sink { [weak self] text in
                if !text.isEmpty {
                    self?.cityData = []
                    self?.fetchCities(beginnigView: text)
                }
            }
            .store(in: &cancellables)
    }
    
    func fetchCities(beginnigView prefix: String) {
        
        apiClient.request(.getCity(prefix: prefix))
            .sink { [weak self] completion in
                guard let self = self else { return }
                self.isLoadingData = false
                switch completion {
                case .finished: break
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                    self.isError = true
                }
            } receiveValue: { (cityModel: CityModel) in
                self.cityData = cityModel.data
            }
            .store(in: &cancellables)

    }
    
}
