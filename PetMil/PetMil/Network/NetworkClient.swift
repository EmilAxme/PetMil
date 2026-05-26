//
//  NetworkClient.swift
//  PetMil
//
//  Created by Emil on 08.04.2026.
//

import Foundation

protocol NetworkClientProtocol: AnyObject {
    func request<T: Decodable>(_ endpoint: Endpoint, type: T.Type) async throws -> T
}

final class NetworkClient: NetworkClientProtocol {
    
    private let session: URLSession
    
    init(session: URLSession? = nil) {
        if let session {
            self.session = session
        } else {
            let configuration = URLSessionConfiguration.default
            configuration.timeoutIntervalForRequest = 30
            configuration.timeoutIntervalForResource = 60
            self.session = URLSession(configuration: configuration)
        }
    }
}

extension NetworkClient {
    func request<T: Decodable>(_ endpoint: Endpoint, type: T.Type) async throws -> T {
        guard let urlRequest = try? makeURLRequest(from: endpoint) else {
            throw APIError.invalidURL
        }
        
        let (data, response): (Data, URLResponse)
        
        do {
            (data, response) = try await session.data(for: urlRequest)
        } catch {
            throw APIError.requestFailed
        }
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        
        guard 200...299 ~= httpResponse.statusCode else {
            throw APIError.serverError(statusCode: httpResponse.statusCode)
        }
        
        do {
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            throw APIError.decodingFailed
        }
    }
}

private extension NetworkClient {
    func makeURLRequest(from endpoint: Endpoint) throws -> URLRequest {
        var components = URLComponents()
        components.scheme = endpoint.scheme
        components.host = endpoint.host
        components.path = endpoint.path
        components.queryItems = endpoint.queryItems
        
        guard let url = components.url else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method.rawValue
        return request
    }
}
