//
//  WeatherPresenter.swift
//  PetMil
//
//  Created by Emil on 09.03.2026.
//

import Foundation

protocol WeatherPresenterProtocol: AnyObject {
    func viewDidLoad()
    func viewWillAppear()
}

final class WeatherPresenter {
    
    weak var view: WeatherViewProtocol?
    
    private let storage: SelectedCityStorageProtocol
    private let weatherService: WeatherServiceProtocol
    
    init(
        storage: SelectedCityStorageProtocol,
        weatherService: WeatherServiceProtocol
    ) {
        self.storage = storage
        self.weatherService = weatherService
    }
}
    
    
extension WeatherPresenter: WeatherPresenterProtocol {
    func viewDidLoad() {
        updateWeather()
    }
    
    func viewWillAppear() {
        updateWeather()
    }
}

private extension WeatherPresenter {
    func updateWeather() {
        let selectedCity = storage.selectedCity
        
        let viewModel = WeatherModels.ViewModel(
            city: selectedCity,
            currentTemperature: "12°",
            currentDescription: "Cloudy",
            rows: [
                .init(
                    dayText: "Today",
                    temperatureText: "12°",
                    descriptionText: "Cloudy",
                    humidityText: "78%",
                    windText: "5 m/s",
                    feelsLikeText: "10°",
                    pressureText: "1012 hPa"
                ),
                .init(
                    dayText: "Tomorrow",
                    temperatureText: "10°",
                    descriptionText: "Rain",
                    humidityText: "85%",
                    windText: "7 m/s",
                    feelsLikeText: "8°",
                    pressureText: "1008 hPa"
                ),
                .init(
                    dayText: "Friday",
                    temperatureText: "14°",
                    descriptionText: "Sunny",
                    humidityText: "60%",
                    windText: "3 m/s",
                    feelsLikeText: "13°",
                    pressureText: "1015 hPa"
                )
            ]
        )
        
        view?.displayWeather(viewModel: viewModel)
    }
}
