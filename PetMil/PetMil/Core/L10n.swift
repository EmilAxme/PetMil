//
//  L10n.swift
//  PetMil
//
//  Created by Emil on 29.05.2026.
//

import Foundation

final class L10n {

    static let shared = L10n()

    private(set) var language: AppLanguage

    private init(settingsStorage: SettingsStorageProtocol = SettingsStorage.shared) {
        self.language = settingsStorage.preferences.language
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(reload),
            name: .unitPreferencesDidChange,
            object: nil
        )
    }

    @objc private func reload() {
        language = SettingsStorage.shared.preferences.language
    }

    var locale: Locale {
        switch language {
        case .russian: return Locale(identifier: "ru_RU")
        case .english: return Locale(identifier: "en_US")
        }
    }

    func string(_ ru: String, _ en: String) -> String {
        switch language {
        case .russian: return ru
        case .english: return en
        }
    }

    var now: String { string("Сейчас", "Now") }
    var today: String { string("Сегодня", "Today") }
    var tomorrow: String { string("Завтра", "Tomorrow") }
    var noData: String { string("Нет данных", "No data") }

    var humidity: String { string("Влажность", "Humidity") }
    var wind: String { string("Ветер", "Wind") }
    var feelsLike: String { string("Ощущается", "Feels like") }
    var pressure: String { string("Давление", "Pressure") }
    var sunrise: String { string("Восход", "Sunrise") }
    var sunset: String { string("Закат", "Sunset") }

    var useMyLocation: String { string("Использовать мою локацию", "Use my location") }
    var locating: String { string("Определяем локацию…", "Locating…") }
    var locationAccessDenied: String {
        string(
            "Доступ к геолокации запрещён. Разрешите его в Настройках → PetMil.",
            "Location access denied. Enable it in Settings → PetMil."
        )
    }
    var locationFailed: String {
        string(
            "Не удалось определить локацию. Попробуйте ещё раз.",
            "Couldn't determine your location. Try again."
        )
    }
    var locationUsageDescription: String { string("Текущая локация", "Current location") }

    var weatherLoadFailed: String {
        string("Не удалось загрузить данные о погоде", "Failed to load weather data")
    }

    var cityNotSelectedTitle: String { string("Город не выбран", "No city selected") }
    var cityNotSelectedSubtitle: String {
        string("Перейди на вкладку поиска\nи выбери город", "Open the search tab\nand pick a city")
    }
    var nothingFound: String {
        string("Ничего не найдено,\nвидимо город скрыт за туманом...", "Nothing found,\nlooks like the city is hidden in the fog...")
    }
    var searchCityPlaceholder: String { string("Поиск города", "Search city") }
    var searchCityTitle: String { string("Поиск", "Search") }

    var weatherTabTitle: String { string("Погода", "Weather") }
    var searchTabTitle: String { string("Поиск", "Search") }

    var retry: String { string("Повторить", "Retry") }
    var ok: String { string("OK", "OK") }
    var delete: String { string("Удалить", "Delete") }
    var cancel: String { string("Отмена", "Cancel") }
    var done: String { string("Готово", "Done") }

    func staleBanner(time: String) -> String {
        string("Нет сети · обновлено в \(time)", "No network · updated at \(time)")
    }

    var details: String { string("Подробнее", "Details") }
    var time: String { string("Время", "Time") }
    var temperature: String { string("Температура", "Temperature") }

    var settingsTitle: String { string("Настройки", "Settings") }
    var settingsUnitsSection: String { string("ЕДИНИЦЫ ИЗМЕРЕНИЯ", "UNITS") }
    var settingsAppearanceSection: String { string("ВНЕШНИЙ ВИД", "APPEARANCE") }
    var settingsLanguageSection: String { string("ЯЗЫК", "LANGUAGE") }
    var settingsTemperatureRow: String { string("Температура", "Temperature") }
    var settingsWindRow: String { string("Ветер", "Wind") }
    var settingsPressureRow: String { string("Давление", "Pressure") }
    var settingsClockRow: String { string("Формат времени", "Clock format") }
    var settingsLanguageRow: String { string("Язык", "Language") }

    func compassDirection(degrees: Int) -> String {
        let normalized = ((degrees % 360) + 360) % 360
        let index = Int(((Double(normalized) + 22.5) / 45.0).rounded(.down)) % 8

        let russian = ["С", "СВ", "В", "ЮВ", "Ю", "ЮЗ", "З", "СЗ"]
        let english = ["N", "NE", "E", "SE", "S", "SW", "W", "NW"]
        return language == .russian ? russian[index] : english[index]
    }
}
