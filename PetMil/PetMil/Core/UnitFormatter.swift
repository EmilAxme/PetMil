//
//  UnitFormatter.swift
//  PetMil
//
//  Created by Emil on 29.05.2026.
//

import Foundation

struct PressureFormatted {
    let value: String
    let unit: String
}

protocol UnitFormatterProtocol {
    func temperature(_ celsius: Double?) -> String
    func temperatureNoSign(_ celsius: Double?) -> String
    func windSpeed(_ mps: Double) -> String
    func windSpeedShort(_ mps: Double) -> String
    func pressure(_ hPa: Int) -> PressureFormatted
    func humidity(_ percent: Int) -> String
    func clockTime(_ date: Date) -> String
    func weekday(from date: Date) -> String
    func temperatureUnitLabel() -> String
    func windUnitLabel() -> String
    func pressureUnitLabel() -> String
    func clockFormatLabel(_ format: ClockFormat) -> String
    func languageLabel(_ language: AppLanguage) -> String
    func temperatureLabel(_ unit: TemperatureUnit) -> String
    func windLabel(_ unit: WindSpeedUnit) -> String
    func pressureLabel(_ unit: PressureUnit) -> String
}

final class UnitFormatter: UnitFormatterProtocol {

    private let preferences: UnitPreferences
    private let l10n: L10n

    init(preferences: UnitPreferences, l10n: L10n = .shared) {
        self.preferences = preferences
        self.l10n = l10n
    }

    func temperature(_ celsius: Double?) -> String {
        guard let celsius else { return "--°" }
        let converted = convertTemperature(celsius)
        return "\(Int(converted.rounded()))°"
    }

    func temperatureNoSign(_ celsius: Double?) -> String {
        guard let celsius else { return "--°" }
        let converted = convertTemperature(celsius)
        return "\(Int(abs(converted.rounded())))°"
    }

    func windSpeed(_ mps: Double) -> String {
        let value = convertWindSpeed(mps)
        let suffix: String
        switch preferences.windSpeedUnit {
        case .metersPerSecond: suffix = l10n.string(" м/с", " m/s")
        case .kilometersPerHour: suffix = l10n.string(" км/ч", " km/h")
        case .milesPerHour: suffix = " mph"
        }
        return "\(Int(value.rounded()))\(suffix)"
    }

    func windSpeedShort(_ mps: Double) -> String {
        let value = convertWindSpeed(mps)
        return "\(Int(value.rounded()))"
    }

    func pressure(_ hPa: Int) -> PressureFormatted {
        switch preferences.pressureUnit {
        case .hPa:
            return PressureFormatted(value: "\(hPa)", unit: l10n.string("гПа", "hPa"))
        case .mmHg:
            let converted = Int((Double(hPa) * 0.750062).rounded())
            return PressureFormatted(value: "\(converted)", unit: l10n.string("мм рт. ст.", "mmHg"))
        }
    }

    func humidity(_ percent: Int) -> String {
        "\(percent)%"
    }

    func clockTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = l10n.locale
        formatter.dateFormat = preferences.clockFormat == .h24 ? "HH:mm" : "h:mm a"
        return formatter.string(from: date)
    }

    func weekday(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = l10n.locale
        formatter.dateFormat = "EEEE"
        let weekday = formatter.string(from: date)
        return weekday.prefix(1).uppercased() + weekday.dropFirst()
    }

    func temperatureUnitLabel() -> String {
        temperatureLabel(preferences.temperatureUnit)
    }

    func windUnitLabel() -> String {
        windLabel(preferences.windSpeedUnit)
    }

    func pressureUnitLabel() -> String {
        pressureLabel(preferences.pressureUnit)
    }

    func clockFormatLabel(_ format: ClockFormat) -> String {
        switch format {
        case .h24: return l10n.string("24 часа", "24-hour")
        case .h12: return l10n.string("12 часов", "12-hour")
        }
    }

    func languageLabel(_ language: AppLanguage) -> String {
        switch language {
        case .russian: return l10n.string("Русский", "Russian")
        case .english: return l10n.string("Английский", "English")
        }
    }

    func temperatureLabel(_ unit: TemperatureUnit) -> String {
        switch unit {
        case .celsius: return "°C"
        case .fahrenheit: return "°F"
        }
    }

    func windLabel(_ unit: WindSpeedUnit) -> String {
        switch unit {
        case .metersPerSecond: return l10n.string("м/с", "m/s")
        case .kilometersPerHour: return l10n.string("км/ч", "km/h")
        case .milesPerHour: return "mph"
        }
    }

    func pressureLabel(_ unit: PressureUnit) -> String {
        switch unit {
        case .hPa: return l10n.string("гПа", "hPa")
        case .mmHg: return l10n.string("мм рт. ст.", "mmHg")
        }
    }
}

private extension UnitFormatter {
    func convertTemperature(_ celsius: Double) -> Double {
        switch preferences.temperatureUnit {
        case .celsius: return celsius
        case .fahrenheit: return celsius * 9.0 / 5.0 + 32
        }
    }

    func convertWindSpeed(_ mps: Double) -> Double {
        switch preferences.windSpeedUnit {
        case .metersPerSecond: return mps
        case .kilometersPerHour: return mps * 3.6
        case .milesPerHour: return mps * 2.236936
        }
    }
}
