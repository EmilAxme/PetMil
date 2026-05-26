//
//  GeocodingResponseDTO.swift
//  PetMil
//
//  Created by Emil on 08.04.2026.
//

import Foundation

struct GeocodingResponseDTO: Decodable {
    let name: String
    let lat: Double
    let lon: Double
    let country: String
}
