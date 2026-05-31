//
//  WeatherSymbolMapper.swift
//  PetMil
//
//  Created by Emil on 29.05.2026.
//

import Foundation

enum WeatherSymbolMapper {
    static func symbolName(for openWeatherCode: String) -> String? {
        let trimmed = openWeatherCode.lowercased()
        guard !trimmed.isEmpty else { return nil }

        let isDay = trimmed.hasSuffix("d")
        let prefix = String(trimmed.dropLast())

        switch prefix {
        case "01": return isDay ? "sun.max.fill" : "moon.stars.fill"
        case "02": return isDay ? "cloud.sun.fill" : "cloud.moon.fill"
        case "03": return "cloud.fill"
        case "04": return "smoke.fill"
        case "09": return "cloud.heavyrain.fill"
        case "10": return isDay ? "cloud.sun.rain.fill" : "cloud.moon.rain.fill"
        case "11": return "cloud.bolt.rain.fill"
        case "13": return "cloud.snow.fill"
        case "50": return "cloud.fog.fill"
        default: return nil
        }
    }
}
