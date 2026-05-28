//
//  AppAssembly.swift
//  PetMil
//
//  Created by Emil on 11.03.2026.
//

import UIKit

enum AppAssembly {
    static func build() -> UIViewController {
        let tabBarController = AppTabBarController()

        let citySearchViewController = CitySearchAssembly.build()
        let weatherPageContainer = WeatherPageContainerViewController(
            cityListStorage: CityListStorage.shared
        )

        let weatherNavigationController = UINavigationController(rootViewController: weatherPageContainer)
        let citySearchNavigationController = UINavigationController(rootViewController: citySearchViewController)

        weatherNavigationController.tabBarItem = UITabBarItem(
            title: L10n.shared.weatherTabTitle,
            image: UIImage(systemName: "cloud.sun.fill"),
            selectedImage: UIImage(systemName: "cloud.sun.fill")
        )

        citySearchNavigationController.tabBarItem = UITabBarItem(
            title: L10n.shared.searchTabTitle,
            image: UIImage(systemName: "magnifyingglass"),
            selectedImage: UIImage(systemName: "magnifyingglass")
        )

        tabBarController.setViewControllers([citySearchNavigationController, weatherNavigationController], animated: false)

        return tabBarController
    }
}
