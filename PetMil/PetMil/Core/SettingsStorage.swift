//
//  SettingsStorage.swift
//  PetMil
//
//  Created by Emil on 29.05.2026.
//

import Foundation

extension Notification.Name {
    static let unitPreferencesDidChange = Notification.Name("PetMil.unitPreferencesDidChange")
}

protocol SettingsStorageProtocol: AnyObject {
    var preferences: UnitPreferences { get set }
}

final class SettingsStorage: SettingsStorageProtocol {

    static let shared = SettingsStorage()

    private let userDefaults: UserDefaults
    private let preferencesKey = "unit_preferences_v1"
    private var cachedPreferences: UnitPreferences

    private init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
        if let data = userDefaults.data(forKey: preferencesKey),
           let decoded = try? JSONDecoder().decode(UnitPreferences.self, from: data) {
            self.cachedPreferences = decoded
        } else {
            self.cachedPreferences = .default
        }
    }

    var preferences: UnitPreferences {
        get { cachedPreferences }
        set {
            guard newValue != cachedPreferences else { return }
            cachedPreferences = newValue
            if let data = try? JSONEncoder().encode(newValue) {
                userDefaults.set(data, forKey: preferencesKey)
            }
            NotificationCenter.default.post(name: .unitPreferencesDidChange, object: nil)
        }
    }
}
