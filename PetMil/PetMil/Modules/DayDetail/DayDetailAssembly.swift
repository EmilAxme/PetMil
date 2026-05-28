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
        let formatter = UnitFormatter(preferences: SettingsStorage.shared.preferences)
        let presenter = DayDetailsPresenter(dayForecast: dayForecast, formatter: formatter)

        viewController.presenter = presenter
        presenter.view = viewController

        return viewController
    }
}
