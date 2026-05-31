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
        case stale(ViewModel, fetchedAt: Date)
        case error(String)
        case noCitySelected
    }
    
    struct ViewModel {
        let city: String
        let currentTemperature: String
        let currentDescription: String
        let currentIconCode: String?
        let backgroundPhotoURL: URL?
        let hourlyRows: [HourlyRow]
        let conditionTiles: [ConditionTile]
        let rows: [ForecastRow]
    }

    struct ConditionTile {
        let symbolName: String
        let title: String
        let value: String
        let subtitle: String?
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

    struct HourlyRow {
        let timeText: String
        let temperatureText: String
        let iconCode: String?
        let precipitationText: String?
    }
}
