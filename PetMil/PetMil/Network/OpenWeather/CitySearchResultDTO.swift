//
//  CitySearchResultDTO.swift
//  PetMil
//
//  Created by Emil on 11.04.2026.
//

import Foundation

struct CitySearchResultDTO: Decodable {
    let name: String
    let lat: Double
    let lon: Double
    let country: String
    let state: String?
}
