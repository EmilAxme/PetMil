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
        let presenter = WeatherPresenter(storage: SelectedCityStorage.shared)
        
        viewController.presenter = presenter
        presenter.view = viewController
        
        return viewController
    }
}
