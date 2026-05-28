//
//  WeatherPresenter.swift
//  PetMil
//
//  Created by Emil on 09.03.2026.
//

import Foundation

protocol WeatherPresenterProtocol: AnyObject {
    func viewWillAppear()
    func retryButtonTapped()
    func refreshWeather()
}

final class WeatherPresenter {
    
    weak var view: WeatherViewProtocol?
    
    private var lastRequestedCity: String?
    private var weatherTask: Task<Void, Never>?
    
    private let storage: SelectedCityStorageProtocol
    private let weatherService: WeatherServiceProtocol
    private let unsplashSearchService: UnsplashSearchServiceProtocol

    init(
        storage: SelectedCityStorageProtocol,
        weatherService: WeatherServiceProtocol,
        unsplashSearchService: UnsplashSearchServiceProtocol
    ) {
        self.storage = storage
        self.weatherService = weatherService
        self.unsplashSearchService = unsplashSearchService
    }
}


extension WeatherPresenter: WeatherPresenterProtocol {
    func viewWillAppear() {
        updateWeather(forceReload: false)
    }
    
    func retryButtonTapped() {
        updateWeather(forceReload: true)
    }

    func refreshWeather() {
        lastRequestedCity = nil
        updateWeather(forceReload: true)
    }
}

private extension WeatherPresenter {
    func updateWeather(forceReload: Bool) {
        weatherTask?.cancel()

        guard storage.hasSelectedCity else {
            view?.displayState(.noCitySelected)
            return
        }

        let selectedCity = storage.selectedCity

        guard selectedCity.name != lastRequestedCity else { return }
        lastRequestedCity = selectedCity.name
        
        view?.displayState(.loading)
        print("Loading weather for city:", selectedCity)
        
        weatherTask = Task { [weak self] in
            guard let self else { return }

            do {
                async let forecastTask = weatherService.fetchForecast(
                    lat: selectedCity.latitude,
                    lon: selectedCity.longitude
                )
                async let photoURLTask = resolvePhotoURL(for: selectedCity)

                let (forecast, photoURL) = try await (forecastTask, photoURLTask)

                try Task.checkCancellation()

                let viewModel = makeViewModel(
                    from: forecast,
                    fallbackCity: selectedCity.name,
                    backgroundPhotoURL: photoURL
                )

                await MainActor.run {
                    self.view?.displayState(.content(viewModel))
                }
            } catch is CancellationError {
                print("Weather task cancelled")
            } catch {
                lastRequestedCity = nil

                await MainActor.run {
                    self.view?.displayState(.error("Не удалось загрузить данные о погоде"))
                }

                print("Weather loading error:", error.localizedDescription)
            }
        }
        
    }
    
    func resolvePhotoURL(for city: SelectedCity) async -> URL? {
        if let urlString = city.photoURLString, let url = URL(string: urlString) {
            return url
        }
        let fallbackQuery = city.name.isEmpty ? "Moscow" : city.name
        let preview = try? await unsplashSearchService.searchPhoto(for: fallbackQuery)
        return preview?.imageURL
    }

    func makeViewModel(from forecast: Forecast, fallbackCity: String, backgroundPhotoURL: URL?) -> WeatherModels.ViewModel {
        let currentItem = forecast.items.first

        let currentTemperature = formattedTemperature(currentItem?.temperature)
        let currentDescription = formattedDescription(currentItem?.description) ?? "Нет данных"

        let dailyForecasts = makeDailyForecasts(from: forecast, maxCount: 5)

        let rows = dailyForecasts.map { dayForecast in
            let representativeItem = bestItemForDay(dayForecast.hourlyItems)

            return WeatherModels.ForecastRow(
                dayText: formattedDay(from: dayForecast.date),
                maxTemperatureText: formattedTemperature(dayForecast.maxTemperature),
                minTemperatureText: formattedTemperature(dayForecast.minTemperature),
                descriptionText: formattedDescription(representativeItem?.description) ?? dayForecast.summary,
                humidityText: "\(representativeItem?.humidity ?? 0)%",
                windText: "\(Int((representativeItem?.windSpeed ?? 0).rounded())) m/s",
                feelsLikeText: formattedTemperature(representativeItem?.feelsLike),
                pressureText: "\(representativeItem?.pressure ?? 0) hPa",
                iconCode: representativeItem?.iconCode,
                dailyForecast: dayForecast
            )
        }

        let hourlyRows = makeHourlyRows(from: forecast.items, maxCount: 12)

        return WeatherModels.ViewModel(
            city: forecast.cityName.isEmpty ? fallbackCity : forecast.cityName,
            currentTemperature: currentTemperature,
            currentDescription: currentDescription,
            currentIconCode: currentItem?.iconCode,
            backgroundPhotoURL: backgroundPhotoURL,
            hourlyRows: hourlyRows,
            rows: rows
        )
    }

    func makeHourlyRows(from items: [ForecastItem], maxCount: Int) -> [WeatherModels.HourlyRow] {
        let now = Date()
        let upcoming = items.filter { $0.date >= now.addingTimeInterval(-30 * 60) }
        let source = upcoming.isEmpty ? items : upcoming

        return source.prefix(maxCount).enumerated().map { index, item in
            WeatherModels.HourlyRow(
                timeText: formattedHour(from: item.date, isFirst: index == 0),
                temperatureText: formattedTemperature(item.temperature),
                iconCode: item.iconCode,
                precipitationText: formattedPrecipitation(item.precipitationProbability)
            )
        }
    }

    func formattedHour(from date: Date, isFirst: Bool) -> String {
        let calendar = Calendar.current
        if isFirst && abs(date.timeIntervalSinceNow) < 90 * 60 {
            return "Сейчас"
        }

        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }

    func formattedPrecipitation(_ value: Double?) -> String? {
        guard let value, value >= 0.1 else { return nil }
        return "\(Int((value * 100).rounded()))%"
    }
    
    func makeDailyForecasts(from forecast: Forecast, maxCount: Int) -> [DailyForecast] {
        let calendar = Calendar.current
        
        let groupedItems = Dictionary(grouping: forecast.items) { item in
            calendar.startOfDay(for: item.date)
        }
        
        let sortedDays = groupedItems.keys.sorted()
        
        let dailyForecasts: [DailyForecast] = sortedDays.compactMap { day in
            guard let dayItems = groupedItems[day], !dayItems.isEmpty else { return nil }
            guard let representativeItem = bestItemForDay(dayItems) else { return nil }
            
            let minTemperature = dayItems.map(\.temperature).min() ?? representativeItem.temperature
            let maxTemperature = dayItems.map(\.temperature).max() ?? representativeItem.temperature
            
            return DailyForecast(
                date: day,
                summary: representativeItem.title,
                currentTemperature: representativeItem.temperature,
                minTemperature: minTemperature,
                maxTemperature: maxTemperature,
                hourlyItems: dayItems.sorted { $0.date < $1.date }
            )
        }
        
        return Array(dailyForecasts.prefix(maxCount))
    }
    
    func formattedTemperature(_ value: Double?) -> String {
        guard let value else { return "--°" }
        return "\(Int(value.rounded()))°"
    }
    
    func formattedDay(from date: Date) -> String {
        if Calendar.current.isDateInToday(date) {
            return "Сегодня"
        }

        if Calendar.current.isDateInTomorrow(date) {
            return "Завтра"
        }

        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.dateFormat = "EEEE"
        let weekday = formatter.string(from: date)
        return weekday.prefix(1).uppercased() + weekday.dropFirst()
    }
    
    func formattedDescription(_ value: String?) -> String? {
        guard let value, !value.isEmpty else { return nil }
        return value.prefix(1).uppercased() + value.dropFirst()
    }

    func bestItemForDay(_ items: [ForecastItem]) -> ForecastItem? {
        let calendar = Calendar.current
        
        return items.min { lhs, rhs in
            let lhsHour = calendar.component(.hour, from: lhs.date)
            let rhsHour = calendar.component(.hour, from: rhs.date)
            
            let lhsDistance = abs(lhsHour - 12)
            let rhsDistance = abs(rhsHour - 12)
            
            return lhsDistance < rhsDistance
        }
    }
}
