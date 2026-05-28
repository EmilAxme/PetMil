//
//  CitySearchModels.swift
//  PetMil
//
//  Created by Emil on 11.03.2026.
//

import Foundation

enum CitySearchModels {
    struct City {
        let name: String
        let country: String
        let state: String?
        let latitude: Double
        let longitude: Double
    }

    struct ViewModel {
        let cities: [City]
    }

    enum ListContent {
        case savedCities([SavedRow])
        case searchResults([City])
        case empty(message: String)
    }

    struct SavedRow {
        let name: String
        let countryOrLocation: String
        let isCurrentLocation: Bool
    }
}
