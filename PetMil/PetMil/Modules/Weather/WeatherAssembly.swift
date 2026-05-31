//
//  WeatherAssembly.swift
//  PetMil
//
//  Created by Emil on 08.03.2026.
//

import UIKit

enum WeatherAssembly {
    static func build(for city: SelectedCity?) -> WeatherViewController {
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

        let presenter = WeatherPresenter(
            city: city,
            weatherService: weatherService,
            unsplashSearchService: unsplashSearchService,
            cacheRepository: ForecastCacheRepository(),
            formatter: UnitFormatter(preferences: SettingsStorage.shared.preferences)
        )

        viewController.presenter = presenter
        viewController.weatherIconService = weatherIconService
        presenter.view = viewController

        return viewController
    }
}
