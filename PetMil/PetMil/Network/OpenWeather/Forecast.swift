//
//  Forecast.swift
//  PetMil
//
//  Created by Emil on 08.04.2026.
//

import Foundation

struct Forecast: Codable {
    let cityName: String
    let items: [ForecastItem]
}

struct ForecastItem: Codable {
    let date: Date
    let temperature: Double
    let feelsLike: Double
    let pressure: Int
    let humidity: Int
    let windSpeed: Double
    let title: String
    let description: String
    let iconCode: String
    let precipitationProbability: Double?
}
