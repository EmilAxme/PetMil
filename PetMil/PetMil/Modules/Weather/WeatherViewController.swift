//
//  WeatherViewController.swift
//  PetMil
//
//  Created by Emil on 04.03.2026.
//

import UIKit

protocol WeatherViewProtocol: AnyObject {
    func displayWeather(viewModel: WeatherModels.Weather)
}

class WeatherViewController: UIViewController {
    
    var presenter: WeatherPresenterProtocol?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        presenter?.viewDidLoad()
    }

}

extension WeatherViewController: WeatherViewProtocol {
    func displayWeather(viewModel: WeatherModels.Weather) {
        title = viewModel.screenTitle
    }
}

