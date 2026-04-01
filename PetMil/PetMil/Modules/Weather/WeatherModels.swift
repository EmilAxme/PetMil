//
//  WeatherModels.swift
//  PetMil
//
//  Created by Emil on 09.03.2026.
//

import Foundation

enum WeatherModels {
    struct ViewModel {
        let screenTitle: String
        let city: String
        let currentTemperature: String
        let currentDescription: String
        let backgroundGIFName: String
        let rows: [ForecastRow]
    }
    
    struct ForecastRow {
        let dayText: String
        let temperatureText: String
        let descriptionText: String
    }
}
