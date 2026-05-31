//
//  WeatherIconService.swift
//  PetMil
//
//  Created by Emil on 10.04.2026.
//

import UIKit

protocol WeatherIconServiceProtocol: AnyObject {
    func loadIcon(into imageView: UIImageView, iconCode: String?)
}

final class WeatherIconService: WeatherIconServiceProtocol {

    private let cache = NSCache<NSString, UIImage>()

    func loadIcon(into imageView: UIImageView, iconCode: String?) {
        imageView.image = nil

        guard let iconCode else { return }

        if let symbolName = WeatherSymbolMapper.symbolName(for: iconCode) {
            imageView.preferredSymbolConfiguration = UIImage.SymbolConfiguration
                .preferringMulticolor()
            imageView.image = UIImage(systemName: symbolName)
            return
        }

        let cacheKey = NSString(string: iconCode)

        if let cachedImage = cache.object(forKey: cacheKey) {
            imageView.image = cachedImage
            return
        }

        guard let url = URL(string: "https://openweathermap.org/img/wn/\(iconCode)@2x.png") else {
            return
        }

        Task {
            do {
                let (data, _) = try await URLSession.shared.data(from: url)

                guard let image = UIImage(data: data) else { return }

                cache.setObject(image, forKey: cacheKey)

                await MainActor.run {
                    imageView.image = image
                }
            } catch {
                print("Failed to load weather icon:", error.localizedDescription)
            }
        }
    }
}
