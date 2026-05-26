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
    
    init(
        storage: SelectedCityStorageProtocol,
        weatherService: WeatherServiceProtocol
    ) {
        self.storage = storage
        self.weatherService = weatherService
    }
}


extension WeatherPresenter: WeatherPresenterProtocol {
    func viewWillAppear() {
        updateWeather(forceReload: false)
    }
    
    func retryButtonTapped() {
        updateWeather(forceReload: true)
    }
}

private extension WeatherPresenter {
    func updateWeather(forceReload: Bool) {
        weatherTask?.cancel()
        
        let selectedCity = storage.selectedCity
        
        guard selectedCity.name != lastRequestedCity else { return }
        lastRequestedCity = selectedCity.name
        
        view?.displayState(.loading)
        print("Loading weather for city:", selectedCity)
        
        weatherTask = Task { [weak self] in
            guard let self else { return }
            
            do {
                let forecast = try await weatherService.fetchForecast(
                    lat: selectedCity.latitude,
                    lon: selectedCity.longitude
                )
                
                try Task.checkCancellation()
                
                let viewModel = makeViewModel(from: forecast, fallbackCity: selectedCity.name)
                
                await MainActor.run {
                    self.view?.displayState(.content(viewModel))
                }
            } catch is CancellationError {
                print("Weather task cancelled")
            } catch {
                lastRequestedCity = nil
                
                await MainActor.run {
                    self.view?.displayState(.error("Failed to load weather data"))
                }
                
                print("Weather loading error:", error.localizedDescription)
            }
        }
        
    }
    
    func makeViewModel(from forecast: Forecast, fallbackCity: String) -> WeatherModels.ViewModel {
        let currentItem = forecast.items.first
        
        let currentTemperature = formattedTemperature(currentItem?.temperature)
        let currentDescription = formattedDescription(currentItem?.description) ?? "No data"
        
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
        
        return WeatherModels.ViewModel(
            city: forecast.cityName.isEmpty ? fallbackCity : forecast.cityName,
            currentTemperature: currentTemperature,
            currentDescription: currentDescription,
            currentIconCode: currentItem?.iconCode,
            rows: rows
        )
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
            return "Today"
        }
        
        if Calendar.current.isDateInTomorrow(date) {
            return "Tomorrow"
        }
        
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "EEEE"
        return formatter.string(from: date)
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
