//
//  DayDetailPresenter.swift
//  PetMil
//
//  Created by Emil on 07.04.2026.
//

import Foundation

protocol DayDetailsPresenterProtocol: AnyObject {
    func viewDidLoad()
}

final class DayDetailsPresenter {
    
    weak var view: DayDetailsViewProtocol?
    private let day: WeatherModels.ForecastRow
    
    init(day: WeatherModels.ForecastRow) {
        self.day = day
    }
}

extension DayDetailsPresenter: DayDetailsPresenterProtocol {
    func viewDidLoad() {
        let viewModel = DayDetailsModels.ViewModel(
            dayText: day.dayText,
            temperatureText: day.temperatureText,
            descriptionText: day.descriptionText,
            humidityText: day.humidityText,
            windText: day.windText,
            feelsLikeText: day.feelsLikeText,
            pressureText: day.pressureText
        )
        
        view?.displayDayDetails(viewModel: viewModel)
    }
}
