//
//  WeatherModels.swift
//  PetMil
//
//  Created by Emil on 09.03.2026.
//

import Foundation

enum WeatherModels {
    struct Weather: Codable {
        let screenTitle: String
        let temperature: String
        let description: String
        let city: String
    }
}
