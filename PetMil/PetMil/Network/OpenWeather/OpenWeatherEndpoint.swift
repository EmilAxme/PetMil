//
//  OpenWeatherEndpoint.swift
//  PetMil
//
//  Created by Emil on 08.04.2026.
//

import Foundation

enum OpenWeatherEndpoint {
    case geocoding(city: String, apiKey: String)
    case forecast(lat: Double, lon: Double, apiKey: String)
}

extension OpenWeatherEndpoint: Endpoint {
    var host: String {
        "api.openweathermap.org"
    }
    
    var path: String {
        switch self {
        case .geocoding:
            return "/geo/1.0/direct"
        case .forecast:
            return "/data/2.5/forecast"
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .geocoding, .forecast:
            return .get
        }
    }
    
    var queryItems: [URLQueryItem] {
        switch self {
        case let .geocoding(city, apiKey):
            return [
                URLQueryItem(name: "q", value: city),
                URLQueryItem(name: "limit", value: "1"),
                URLQueryItem(name: "appid", value: apiKey)
            ]
        case let .forecast(lat, lon, apiKey):
            return [
                URLQueryItem(name: "lat", value: String(lat)),
                URLQueryItem(name: "lon", value: String(lon)),
                URLQueryItem(name: "appid", value: apiKey),
                URLQueryItem(name: "units", value: "metric")
            ]
        }
    }
}
