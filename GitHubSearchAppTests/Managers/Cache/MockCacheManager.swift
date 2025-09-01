//
//  MockCacheManager.swift
//  GitHubSearchAppTests
//
//  Created by MINERALA on 31.08.2025.
//

import UIKit
@testable import GitHubSearchApp

final class MockCacheManager: CacheManagerProtocol {
    
    var getImageCalled = false
    var cacheImageCalled = false
    var loadImageCalled = false
    
    var stubbedImage: UIImage?
    var stubbedData: Data?

    func getImage(for url: String) -> UIImage? {
        getImageCalled = true
        return stubbedImage
    }
    
    func cacheImage(_ image: UIImage, for url: String) {
        cacheImageCalled = true
    }
    
    func loadImage(from url: String) async -> Data? {
        loadImageCalled = true
        return stubbedData
    }
}

