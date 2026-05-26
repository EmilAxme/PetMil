//
//  WeatherAssembly.swift
//  PetMil
//
//  Created by Emil on 08.03.2026.
//

import UIKit

enum WeatherAssembly {
    static func build() -> UIViewController {
        let viewController = WeatherViewController()
        
        let networkClient = NetworkClient()
        let weatherService = WeatherService(
            networkClient: networkClient,
            apiKey: Secrets.openWeatherAPIKey
        )
        let unsplashSearchService = UnsplashSearchService(
            networkClient: networkClient,
            accessKey: Secrets.unsplashAccessKey
        )
        let weatherIconService = WeatherIconService()
        let imageLoaderService = ImageLoaderService()

        let presenter = WeatherPresenter(
            storage: SelectedCityStorage.shared,
            weatherService: weatherService,
            unsplashSearchService: unsplashSearchService
        )
        
        viewController.presenter = presenter
        viewController.weatherIconService = weatherIconService
        viewController.imageLoaderService = imageLoaderService
        presenter.view = viewController
        
        return viewController
    }
}
