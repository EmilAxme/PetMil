//
//  UnsplashSearchService..swift
//  PetMil
//
//  Created by Emil on 15.04.2026.
//

import Foundation

protocol UnsplashSearchServiceProtocol: AnyObject {
    func searchPhoto(for cityName: String) async throws -> CityPhotoPreview?
}

final class UnsplashSearchService: UnsplashSearchServiceProtocol {
    
    private let networkClient: NetworkClientProtocol
    private let accessKey: String
    
    init(
        networkClient: NetworkClientProtocol,
        accessKey: String
    ) {
        self.networkClient = networkClient
        self.accessKey = accessKey
    }
    
    func searchPhoto(for cityName: String) async throws -> CityPhotoPreview? {
        let endpoint = UnsplashEndpoint.searchPhotos(query: cityName, accessKey: accessKey)
        let response = try await networkClient.request(endpoint, type: UnsplashPhotoSearchResponseDTO.self)
        
        guard
            let first = response.results.first,
            let imageURL = URL(string: first.urls.regular),
            let authorProfileURL = URL(string: first.user.links.html),
            let photoPageURL = URL(string: first.links.html)
        else {
            return nil
        }
        
        return CityPhotoPreview(
            imageURL: imageURL,
            authorName: first.user.name,
            authorProfileURL: authorProfileURL,
            photoPageURL: photoPageURL
        )
    }
}
