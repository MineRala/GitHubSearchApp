//
//  CacheManager.swift
//  GitHubSearchApp
//
//  Created by MINERALA on 29.08.2025.
//

import UIKit

protocol CacheManagerProtocol {
    func getImage(for url: String) -> UIImage?
    func cacheImage(_ image: UIImage, for url: String)
    func loadImage(from url: String, completion: @escaping (UIImage?) -> Void)
}

final class CacheManager: CacheManagerProtocol {
    private let imageCache = NSCache<NSString, UIImage>()

    func getImage(for url: String) -> UIImage? {
        return imageCache.object(forKey: url as NSString)
    }

    func cacheImage(_ image: UIImage, for url: String) {
        imageCache.setObject(image, forKey: url as NSString)
    }

    func loadImage(from url: String, completion: @escaping (UIImage?) -> Void) {
        if let cachedImage = getImage(for: url) {
            completion(cachedImage)
            return
        }

        guard let imageURL = URL(string: url) else {
            completion(nil)
            return
        }

        URLSession.shared.dataTask(with: imageURL) { data, _, error in
            guard let data = data, let image = UIImage(data: data), error == nil else {
                completion(nil)
                return
            }

            self.cacheImage(image, for: url)

            DispatchQueue.main.async {
                completion(image)
            }
        }.resume()
    }
}
