//
//  CurrentWeather.swift
//  PetMil
//
//  Created by Emil on 29.05.2026.
//

import Foundation

struct CurrentWeather: Codable {
    let temperature: Double
    let feelsLike: Double
    let pressure: Int
    let humidity: Int
    let windSpeed: Double
    let windDirectionDegrees: Int?
    let cloudiness: Int?
    let visibilityMeters: Int?
    let sunrise: Date
    let sunset: Date
    let description: String
    let iconCode: String
}
