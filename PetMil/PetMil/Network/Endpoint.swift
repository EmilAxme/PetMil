//
//  Endpoint.swift
//  PetMil
//
//  Created by Emil on 08.04.2026.
//

import Foundation

protocol Endpoint {
    var scheme: String { get }
    var host: String { get }
    var path: String { get }
    var method: HTTPMethod { get }
    var queryItems: [URLQueryItem] { get }
}

extension Endpoint {
    var scheme: String { "https" }
}
