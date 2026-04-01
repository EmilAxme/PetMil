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
        
        let viewModel = WeatherModels.ViewModel(
                   screenTitle: "Weather",
                   city: "Moscow",
                   currentTemperature: "12°",
                   currentDescription: "Cloudy",
                   backgroundGIFName: "cloudy",
                   rows: [
                       .init(dayText: "Today", temperatureText: "12°", descriptionText: "Cloudy"),
                       .init(dayText: "Tomorrow", temperatureText: "10°", descriptionText: "Rain"),
                       .init(dayText: "Friday", temperatureText: "14°", descriptionText: "Sunny")
                   ]
               )
        
        view?.displayWeather(viewModel: viewModel)
    }
}
