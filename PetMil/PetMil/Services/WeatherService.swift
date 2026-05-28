//
//  WeatherService.swift
//  PetMil
//
//  Created by Emil on 08.04.2026.
//

import Foundation

protocol WeatherServiceProtocol: AnyObject {
    func fetchCityLocation(for city: String) async throws -> CityLocation
    func fetchForecast(lat: Double, lon: Double) async throws -> Forecast
}

final class WeatherService: WeatherServiceProtocol {
    
    private let networkClient: NetworkClientProtocol
    private let apiKey: String
    
    init(
        networkClient: NetworkClientProtocol,
        apiKey: String
    ) {
        self.networkClient = networkClient
        self.apiKey = apiKey
    }
}

extension WeatherService {
    func fetchCityLocation(for city: String) async throws -> CityLocation {
        let endpoint = OpenWeatherEndpoint.geocoding(city: city, apiKey: apiKey)
        let response = try await networkClient.request(endpoint, type: [GeocodingResponseDTO].self)
        
        guard let firstCity = response.first else {
            throw APIError.requestFailed
        }
        
        return CityLocation(
            name: firstCity.name,
            latitude: firstCity.lat,
            longitude: firstCity.lon,
            country: firstCity.country
        )
    }
    
    func fetchForecast(lat: Double, lon: Double) async throws -> Forecast {
            let endpoint = OpenWeatherEndpoint.forecast(lat: lat, lon: lon, apiKey: apiKey)
            let response = try await networkClient.request(endpoint, type: ForecastResponseDTO.self)
            
            let items = response.list.map {
                ForecastItem(
                    date: Date(timeIntervalSince1970: $0.dt),
                    temperature: $0.main.temp,
                    feelsLike: $0.main.feelsLike,
                    pressure: $0.main.pressure,
                    humidity: $0.main.humidity,
                    windSpeed: $0.wind.speed,
                    title: $0.weather.first?.main ?? "",
                    description: $0.weather.first?.description ?? "",
                    iconCode: $0.weather.first?.icon ?? "",
                    precipitationProbability: $0.pop
                )
            }
            
            return Forecast(
                cityName: response.city.name,
                items: items
            )
        }
}
