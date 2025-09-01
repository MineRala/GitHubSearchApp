//
//  FavoritesViewModelTests.swift
//  GitHubSearchAppTests
//
//  Created by MINERALA on 31.08.2025.
//

import XCTest
import CoreData
@testable import GitHubSearchApp

final class FavoritesViewModelTests: XCTestCase {
    
    var viewModel: FavoritesViewModel!
    var mockNetworkManager: MockNetworkManager!
    var mockCacheManager: MockCacheManager!
    var mockCoreDataManager: MockCoreDataManager!
    var mockDelegate: MockFavoritesViewControllerDelegate!
    
    override func setUp() {
        super.setUp()
        mockNetworkManager = MockNetworkManager()
        mockCacheManager = MockCacheManager()
        mockCoreDataManager = MockCoreDataManager()
        mockDelegate = MockFavoritesViewControllerDelegate()
        
        viewModel = FavoritesViewModel(networkManager: mockNetworkManager,
                                       cacheManager: mockCacheManager,
                                       coreDataManager: mockCoreDataManager)
        viewModel.delegate = mockDelegate
    }
    
    override func tearDown() {
        viewModel = nil
        mockNetworkManager = nil
        mockCacheManager = nil
        mockCoreDataManager = nil
        mockDelegate = nil
        super.tearDown()
    }
    
    func testViewDidLoad_FetchesFavoritesAndUpdatesUI() {
        let container = NSPersistentContainer(name: AppStrings.favoriteEntityName)
        let description = NSPersistentStoreDescription()
        description.type = NSInMemoryStoreType
        container.persistentStoreDescriptions = [description]
        container.loadPersistentStores { (_, error) in
            XCTAssertNil(error, "In-memory store should load without error")
        }
        let context = container.viewContext

        // Given
        let favoriteItem = FavoriteUser(context: context)
        favoriteItem.login = "User1"
        favoriteItem.avatarURL = "https://example.com/avatar.png"

        mockCoreDataManager.stubFavorites = [favoriteItem]

        // When
        viewModel.viewDidLoad()

        // Then
        let expectation = expectation(description: "Delegate updates")
        DispatchQueue.main.async {
            XCTAssertFalse(self.mockDelegate.lastEmptyStateValue ?? true, "Empty state should be false")
            XCTAssertTrue(self.mockDelegate.tableReloadCalled, "Table reload should be called")
            XCTAssertEqual(self.viewModel.allFavoritesCount, 1)

            let item = self.viewModel.getItem(index: 0)
            XCTAssertEqual(item.login, "User1")
            XCTAssertEqual(item.avatarURL, "https://example.com/avatar.png")
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testFetchFavorites_WhenEmpty_UpdatesEmptyState() {
        // Given
        mockCoreDataManager.stubFavorites = []
        
        // When
        viewModel.viewDidLoad()
        
        // Then
        let expectation = expectation(description: "Empty state delegate called")
        DispatchQueue.main.async {
            XCTAssertTrue(self.mockDelegate.lastEmptyStateValue ?? false, "Empty state should be true")
            XCTAssertFalse(self.mockDelegate.tableReloadCalled, "Table reload should not be called")
            XCTAssertEqual(self.viewModel.allFavoritesCount, 0)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testGetItem_ReturnsCorrectSearchItem() {
        let container = NSPersistentContainer(name: AppStrings.favoriteEntityName)
        let description = NSPersistentStoreDescription()
        description.type = NSInMemoryStoreType
        container.persistentStoreDescriptions = [description]
        container.loadPersistentStores { _, error in
            XCTAssertNil(error)
        }
        let context = container.viewContext
        
        let favoriteItem = FavoriteUser(context: context)
        favoriteItem.login = "User2"
        favoriteItem.avatarURL = "https://example.com/avatar2.png"
        
        mockCoreDataManager.stubFavorites = [favoriteItem]
        
        // Test
        viewModel.viewDidLoad()
        
        let expectation = expectation(description: "Get item after fetch")
        DispatchQueue.main.async {
            let item = self.viewModel.getItem(index: 0)
            XCTAssertEqual(item.login, "User2")
            XCTAssertEqual(item.avatarURL, "https://example.com/avatar2.png")
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testViewDidLoad_WithNilDelegate_DoesNotCrash() {
        // Given
        viewModel.delegate = nil
        mockCoreDataManager.stubFavorites = []
        
        // When / Then
        XCTAssertNoThrow(viewModel.viewDidLoad())
        XCTAssertEqual(viewModel.allFavoritesCount, 0)
    }
    
    func testAllFavoritesCount_AfterUpdatingList() {
        let container = NSPersistentContainer(name: AppStrings.favoriteEntityName)
        let description = NSPersistentStoreDescription()
        description.type = NSInMemoryStoreType
        container.persistentStoreDescriptions = [description]
        container.loadPersistentStores { (desc, error) in
            XCTAssertNil(error)
        }
        let context = container.viewContext

        let favorite1 = FavoriteUser(context: context)
        favorite1.login = "User1"
        favorite1.avatarURL = "https://example.com/1.png"

        let favorite2 = FavoriteUser(context: context)
        favorite2.login = "User2"
        favorite2.avatarURL = "https://example.com/2.png"

        mockCoreDataManager.stubFavorites = [favorite1, favorite2]

        viewModel.viewDidLoad()

        let expectation = expectation(description: "AllFavoritesCount updated")
        DispatchQueue.main.async {
            XCTAssertEqual(self.viewModel.allFavoritesCount, 2)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
    }
}
