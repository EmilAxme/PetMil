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
    private let unsplashSearchService: UnsplashSearchServiceProtocol
    
    private var searchWorkItem: DispatchWorkItem?
    private var searchTask: Task<Void, Never>?
    private var selectedCityPhotoTask: Task<Void, Never>?

    private var filteredCities: [CitySearchModels.City] = []
    private var searchCache: [String: [CitySearchModels.City]] = [:]

    private let minQueryLength = 2
    private let debounceInterval: TimeInterval = 0.25
    
    init(
        storage: SelectedCityStorageProtocol,
        citySearchService: CitySearchServiceProtocol,
        unsplashSearchService: UnsplashSearchServiceProtocol
    ) {
        self.storage = storage
        self.citySearchService = citySearchService
        self.unsplashSearchService = unsplashSearchService
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
        DispatchQueue.main.asyncAfter(deadline: .now() + debounceInterval, execute: workItem)
    }
    
    func didSelectCity(at index: Int) {
        guard filteredCities.indices.contains(index) else { return }
        
        let city = filteredCities[index]
        
        storage.selectedCity = makeSelectedCity(from: city, photoURLString: nil)
        loadAndStorePhoto(for: city)
        
        view?.routeToWeatherScreen()
    }
}

private extension CitySearchPresenter {
    func applySearch(text: String) {
        let trimmedText = text.trimmingCharacters(in: .whitespacesAndNewlines)

        guard trimmedText.count >= minQueryLength else {
            view?.displayLoading(false)
            filteredCities = []
            view?.displayCities(.init(cities: []))
            return
        }

        let cacheKey = trimmedText.lowercased()
        if let cached = searchCache[cacheKey] {
            filteredCities = cached
            view?.displayCities(.init(cities: cached))
            return
        }

        view?.displayLoading(true)

        searchTask = Task { [weak self] in
            guard let self else { return }

            do {
                let cities = try await citySearchService.searchCities(query: trimmedText)
                self.filteredCities = cities
                self.searchCache[cacheKey] = cities

                await MainActor.run {
                    self.view?.displayLoading(false)
                    self.view?.displayCities(.init(cities: cities))
                }
            } catch is CancellationError {
                print("City search cancelled")
            } catch {
                print("City search error:", error.localizedDescription)

                await MainActor.run {
                    self.view?.displayLoading(false)
                    self.filteredCities = []
                    self.view?.displayCities(.init(cities: []))
                }
            }
        }
    }
    
    func makeSelectedCity(from city: CitySearchModels.City, photoURLString: String?) -> SelectedCity {
        SelectedCity(
            name: city.name,
            country: city.country,
            latitude: city.latitude,
            longitude: city.longitude,
            photoURLString: photoURLString
        )
    }
    
    func loadAndStorePhoto(for city: CitySearchModels.City) {
        selectedCityPhotoTask?.cancel()
        
        selectedCityPhotoTask = Task { [weak self] in
            guard let self else { return }
            
            do {
                let preview = try await unsplashSearchService.searchPhoto(for: city.name)
                let updatedCity = makeSelectedCity(
                    from: city,
                    photoURLString: preview?.imageURL.absoluteString
                )
                
                storage.selectedCity = updatedCity
            } catch is CancellationError {
                print("Selected city photo loading cancelled")
            } catch {
                print("Selected city photo loading error:", error.localizedDescription)
            }
        }
    }
}
