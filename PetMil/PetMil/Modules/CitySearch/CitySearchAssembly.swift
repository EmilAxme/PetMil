//
//  CitySearchAssembly.swift
//  PetMil
//
//  Created by Emil on 11.03.2026.
//

import UIKit

enum CitySearchAssembly {
    static func build() -> UIViewController {
        let viewController = CitySearchViewController()

        let networkClient = NetworkClient()
        let citySearchService = CitySearchService(
            networkClient: networkClient,
            apiKey: Secrets.openWeatherAPIKey
        )
        let unsplashSearchService = UnsplashSearchService(
            networkClient: networkClient,
            accessKey: Secrets.unsplashAccessKey
        )
        let weatherService = WeatherService(
            networkClient: networkClient,
            apiKey: Secrets.openWeatherAPIKey
        )
        let locationService = LocationService()

        let presenter = CitySearchPresenter(
            storage: SelectedCityStorage.shared,
            citySearchService: citySearchService,
            unsplashSearchService: unsplashSearchService,
            locationService: locationService,
            weatherService: weatherService
        )

        viewController.presenter = presenter
        presenter.view = viewController

        return viewController
    }
}
