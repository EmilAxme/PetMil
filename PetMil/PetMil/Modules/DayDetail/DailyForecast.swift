//
//  DailyForecast.swift
//  PetMil
//
//  Created by Emil on 09.04.2026.
//

import Foundation

struct DailyForecast {
    let date: Date
    let cityName: String
    let summary: String
    let currentTemperature: Double
    let hourlyItems: [ForecastItem]
}
