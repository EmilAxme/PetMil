//
//  OpenWeatherEndpoint.swift
//  PetMil
//
//  Created by Emil on 08.04.2026.
//

import Foundation

enum OpenWeatherEndpoint {
    case citySearch(query: String, apiKey: String)
    case geocoding(city: String, apiKey: String)
    case reverseGeocoding(lat: Double, lon: Double, apiKey: String)
    case currentWeather(lat: Double, lon: Double, apiKey: String)
    case forecast(lat: Double, lon: Double, apiKey: String)
}

extension OpenWeatherEndpoint: Endpoint {
    var host: String {
        "api.openweathermap.org"
    }

    var path: String {
        switch self {
        case .citySearch, .geocoding:
            return "/geo/1.0/direct"
        case .reverseGeocoding:
            return "/geo/1.0/reverse"
        case .currentWeather:
            return "/data/2.5/weather"
        case .forecast:
            return "/data/2.5/forecast"
        }
    }

    var method: HTTPMethod {
        switch self {
        case .citySearch, .geocoding, .reverseGeocoding, .currentWeather, .forecast:
            return .get
        }
    }

    var queryItems: [URLQueryItem] {
        switch self {
        case let .citySearch(query, apiKey):
            return [
                URLQueryItem(name: "q", value: query),
                URLQueryItem(name: "limit", value: "5"),
                URLQueryItem(name: "appid", value: apiKey)
            ]

        case let .geocoding(city, apiKey):
            return [
                URLQueryItem(name: "q", value: city),
                URLQueryItem(name: "limit", value: "1"),
                URLQueryItem(name: "appid", value: apiKey)
            ]

        case let .reverseGeocoding(lat, lon, apiKey):
            return [
                URLQueryItem(name: "lat", value: String(lat)),
                URLQueryItem(name: "lon", value: String(lon)),
                URLQueryItem(name: "limit", value: "1"),
                URLQueryItem(name: "appid", value: apiKey)
            ]

        case let .currentWeather(lat, lon, apiKey):
            return [
                URLQueryItem(name: "lat", value: String(lat)),
                URLQueryItem(name: "lon", value: String(lon)),
                URLQueryItem(name: "appid", value: apiKey),
                URLQueryItem(name: "units", value: "metric"),
                URLQueryItem(name: "lang", value: L10n.shared.language.rawValue)
            ]

        case let .forecast(lat, lon, apiKey):
            return [
                URLQueryItem(name: "lat", value: String(lat)),
                URLQueryItem(name: "lon", value: String(lon)),
                URLQueryItem(name: "appid", value: apiKey),
                URLQueryItem(name: "units", value: "metric"),
                URLQueryItem(name: "lang", value: L10n.shared.language.rawValue)
            ]
        }
    }
}
