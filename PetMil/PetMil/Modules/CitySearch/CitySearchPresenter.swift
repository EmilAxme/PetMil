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
    private let citySearchService: CitySearchServiceProtocol
    
    private var searchWorkItem: DispatchWorkItem?
    private var searchTask: Task<Void, Never>?
    
    private var filteredCities: [CitySearchModels.City] = []
    
    init(
        storage: SelectedCityStorageProtocol,
        citySearchService: CitySearchServiceProtocol
    ) {
        self.storage = storage
        self.citySearchService = citySearchService
    }
}

extension CitySearchPresenter: CitySearchPresenterProtocol {
    func viewDidLoad() {
        view?.displayCities(.init(cities: []))
    }
    
    func didUpdateSearch(text: String) {
        searchWorkItem?.cancel()
        searchTask?.cancel()
        
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
        storage.selectedCity = SelectedCity(
            name: city.name,
            country: city.country,
            latitude: city.latitude,
            longitude: city.longitude
        )
        
        view?.routeToWeatherScreen()
    }
}

private extension CitySearchPresenter {
    func applySearch(text: String) {
        let trimmedText = text.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !trimmedText.isEmpty else {
            filteredCities = []
            view?.displayCities(.init(cities: []))
            return
        }
        
        searchTask = Task { [weak self] in
            guard let self else { return }
            
            do {
                let cities = try await citySearchService.searchCities(query: trimmedText)
                self.filteredCities = cities
                
                await MainActor.run {
                    self.view?.displayCities(.init(cities: cities))
                }
            } catch is CancellationError {
                print("City search cancelled")
            } catch {
                print("City search error:", error.localizedDescription)
                
                await MainActor.run {
                    self.filteredCities = []
                    self.view?.displayCities(.init(cities: []))
                }
            }
        }
    }
}
