//
//  DayDetailAssembly.swift
//  PetMil
//
//  Created by Emil on 07.04.2026.
//

import UIKit

enum DayDetailsAssembly {
    static func build(day: WeatherModels.ForecastRow) -> UIViewController {
        let viewController = DayDetailsViewController()
        let presenter = DayDetailsPresenter(day: day)
        
        viewController.presenter = presenter
        presenter.view = viewController
        
        return viewController
    }
}
