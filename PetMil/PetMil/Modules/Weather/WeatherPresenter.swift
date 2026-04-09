//
//  WeatherPresenter.swift
//  PetMil
//
//  Created by Emil on 09.03.2026.
//

import Foundation

protocol WeatherPresenterProtocol: AnyObject {
    func viewDidLoad()
    func viewWillAppear()
    func retryButtonTapped()
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
    func viewDidLoad() {    }
    
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
        
        guard selectedCity != lastRequestedCity else { return }
        lastRequestedCity = selectedCity
        
        view?.displayState(.loading)
        print("Loading weather for city:", selectedCity)
        
        weatherTask = Task { [weak self] in
            guard let self else { return }
            
            do {
                let location = try await weatherService.fetchCityLocation(for: selectedCity)
                
                try Task.checkCancellation()
                
                let forecast = try await weatherService.fetchForecast(
                    lat: location.latitude,
                    lon: location.longitude
                )
                
                try Task.checkCancellation()
                
                let viewModel = makeViewModel(from: forecast, fallbackCity: selectedCity)
                
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
        let currentDescription = currentItem?.title ?? "No data"
        
        let rows = Array(forecast.items.prefix(5)).map { item in
            WeatherModels.ForecastRow(
                dayText: formattedDay(from: item.date),
                temperatureText: formattedTemperature(item.temperature),
                descriptionText: item.title,
                humidityText: "\(item.humidity)%",
                windText: "\(Int(item.windSpeed.rounded())) m/s",
                feelsLikeText: formattedTemperature(item.feelsLike),
                pressureText: "\(item.pressure) hPa"
            )
        }
        
        return WeatherModels.ViewModel(
            city: forecast.cityName.isEmpty ? fallbackCity : forecast.cityName,
            currentTemperature: currentTemperature,
            currentDescription: currentDescription,
            rows: rows
        )
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
}
