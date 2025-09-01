//
//  CacheManager.swift
//  GitHubSearchApp
//
//  Created by MINERALA on 29.08.2025.
//

import UIKit

// MARK: - CacheManagerProtocol
protocol CacheManagerProtocol {
    func getImage(for url: String) -> UIImage?
    func cacheImage(_ image: UIImage, for url: String)
    func loadImage(from url: String) async -> Data?
}

// MARK: - CacheManager
final class CacheManager: CacheManagerProtocol {
    private let imageCache = NSCache<NSString, UIImage>()
    
    func getImage(for url: String) -> UIImage? {
        return imageCache.object(forKey: url as NSString)
    }
    
    func cacheImage(_ image: UIImage, for url: String) {
        imageCache.setObject(image, forKey: url as NSString)
    }
    
    func loadImage(from url: String) async -> Data? {
        if let cachedImage = getImage(for: url) {
            return cachedImage.pngData()
        }
        
        guard let imageURL = URL(string: url) else { return nil }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: imageURL)
            if let image = UIImage(data: data) {
                cacheImage(image, for: url)
                return image.pngData()
            } else {
                return nil
            }
        } catch {
            return nil
        }
    }
}
