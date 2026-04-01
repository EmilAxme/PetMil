//
//  WeatherViewController.swift
//  PetMil
//
//  Created by Emil on 04.03.2026.
//

import UIKit

protocol WeatherViewProtocol: AnyObject {
    func displayWeather(viewModel: WeatherModels.ViewModel)
}

class WeatherViewController: UIViewController {
    
    var presenter: WeatherPresenterProtocol?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupAppearance()
        presenter?.viewDidLoad()
    }
    
    private func setupAppearance() {
        view.backgroundColor = .systemBackground
    }

}

extension WeatherViewController: WeatherViewProtocol {
    func displayWeather(viewModel: WeatherModels.ViewModel) {
        title = viewModel.screenTitle
    }
}

