//
//  CitySearchService.swift
//  PetMil
//
//  Created by Emil on 11.04.2026.
//

import Foundation

protocol CitySearchServiceProtocol: AnyObject {
    func searchCities(query: String) async throws -> [CitySearchModels.City]
}

final class CitySearchService: CitySearchServiceProtocol {
    
    private let networkClient: NetworkClientProtocol
    private let apiKey: String
    
    init(
        networkClient: NetworkClientProtocol,
        apiKey: String
    ) {
        self.networkClient = networkClient
        self.apiKey = apiKey
    }
    
    func searchCities(query: String) async throws -> [CitySearchModels.City] {
        let endpoint = OpenWeatherEndpoint.citySearch(query: query, apiKey: apiKey)
        let response = try await networkClient.request(endpoint, type: [CitySearchResultDTO].self)
        
        return response.map {
            CitySearchModels.City(
                name: $0.name,
                country: $0.country,
                state: $0.state,
                latitude: $0.lat,
                longitude: $0.lon
            )
        }
    }
}
