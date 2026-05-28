//
//  CityListStorage.swift
//  PetMil
//
//  Created by Emil on 29.05.2026.
//

import Foundation

extension Notification.Name {
    static let cityListDidChange = Notification.Name("PetMil.cityListDidChange")
}

private struct CityListSnapshot: Codable {
    let cities: [SelectedCity]
    let activeIndex: Int
}

protocol CityListStorageProtocol: AnyObject {
    var cities: [SelectedCity] { get }
    var activeIndex: Int { get set }
    var activeCity: SelectedCity? { get }
    var hasAnyCity: Bool { get }

    func appendCity(_ city: SelectedCity)
    func updateCity(at index: Int, _ city: SelectedCity)
    func removeCity(at index: Int)
    func upsertCurrentLocation(_ city: SelectedCity)
}

final class CityListStorage: CityListStorageProtocol {

    static let shared = CityListStorage()

    private let userDefaults: UserDefaults
    private let storageKey = "city_list_storage_v2"
    private let legacyKey = "selected_city_key"

    private var snapshot: CityListSnapshot

    var cities: [SelectedCity] { snapshot.cities }

    var activeIndex: Int {
        get { snapshot.activeIndex }
        set {
            let clamped = max(0, min(newValue, max(snapshot.cities.count - 1, 0)))
            guard clamped != snapshot.activeIndex else { return }
            snapshot = CityListSnapshot(cities: snapshot.cities, activeIndex: clamped)
            persist()
        }
    }

    var activeCity: SelectedCity? {
        guard snapshot.cities.indices.contains(snapshot.activeIndex) else {
            return snapshot.cities.first
        }
        return snapshot.cities[snapshot.activeIndex]
    }

    var hasAnyCity: Bool { !snapshot.cities.isEmpty }

    private init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
        self.snapshot = CityListStorage.loadInitial(userDefaults: userDefaults, storageKey: storageKey, legacyKey: legacyKey)
    }

    func appendCity(_ city: SelectedCity) {
        guard !city.isCurrentLocation else {
            upsertCurrentLocation(city)
            return
        }

        var newCities = snapshot.cities
        newCities.append(city)
        snapshot = CityListSnapshot(cities: newCities, activeIndex: newCities.count - 1)
        persist()
    }

    func updateCity(at index: Int, _ city: SelectedCity) {
        guard snapshot.cities.indices.contains(index) else { return }
        var newCities = snapshot.cities
        newCities[index] = city
        snapshot = CityListSnapshot(cities: newCities, activeIndex: snapshot.activeIndex)
        persist()
    }

    func removeCity(at index: Int) {
        guard snapshot.cities.indices.contains(index) else { return }
        var newCities = snapshot.cities
        newCities.remove(at: index)
        let newActive: Int
        if newCities.isEmpty {
            newActive = 0
        } else if index < snapshot.activeIndex {
            newActive = max(0, snapshot.activeIndex - 1)
        } else if index == snapshot.activeIndex {
            newActive = min(snapshot.activeIndex, newCities.count - 1)
        } else {
            newActive = min(snapshot.activeIndex, newCities.count - 1)
        }
        snapshot = CityListSnapshot(cities: newCities, activeIndex: newActive)
        persist()
    }

    func upsertCurrentLocation(_ city: SelectedCity) {
        var newCities = snapshot.cities
        let gpsCity = SelectedCity(
            name: city.name,
            country: city.country,
            latitude: city.latitude,
            longitude: city.longitude,
            photoURLString: city.photoURLString,
            isCurrentLocation: true
        )

        if let firstIndex = newCities.firstIndex(where: { $0.isCurrentLocation }) {
            newCities[firstIndex] = gpsCity
            snapshot = CityListSnapshot(cities: newCities, activeIndex: firstIndex)
        } else {
            newCities.insert(gpsCity, at: 0)
            snapshot = CityListSnapshot(cities: newCities, activeIndex: 0)
        }
        persist()
    }
}

private extension CityListStorage {
    static func loadInitial(userDefaults: UserDefaults, storageKey: String, legacyKey: String) -> CityListSnapshot {
        if let data = userDefaults.data(forKey: storageKey),
           let decoded = try? JSONDecoder().decode(CityListSnapshot.self, from: data) {
            return decoded
        }

        if let legacyData = userDefaults.data(forKey: legacyKey),
           let legacyCity = try? JSONDecoder().decode(SelectedCity.self, from: legacyData) {
            userDefaults.removeObject(forKey: legacyKey)
            let migrated = CityListSnapshot(cities: [legacyCity], activeIndex: 0)
            if let encoded = try? JSONEncoder().encode(migrated) {
                userDefaults.set(encoded, forKey: storageKey)
            }
            return migrated
        }

        return CityListSnapshot(cities: [], activeIndex: 0)
    }

    func persist() {
        guard let data = try? JSONEncoder().encode(snapshot) else { return }
        userDefaults.set(data, forKey: storageKey)
        NotificationCenter.default.post(name: .cityListDidChange, object: nil)
    }
}
