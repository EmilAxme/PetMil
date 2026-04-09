//
//  DayDetailAssembly.swift
//  PetMil
//
//  Created by Emil on 07.04.2026.
//

import UIKit

enum DayDetailsAssembly {
    static func build(dayForecast: DailyForecast) -> UIViewController {
        let viewController = DayDetailsViewController()
        let presenter = DayDetailsPresenter(dayForecast: dayForecast)
        
        viewController.presenter = presenter
        presenter.view = viewController
        
        return viewController
    }
}
