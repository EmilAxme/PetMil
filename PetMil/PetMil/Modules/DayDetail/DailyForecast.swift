//
//  DailyForecast.swift
//  PetMil
//
//  Created by Emil on 09.04.2026.
//

import Foundation

struct DailyForecast {
    let date: Date
    let summary: String
    let currentTemperature: Double
    let minTemperature: Double
    let maxTemperature: Double
    let hourlyItems: [ForecastItem]
}
