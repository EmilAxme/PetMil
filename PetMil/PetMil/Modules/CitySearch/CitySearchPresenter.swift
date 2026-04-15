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
            self.applySearch(text: text)
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
            cities: filteredCities
        )
        view?.displayCities(viewModel)
    }
    
    func applySearch(text: String) {
        let trimmedText = text.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if trimmedText.isEmpty {
            filteredCities = allCities
        } else {
            filteredCities = allCities.filter {
                $0.name.localizedCaseInsensitiveContains(trimmedText) ||
                $0.country.localizedCaseInsensitiveContains(trimmedText)
            }
        }
        
        updateView()
    }
}
