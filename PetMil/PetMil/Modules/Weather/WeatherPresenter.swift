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

    private let city: SelectedCity?
    private var lastRequestedCity: String?
    private var weatherTask: Task<Void, Never>?

    private let weatherService: WeatherServiceProtocol
    private let unsplashSearchService: UnsplashSearchServiceProtocol
    private let cacheRepository: ForecastCacheRepositoryProtocol
    private let formatter: UnitFormatterProtocol
    private let l10n: L10n

    private let freshCacheTTL: TimeInterval = 10 * 60
    private let staleCacheTTL: TimeInterval = 24 * 60 * 60

    init(
        city: SelectedCity?,
        weatherService: WeatherServiceProtocol,
        unsplashSearchService: UnsplashSearchServiceProtocol,
        cacheRepository: ForecastCacheRepositoryProtocol,
        formatter: UnitFormatterProtocol,
        l10n: L10n = .shared
    ) {
        self.city = city
        self.weatherService = weatherService
        self.unsplashSearchService = unsplashSearchService
        self.cacheRepository = cacheRepository
        self.formatter = formatter
        self.l10n = l10n
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

        guard let selectedCity = city else {
            view?.displayState(.noCitySelected)
            return
        }

        if !forceReload, selectedCity.name == lastRequestedCity { return }
        lastRequestedCity = selectedCity.name

        let cacheKey = makeCacheKey(for: selectedCity)
        let cached = cacheRepository.loadCached(for: cacheKey)
        let now = Date()

        if let cached, !forceReload {
            let age = now.timeIntervalSince(cached.fetchedAt)
            let viewModel = makeViewModel(
                from: cached.payload.forecast,
                currentWeather: cached.payload.currentWeather,
                fallbackCity: cached.payload.cityName,
                backgroundPhotoURL: nil
            )

            if age < freshCacheTTL {
                view?.displayState(.content(viewModel))
            } else if age < staleCacheTTL {
                view?.displayState(.stale(viewModel, fetchedAt: cached.fetchedAt))
            } else {
                view?.displayState(.loading)
            }
        } else {
            view?.displayState(.loading)
        }

        print("Loading weather for city:", selectedCity)
        
        weatherTask = Task { [weak self] in
            guard let self else { return }

            do {
                async let forecastTask = weatherService.fetchForecast(
                    lat: selectedCity.latitude,
                    lon: selectedCity.longitude
                )
                async let photoURLTask = resolvePhotoURL(for: selectedCity)
                async let currentWeatherTask = fetchCurrentWeatherOptional(
                    lat: selectedCity.latitude,
                    lon: selectedCity.longitude
                )

                let (forecast, photoURL, currentWeather) = try await (
                    forecastTask,
                    photoURLTask,
                    currentWeatherTask
                )

                try Task.checkCancellation()

                let viewModel = makeViewModel(
                    from: forecast,
                    currentWeather: currentWeather,
                    fallbackCity: selectedCity.name,
                    backgroundPhotoURL: photoURL
                )

                cacheRepository.saveCache(
                    CachedWeather(
                        forecast: forecast,
                        currentWeather: currentWeather,
                        cityName: forecast.cityName.isEmpty ? selectedCity.name : forecast.cityName
                    ),
                    for: cacheKey,
                    at: Date()
                )

                await MainActor.run {
                    self.view?.displayState(.content(viewModel))
                }
            } catch is CancellationError {
                print("Weather task cancelled")
            } catch {
                lastRequestedCity = nil

                if let cached {
                    let viewModel = makeViewModel(
                        from: cached.payload.forecast,
                        currentWeather: cached.payload.currentWeather,
                        fallbackCity: cached.payload.cityName,
                        backgroundPhotoURL: nil
                    )
                    await MainActor.run {
                        self.view?.displayState(.stale(viewModel, fetchedAt: cached.fetchedAt))
                    }
                } else {
                    await MainActor.run {
                        self.view?.displayState(.error(self.l10n.weatherLoadFailed))
                    }
                }

                print("Weather loading error:", error.localizedDescription)
            }
        }

    }

    func fetchCurrentWeatherOptional(lat: Double, lon: Double) async -> CurrentWeather? {
        try? await weatherService.fetchCurrentWeather(lat: lat, lon: lon)
    }

    func makeCacheKey(for city: SelectedCity) -> String {
        let lat = (city.latitude * 10_000).rounded() / 10_000
        let lon = (city.longitude * 10_000).rounded() / 10_000
        return "\(lat),\(lon)"
    }
    
    func resolvePhotoURL(for city: SelectedCity) async -> URL? {
        if let urlString = city.photoURLString, let url = URL(string: urlString) {
            return url
        }
        let fallbackQuery = city.name.isEmpty ? "Moscow" : city.name
        let preview = try? await unsplashSearchService.searchPhoto(for: fallbackQuery)
        return preview?.imageURL
    }

    func makeViewModel(
        from forecast: Forecast,
        currentWeather: CurrentWeather?,
        fallbackCity: String,
        backgroundPhotoURL: URL?
    ) -> WeatherModels.ViewModel {
        let currentItem = forecast.items.first

        let currentTemperature = formatter.temperature(currentWeather?.temperature ?? currentItem?.temperature)
        let currentDescription = formattedDescription(currentWeather?.description ?? currentItem?.description) ?? l10n.noData
        let currentIconCode = currentWeather?.iconCode ?? currentItem?.iconCode

        let dailyForecasts = makeDailyForecasts(from: forecast, maxCount: 5)

        let rows = dailyForecasts.map { dayForecast in
            let representativeItem = bestItemForDay(dayForecast.hourlyItems)
            let pressureFormatted = formatter.pressure(representativeItem?.pressure ?? 0)

            return WeatherModels.ForecastRow(
                dayText: formattedDay(from: dayForecast.date),
                maxTemperatureText: formatter.temperature(dayForecast.maxTemperature),
                minTemperatureText: formatter.temperature(dayForecast.minTemperature),
                descriptionText: formattedDescription(representativeItem?.description) ?? dayForecast.summary,
                humidityText: formatter.humidity(representativeItem?.humidity ?? 0),
                windText: formatter.windSpeed(representativeItem?.windSpeed ?? 0),
                feelsLikeText: formatter.temperature(representativeItem?.feelsLike),
                pressureText: "\(pressureFormatted.value) \(pressureFormatted.unit)",
                iconCode: representativeItem?.iconCode,
                dailyForecast: dayForecast
            )
        }

        let hourlyRows = makeHourlyRows(from: forecast.items, maxCount: 12)
        let conditionTiles = makeConditionTiles(currentWeather: currentWeather, fallbackItem: currentItem)

        return WeatherModels.ViewModel(
            city: forecast.cityName.isEmpty ? fallbackCity : forecast.cityName,
            currentTemperature: currentTemperature,
            currentDescription: currentDescription,
            currentIconCode: currentIconCode,
            backgroundPhotoURL: backgroundPhotoURL,
            hourlyRows: hourlyRows,
            conditionTiles: conditionTiles,
            rows: rows
        )
    }

    func makeConditionTiles(currentWeather: CurrentWeather?, fallbackItem: ForecastItem?) -> [WeatherModels.ConditionTile] {
        let humidity = currentWeather?.humidity ?? fallbackItem?.humidity
        let feelsLike = currentWeather?.feelsLike ?? fallbackItem?.feelsLike
        let pressure = currentWeather?.pressure ?? fallbackItem?.pressure
        let windSpeed = currentWeather?.windSpeed ?? fallbackItem?.windSpeed

        var tiles: [WeatherModels.ConditionTile] = []

        if let humidity {
            tiles.append(.init(
                symbolName: "humidity.fill",
                title: l10n.humidity,
                value: formatter.humidity(humidity),
                subtitle: nil
            ))
        }

        if let windSpeed {
            tiles.append(.init(
                symbolName: "wind",
                title: l10n.wind,
                value: formatter.windSpeed(windSpeed),
                subtitle: currentWeather?.windDirectionDegrees.map { l10n.compassDirection(degrees: $0) }
            ))
        }

        if let feelsLike {
            tiles.append(.init(
                symbolName: "thermometer.medium",
                title: l10n.feelsLike,
                value: formatter.temperature(feelsLike),
                subtitle: nil
            ))
        }

        if let pressure {
            let pressureFormatted = formatter.pressure(pressure)
            tiles.append(.init(
                symbolName: "gauge.with.dots.needle.50percent",
                title: l10n.pressure,
                value: pressureFormatted.value,
                subtitle: pressureFormatted.unit
            ))
        }

        if let current = currentWeather {
            tiles.append(.init(
                symbolName: "sunrise.fill",
                title: l10n.sunrise,
                value: formatter.clockTime(current.sunrise),
                subtitle: nil
            ))
            tiles.append(.init(
                symbolName: "sunset.fill",
                title: l10n.sunset,
                value: formatter.clockTime(current.sunset),
                subtitle: nil
            ))
        }

        return tiles
    }

    func makeHourlyRows(from items: [ForecastItem], maxCount: Int) -> [WeatherModels.HourlyRow] {
        let now = Date()
        let upcoming = items.filter { $0.date >= now.addingTimeInterval(-30 * 60) }
        let source = upcoming.isEmpty ? items : upcoming

        return source.prefix(maxCount).enumerated().map { index, item in
            WeatherModels.HourlyRow(
                timeText: formattedHour(from: item.date, isFirst: index == 0),
                temperatureText: formatter.temperature(item.temperature),
                iconCode: item.iconCode,
                precipitationText: formattedPrecipitation(item.precipitationProbability)
            )
        }
    }

    func formattedHour(from date: Date, isFirst: Bool) -> String {
        if isFirst && abs(date.timeIntervalSinceNow) < 90 * 60 {
            return l10n.now
        }
        return formatter.clockTime(date)
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
    
    func formattedDay(from date: Date) -> String {
        if Calendar.current.isDateInToday(date) { return l10n.today }
        if Calendar.current.isDateInTomorrow(date) { return l10n.tomorrow }
        return formatter.weekday(from: date)
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
