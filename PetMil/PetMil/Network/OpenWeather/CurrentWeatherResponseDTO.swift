//
//  CurrentWeatherResponseDTO.swift
//  PetMil
//
//  Created by Emil on 29.05.2026.
//

import Foundation

struct CurrentWeatherResponseDTO: Decodable {
    let main: CurrentMainDTO
    let wind: CurrentWindDTO
    let clouds: CurrentCloudsDTO?
    let visibility: Int?
    let sys: CurrentSysDTO
    let weather: [ForecastWeatherDTO]
}

struct CurrentMainDTO: Decodable {
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

struct CurrentWindDTO: Decodable {
    let speed: Double
    let deg: Int?
}

struct CurrentCloudsDTO: Decodable {
    let all: Int
}

struct CurrentSysDTO: Decodable {
    let sunrise: TimeInterval
    let sunset: TimeInterval
}
