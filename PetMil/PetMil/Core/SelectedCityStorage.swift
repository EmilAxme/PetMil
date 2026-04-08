//
//  SelectedCityStorage.swift
//  PetMil
//
//  Created by Emil on 08.04.2026.
//

import Foundation

protocol SelectedCityStorageProtocol: AnyObject {
    var selectedCity: String { get set }
}

final class SelectedCityStorage: SelectedCityStorageProtocol {
    
    static let shared = SelectedCityStorage()
    
    var selectedCity: String = "Moscow"
    
    private init() {}
}
