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
        let weatherViewController = WeatherAssembly.build()
        
        let weatherNavigationController = UINavigationController(rootViewController: weatherViewController)
        let citySearchNavigationController = UINavigationController(rootViewController: citySearchViewController)
        
        weatherNavigationController.tabBarItem = UITabBarItem(
            title: "Weather",
            image: UIImage(systemName: "cloud.sun.fill"),
            selectedImage: UIImage(systemName: "cloud.sun.fill")
        )
        
        citySearchNavigationController.tabBarItem = UITabBarItem(
            title: "Search City",
            image: UIImage(systemName: "magnifyingglass"),
            selectedImage: UIImage(systemName: "magnifyingglass")
        )
        
        tabBarController.setViewControllers([citySearchNavigationController, weatherNavigationController], animated: false)
        
        return tabBarController
    }
}
