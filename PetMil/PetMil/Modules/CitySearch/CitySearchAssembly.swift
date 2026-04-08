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
        let presenter = CitySearchPresenter(storage: SelectedCityStorage.shared)
        
        viewController.presenter = presenter
        presenter.view = viewController
        
        return viewController
    }
}
