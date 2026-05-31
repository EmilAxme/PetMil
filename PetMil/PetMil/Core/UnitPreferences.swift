//
//  UnitPreferences.swift
//  PetMil
//
//  Created by Emil on 29.05.2026.
//

import Foundation

enum TemperatureUnit: String, Codable, CaseIterable {
    case celsius
    case fahrenheit
}

enum WindSpeedUnit: String, Codable, CaseIterable {
    case metersPerSecond
    case kilometersPerHour
    case milesPerHour
}

enum PressureUnit: String, Codable, CaseIterable {
    case hPa
    case mmHg
}

enum ClockFormat: String, Codable, CaseIterable {
    case h24
    case h12
}

enum AppLanguage: String, Codable, CaseIterable {
    case russian = "ru"
    case english = "en"
}

struct UnitPreferences: Codable, Equatable {
    var temperatureUnit: TemperatureUnit
    var windSpeedUnit: WindSpeedUnit
    var pressureUnit: PressureUnit
    var clockFormat: ClockFormat
    var language: AppLanguage

    static let `default` = UnitPreferences(
        temperatureUnit: .celsius,
        windSpeedUnit: .metersPerSecond,
        pressureUnit: .hPa,
        clockFormat: .h24,
        language: .russian
    )
}
