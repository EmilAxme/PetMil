//
//  SelectedCityStorage.swift
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

protocol SelectedCityStorageProtocol: AnyObject {
    var selectedCity: SelectedCity { get set }
    var hasSelectedCity: Bool { get }
}

final class SelectedCityStorage: SelectedCityStorageProtocol {
    
    static let shared = SelectedCityStorage()
    
    private let userDefaults: UserDefaults
    private let selectedCityKey = "selected_city_key"
    
    private let defaultCity = SelectedCity(
        name: "Moscow",
        country: "RU",
        latitude: 55.7504461,
        longitude: 37.6174943,
        photoURLString: nil,
        isCurrentLocation: false
    )
    
    var selectedCity: SelectedCity {
        get {
            guard
                let data = userDefaults.data(forKey: selectedCityKey),
                let city = try? JSONDecoder().decode(SelectedCity.self, from: data)
            else {
                return defaultCity
            }
            
            return city
        }
        set {
            guard let data = try? JSONEncoder().encode(newValue) else { return }
            userDefaults.set(data, forKey: selectedCityKey)
        }
    }
    
    var hasSelectedCity: Bool {
        userDefaults.data(forKey: selectedCityKey) != nil
    }

    private init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }
}
