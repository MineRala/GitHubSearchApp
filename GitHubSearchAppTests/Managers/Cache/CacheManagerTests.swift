//
//  CacheManagerTests.swift
//  GitHubSearchAppTests
//
//  Created by MINERALA on 31.08.2025.
//

import XCTest
@testable import GitHubSearchApp
import UIKit

final class CacheManagerTests: XCTestCase {

    var cacheManager: CacheManager!

    override func setUp() {
        super.setUp()
        cacheManager = CacheManager()
    }

    override func tearDown() {
        cacheManager = nil
        super.tearDown()
    }

    // MARK: - Cache & Get Tests

    func testCacheImage_SetsAndGetImageReturnsSameImage() {
        // Given
        let url = "https://example.com/image.png"
        let image = UIImage(systemName: "person.circle")!

        // When
        cacheManager.cacheImage(image, for: url)
        let returnedImage = cacheManager.getImage(for: url)

        // Then
        XCTAssertNotNil(returnedImage, "Image should be returned from cache")
        XCTAssertEqual(returnedImage?.pngData(), image.pngData(), "Returned image should match cached image")
    }

    func testGetImage_ForNonCachedURL_ReturnsNil() {
        let url = "https://example.com/nonexistent.png"
        let image = cacheManager.getImage(for: url)
        XCTAssertNil(image, "Image should be nil for URL not cached")
    }

    // MARK: - Async Load Tests

    func testLoadImage_FromCache_ReturnsCachedData() async {
        // Given
        let url = "https://example.com/cached.png"
        let image = UIImage(systemName: "star.fill")!
        cacheManager.cacheImage(image, for: url)

        // When
        let data = await cacheManager.loadImage(from: url)

        // Then
        XCTAssertNotNil(data, "Data should be returned for cached image")
        XCTAssertEqual(data, image.pngData(), "Returned data should match cached image")
    }

    func testLoadImage_FromValidURL_ReturnsData() async {
        // Given
        let url = "https://avatars.githubusercontent.com/u/47946453?v=4"

        // When
        let data = await cacheManager.loadImage(from: url)

        // Then
        XCTAssertNotNil(data, "Data should be returned from valid URL")
    }

    func testLoadImage_FromInvalidURL_ReturnsNil() async {
        // Given
        let url = "invalid-url"

        // When
        let data = await cacheManager.loadImage(from: url)

        // Then
        XCTAssertNil(data, "Data should be nil for invalid URL")
    }

    func testLoadImage_FromNonImageData_ReturnsNil() async {
        // Given
        let url = "https://www.example.com"

        // When
        let data = await cacheManager.loadImage(from: url)

        // Then
        XCTAssertNil(data, "Data should be nil if downloaded data cannot be converted to UIImage")
    }
}
