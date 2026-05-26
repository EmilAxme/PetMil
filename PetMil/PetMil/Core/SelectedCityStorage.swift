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
        photoURLString: nil
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
