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
        let preview: Preview?
    }
    
    struct Preview {
        let imageURL: URL
        let authorName: String
        let authorProfileURL: URL
        let photoPageURL: URL
    }
}
