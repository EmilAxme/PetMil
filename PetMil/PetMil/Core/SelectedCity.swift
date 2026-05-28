//
//  SelectedCity.swift
//  PetMil
//
//  Created by Emil on 08.04.2026.
//

import Foundation

struct SelectedCity: Codable {
    let name: String
    let country: String
    let latitude: Double
    let longitude: Double
    let photoURLString: String?
    let isCurrentLocation: Bool

    init(
        name: String,
        country: String,
        latitude: Double,
        longitude: Double,
        photoURLString: String?,
        isCurrentLocation: Bool = false
    ) {
        self.name = name
        self.country = country
        self.latitude = latitude
        self.longitude = longitude
        self.photoURLString = photoURLString
        self.isCurrentLocation = isCurrentLocation
    }

    enum CodingKeys: String, CodingKey {
        case name, country, latitude, longitude, photoURLString, isCurrentLocation
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decode(String.self, forKey: .name)
        country = try container.decode(String.self, forKey: .country)
        latitude = try container.decode(Double.self, forKey: .latitude)
        longitude = try container.decode(Double.self, forKey: .longitude)
        photoURLString = try container.decodeIfPresent(String.self, forKey: .photoURLString)
        isCurrentLocation = try container.decodeIfPresent(Bool.self, forKey: .isCurrentLocation) ?? false
    }
}
