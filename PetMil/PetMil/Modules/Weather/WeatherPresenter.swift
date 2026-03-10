//
//  WeatherPresenter.swift
//  PetMil
//
//  Created by Emil on 09.03.2026.
//

import Foundation

protocol WeatherPresenterProtocol: AnyObject {
    func viewDidLoad()
}

final class WeatherPresenter: WeatherPresenterProtocol {
    
    weak var view: WeatherViewProtocol?
    
    func viewDidLoad() {
        
        let viewModel = WeatherModels.Weather(
            screenTitle: "Пенис",
            temperature: "ДаблПеннис",
            description: "ТриплПеннис",
            city: "УльтраПеннис"
        )
        
        view?.displayWeather(viewModel: viewModel)
    }
}
