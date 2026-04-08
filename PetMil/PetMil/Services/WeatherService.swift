//
//  WeatherService.swift
//  PetMil
//
//  Created by Emil on 08.04.2026.
//

import Foundation

protocol WeatherServiceProtocol: AnyObject {
    func fetchCityLocation(for city: String) async throws -> CityLocation
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
}
