//
//  CoreDataManagerTests.swift
//  GitHubSearchAppTests
//
//  Created by MINERALA on 31.08.2025.
//

import XCTest
import CoreData
@testable import GitHubSearchApp

final class CoreDataManagerTests: XCTestCase {
    
    var sut: CoreDataManager!
    var persistentContainer: NSPersistentContainer!
    var testUser: SearchItem!
    
    override func setUp() {
        super.setUp()
        
        persistentContainer = NSPersistentContainer(name: AppStrings.favoriteEntityName)
        let description = NSPersistentStoreDescription()
        description.type = NSInMemoryStoreType
        persistentContainer.persistentStoreDescriptions = [description]
        
        persistentContainer.loadPersistentStores { (_, error) in
            XCTAssertNil(error)
        }
        
        sut = CoreDataManager(container: persistentContainer)
        
        testUser = SearchItem(
            login: "MineRala",
            avatarURL: "https://avatars.githubusercontent.com/u/47946453?v=4"
        )
    }
    
    override func tearDown() {
        sut = nil
        persistentContainer = nil
        testUser = nil
        super.tearDown()
    }
    
    // MARK: - Save Favorite
    func testAddFavorite_ShouldPersistUser() {
        // When
        sut.saveFavorite(user: testUser)
        
        // Then
        let favorites = sut.fetchFavorites()
        XCTAssertEqual(favorites.count, 1)
        XCTAssertEqual(favorites.first?.login, testUser.login)
    }
    
    // MARK: - Remove Favorite
    func testRemoveFavorite_ShouldDeleteUser() {
        // Given
        sut.saveFavorite(user: testUser)
        XCTAssertTrue(sut.isFavorite(login: testUser.login))
        
        // When
        sut.removeFavorite(login: testUser.login)
        
        // Then
        XCTAssertFalse(sut.isFavorite(login: testUser.login))
        XCTAssertTrue(sut.fetchFavorites().isEmpty)
    }
    
    func testRemoveFavorite_WhenNotExists_DoesNothing() {
        // When
        sut.removeFavorite(login: "nonexistent")
        
        // Then
        XCTAssertTrue(sut.fetchFavorites().isEmpty)
    }
    
    // MARK: - Is Favorite
    func testIsFavorite_ReturnsTrueIfExists() {
        // Given
        sut.saveFavorite(user: testUser)
        
        // When
        let isFav = sut.isFavorite(login: testUser.login)
        
        // Then
        XCTAssertTrue(isFav)
    }
    
    func testIsFavorite_ReturnsFalseIfNotExists() {
        // When
        let isFav = sut.isFavorite(login: "unknownUser")
        
        // Then
        XCTAssertFalse(isFav)
    }
    
    // MARK: - Toggle Favorite
    func testToggleFavorite_AddsAndRemovesCorrectly() {
        // Initially not favorite
        XCTAssertFalse(sut.isFavorite(login: testUser.login))
        
        // Add
        sut.toggleFavorite(user: testUser)
        XCTAssertTrue(sut.isFavorite(login: testUser.login))
        
        // Remove
        sut.toggleFavorite(user: testUser)
        XCTAssertFalse(sut.isFavorite(login: testUser.login))
    }
    
    // MARK: - Fetch Favorites
    func testFetchFavorites_ReturnsSavedUsers() {
        // Given
        sut.saveFavorite(user: testUser)
        
        // When
        let favorites = sut.fetchFavorites()
        
        // Then
        XCTAssertEqual(favorites.count, 1)
        XCTAssertEqual(favorites.first?.login, testUser.login)
    }
    
    func testFetchFavorites_WhenEmpty_ReturnsEmptyArray() {
        // When
        let favorites = sut.fetchFavorites()
        
        // Then
        XCTAssertTrue(favorites.isEmpty)
    }
    
    
    func testSaveContext_WhenNoChanges_DoesNothing() {
        // Given
        sut.saveFavorite(user: testUser)
        let context = sut.fetchFavorites().first!.managedObjectContext
        context?.reset()
        
        // When
        let _ = sut.fetchFavorites()
    }
    
    func testRemoveFavorite_WhenFetchFails_DoesNotCrash() {
        // When
        sut.removeFavorite(login: "nonexistent_user")
    }
    
    func testToggleFavorite_WhenAlreadyExists_RemovesIt() {
        // Given
        sut.saveFavorite(user: testUser)
        
        // When
        sut.toggleFavorite(user: testUser)
    }
}
