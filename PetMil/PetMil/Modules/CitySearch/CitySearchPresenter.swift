//
//  CitySearchPresenter.swift
//  PetMil
//
//  Created by Emil on 11.03.2026.
//

import Foundation

protocol CitySearchPresenterProtocol: AnyObject {
    func viewDidLoad()
    func didUpdateSearch(text: String)
    func didSelectCity(at index: Int)
}

final class CitySearchPresenter {
    
    weak var view: CitySearchViewProtocol?
    
    private let storage: SelectedCityStorageProtocol
    
    private var searchWorkItem: DispatchWorkItem?
    
    private let allCities: [CitySearchModels.City] = [
        .init(name: "Moscow", country: "Russia"),
        .init(name: "Saint Petersburg", country: "Russia"),
        .init(name: "Kazan", country: "Russia"),
        .init(name: "Novosibirsk", country: "Russia"),
        .init(name: "Yekaterinburg", country: "Russia"),
        .init(name: "London", country: "United Kingdom"),
        .init(name: "Paris", country: "France"),
        .init(name: "Berlin", country: "Germany"),
        .init(name: "Rome", country: "Italy"),
        .init(name: "New York", country: "United States"),
        .init(name: "Tokyo", country: "Japan")
    ]
    
    private var filteredCities: [CitySearchModels.City] = []
    
    init(storage: SelectedCityStorageProtocol) {
        self.storage = storage
    }
}

extension CitySearchPresenter: CitySearchPresenterProtocol {
    func viewDidLoad() {
        filteredCities = allCities
        updateView()
    }
    
    func didUpdateSearch(text: String) {
        searchWorkItem?.cancel()
        
        let workItem = DispatchWorkItem { [weak self] in
            guard let self else { return }
            
            let trimmedText = text.trimmingCharacters(in: .whitespacesAndNewlines)
            
            if trimmedText.isEmpty {
                self.filteredCities = self.allCities
            } else {
                self.filteredCities = self.allCities.filter {
                    $0.name.localizedCaseInsensitiveContains(trimmedText) ||
                    $0.country.localizedCaseInsensitiveContains(trimmedText)
                }
            }
            
            self.updateView()
        }
        
        searchWorkItem = workItem
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35, execute: workItem)
    }
    
    func didSelectCity(at index: Int) {
        guard filteredCities.indices.contains(index) else { return }
        
        let city = filteredCities[index]
        storage.selectedCity = city.name
        view?.displaySelectedCity(city.name)
    }
}

private extension CitySearchPresenter {
    func updateView() {
        let viewModel = CitySearchModels.ViewModel(
            title: "Search City",
            cities: filteredCities
        )
        view?.displayCities(viewModel)
    }
}
