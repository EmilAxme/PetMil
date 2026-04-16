//
//  UnsplashEndpoint.swift
//  PetMil
//
//  Created by Emil on 15.04.2026.
//

import Foundation

enum UnsplashEndpoint {
    case searchPhotos(query: String, accessKey: String)
}

extension UnsplashEndpoint: Endpoint {
    var scheme: String { "https" }
    
    var host: String {
        "api.unsplash.com"
    }
    
    var path: String {
        switch self {
        case .searchPhotos:
            return "/search/photos"
        }
    }
    
    var method: HTTPMethod {
        .get
    }
    
    var queryItems: [URLQueryItem] {
        switch self {
        case let .searchPhotos(query, accessKey):
            return [
                URLQueryItem(name: "query", value: query),
                URLQueryItem(name: "per_page", value: "1"),
                URLQueryItem(name: "client_id", value: accessKey)
            ]
        }
    }
}
