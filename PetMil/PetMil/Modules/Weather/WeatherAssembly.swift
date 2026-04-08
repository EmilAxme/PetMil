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
        
        let presenter = WeatherPresenter(
            storage: SelectedCityStorage.shared,
            weatherService: weatherService
        )
        
        viewController.presenter = presenter
        presenter.view = viewController
        
        return viewController
    }
}
