//
//  CitySearchPresenter.swift
//  PetMil
//
//  Created by Emil on 11.03.2026.
//

import Foundation

protocol CitySearchPresenterProtocol: AnyObject {
    func viewDidLoad()
    func viewWillAppear()
    func didUpdateSearch(text: String)
    func didSelectCity(at index: Int)
    func didSelectSavedCity(at index: Int)
    func didDeleteSavedCity(at index: Int)
    func didTapCurrentLocation()
}

final class CitySearchPresenter {

    weak var view: CitySearchViewProtocol?

    private let cityListStorage: CityListStorageProtocol
    private let citySearchService: CitySearchServiceProtocol
    private let unsplashSearchService: UnsplashSearchServiceProtocol
    private let locationService: LocationServiceProtocol
    private let weatherService: WeatherServiceProtocol

    private var searchWorkItem: DispatchWorkItem?
    private var searchTask: Task<Void, Never>?
    private var selectedCityPhotoTask: Task<Void, Never>?
    private var currentLocationTask: Task<Void, Never>?

    private var filteredCities: [CitySearchModels.City] = []
    private var searchCache: [String: [CitySearchModels.City]] = [:]

    private let minQueryLength = 2
    private let debounceInterval: TimeInterval = 0.25

    init(
        cityListStorage: CityListStorageProtocol,
        citySearchService: CitySearchServiceProtocol,
        unsplashSearchService: UnsplashSearchServiceProtocol,
        locationService: LocationServiceProtocol,
        weatherService: WeatherServiceProtocol
    ) {
        self.cityListStorage = cityListStorage
        self.citySearchService = citySearchService
        self.unsplashSearchService = unsplashSearchService
        self.locationService = locationService
        self.weatherService = weatherService
    }
}

extension CitySearchPresenter: CitySearchPresenterProtocol {
    func viewDidLoad() {
        displayCurrentList(searchText: "")
    }

    func viewWillAppear() {
        displayCurrentList(searchText: "")
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
        let selected = makeSelectedCity(from: city, photoURLString: nil)
        cityListStorage.appendCity(selected)
        loadAndStorePhoto(for: city)

        view?.routeToWeatherScreen()
    }

    func didSelectSavedCity(at index: Int) {
        guard cityListStorage.cities.indices.contains(index) else { return }
        cityListStorage.activeIndex = index
        view?.routeToWeatherScreen()
    }

    func didDeleteSavedCity(at index: Int) {
        guard cityListStorage.cities.indices.contains(index) else { return }
        cityListStorage.removeCity(at: index)
        displayCurrentList(searchText: "")
    }

    func didTapCurrentLocation() {
        currentLocationTask?.cancel()
        view?.displayLocationLoading(true)

        currentLocationTask = Task { [weak self] in
            guard let self else { return }
            do {
                let coordinate = try await locationService.requestCurrentLocation()
                let location = try await weatherService.reverseGeocode(
                    lat: coordinate.latitude,
                    lon: coordinate.longitude
                )

                try Task.checkCancellation()

                let currentLocationCity = SelectedCity(
                    name: location.name,
                    country: location.country,
                    latitude: location.latitude,
                    longitude: location.longitude,
                    photoURLString: nil,
                    isCurrentLocation: true
                )

                cityListStorage.upsertCurrentLocation(currentLocationCity)
                loadAndStorePhoto(forCurrentLocation: currentLocationCity)

                await MainActor.run {
                    self.view?.displayLocationLoading(false)
                    self.view?.routeToWeatherScreen()
                }
            } catch is CancellationError {
                print("Current location task cancelled")
            } catch LocationError.permissionDenied {
                await MainActor.run {
                    self.view?.displayLocationLoading(false)
                    self.view?.displayLocationError(L10n.shared.locationAccessDenied)
                }
            } catch {
                print("Current location error:", error.localizedDescription)
                await MainActor.run {
                    self.view?.displayLocationLoading(false)
                    self.view?.displayLocationError(L10n.shared.locationFailed)
                }
            }
        }
    }
}

private extension CitySearchPresenter {
    func applySearch(text: String) {
        let trimmedText = text.trimmingCharacters(in: .whitespacesAndNewlines)

        guard trimmedText.count >= minQueryLength else {
            view?.displayLoading(false)
            filteredCities = []
            displayCurrentList(searchText: trimmedText)
            return
        }

        let cacheKey = trimmedText.lowercased()
        if let cached = searchCache[cacheKey] {
            filteredCities = cached
            view?.displayList(.searchResults(cached))
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
                    self.view?.displayList(.searchResults(cities))
                }
            } catch is CancellationError {
                print("City search cancelled")
            } catch {
                print("City search error:", error.localizedDescription)

                await MainActor.run {
                    self.view?.displayLoading(false)
                    self.filteredCities = []
                    self.view?.displayList(.empty(message: L10n.shared.nothingFound))
                }
            }
        }
    }

    func displayCurrentList(searchText: String) {
        let trimmed = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmed.isEmpty else {
            view?.displayList(.searchResults(filteredCities))
            return
        }

        let savedRows = cityListStorage.cities.map { city -> CitySearchModels.SavedRow in
            let location: String
            if city.country.isEmpty {
                location = city.isCurrentLocation ? L10n.shared.locationUsageDescription : ""
            } else {
                location = city.country
            }
            return CitySearchModels.SavedRow(
                name: city.name,
                countryOrLocation: location,
                isCurrentLocation: city.isCurrentLocation
            )
        }

        if savedRows.isEmpty {
            view?.displayList(.empty(message: ""))
        } else {
            view?.displayList(.savedCities(savedRows))
        }
    }
    
    func makeSelectedCity(from city: CitySearchModels.City, photoURLString: String?) -> SelectedCity {
        SelectedCity(
            name: city.name,
            country: city.country,
            latitude: city.latitude,
            longitude: city.longitude,
            photoURLString: photoURLString,
            isCurrentLocation: false
        )
    }
    
    func loadAndStorePhoto(for city: CitySearchModels.City) {
        selectedCityPhotoTask?.cancel()

        selectedCityPhotoTask = Task { [weak self] in
            guard let self else { return }

            do {
                let preview = try await unsplashSearchService.searchPhoto(for: city.name)

                guard let index = cityListStorage.cities.lastIndex(where: {
                    $0.name == city.name && abs($0.latitude - city.latitude) < 0.0001
                }) else { return }

                let updatedCity = makeSelectedCity(
                    from: city,
                    photoURLString: preview?.imageURL.absoluteString
                )

                cityListStorage.updateCity(at: index, updatedCity)
            } catch is CancellationError {
                print("Selected city photo loading cancelled")
            } catch {
                print("Selected city photo loading error:", error.localizedDescription)
            }
        }
    }

    func loadAndStorePhoto(forCurrentLocation city: SelectedCity) {
        selectedCityPhotoTask?.cancel()

        selectedCityPhotoTask = Task { [weak self] in
            guard let self else { return }

            do {
                let preview = try await unsplashSearchService.searchPhoto(for: city.name)
                let updated = SelectedCity(
                    name: city.name,
                    country: city.country,
                    latitude: city.latitude,
                    longitude: city.longitude,
                    photoURLString: preview?.imageURL.absoluteString,
                    isCurrentLocation: true
                )
                cityListStorage.upsertCurrentLocation(updated)
            } catch is CancellationError {
                print("Current location photo loading cancelled")
            } catch {
                print("Current location photo loading error:", error.localizedDescription)
            }
        }
    }
}
