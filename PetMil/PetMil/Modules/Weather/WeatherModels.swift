//
//  WeatherModels.swift
//  PetMil
//
//  Created by Emil on 09.03.2026.
//

import Foundation

enum WeatherModels {
    enum ViewState {
        case loading
        case content(ViewModel)
        case error(String)
    }
    
    struct ViewModel {
        let city: String
        let currentTemperature: String
        let currentDescription: String
        let currentIconCode: String?
        let rows: [ForecastRow]
    }
    
    struct ForecastRow {
        let dayText: String
        let maxTemperatureText: String
        let minTemperatureText: String
        let descriptionText: String
        let humidityText: String
        let windText: String
        let feelsLikeText: String
        let pressureText: String
        let iconCode: String?
        let dailyForecast: DailyForecast
    }
}
