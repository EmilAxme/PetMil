//
//  UnsplashDTO.swift
//  PetMil
//
//  Created by Emil on 15.04.2026.
//

import Foundation

struct UnsplashPhotoSearchResponseDTO: Decodable {
    let results: [UnsplashPhotoDTO]
}

struct UnsplashPhotoDTO: Decodable {
    let urls: UnsplashPhotoURLsDTO
    let user: UnsplashUserDTO
    let links: UnsplashPhotoLinksDTO
}

struct UnsplashPhotoURLsDTO: Decodable {
    let regular: String
    let small: String
}

struct UnsplashUserDTO: Decodable {
    let name: String
    let links: UnsplashUserLinksDTO
}

struct UnsplashUserLinksDTO: Decodable {
    let html: String
}

struct UnsplashPhotoLinksDTO: Decodable {
    let html: String
}
