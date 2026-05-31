//
//  ImageLoaderService.swift
//  PetMil
//
//  Created by Emil on 26.05.2026.
//

import UIKit

protocol ImageLoaderServiceProtocol: AnyObject {
    func loadImage(from url: URL) async -> UIImage?
}

final class ImageLoaderService: ImageLoaderServiceProtocol {

    private let cache = NSCache<NSURL, UIImage>()

    func loadImage(from url: URL) async -> UIImage? {
        if let cached = cache.object(forKey: url as NSURL) {
            return cached
        }

        guard let (data, _) = try? await URLSession.shared.data(from: url),
              let image = UIImage(data: data)
        else {
            return nil
        }

        cache.setObject(image, forKey: url as NSURL)
        return image
    }
}
