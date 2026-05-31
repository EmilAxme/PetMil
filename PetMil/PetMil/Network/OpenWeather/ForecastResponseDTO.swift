//
//  ForecastResponseDTO.swift
//  PetMil
//
//  Created by Emil on 08.04.2026.
//

import Foundation

struct ForecastResponseDTO: Decodable {
    let list: [ForecastItemDTO]
    let city: ForecastCityDTO
}

struct ForecastItemDTO: Decodable {
    let dt: TimeInterval
    let main: ForecastMainDTO
    let weather: [ForecastWeatherDTO]
    let wind: ForecastWindDTO
    let pop: Double?
}

struct ForecastMainDTO: Decodable {
    let temp: Double
    let feelsLike: Double
    let pressure: Int
    let humidity: Int
    
    enum CodingKeys: String, CodingKey {
        case temp
        case feelsLike = "feels_like"
        case pressure
        case humidity
    }
}

struct ForecastWeatherDTO: Decodable {
    let main: String
    let description: String
    let icon: String
}

struct ForecastWindDTO: Decodable {
    let speed: Double
}

struct ForecastCityDTO: Decodable {
    let name: String
}
