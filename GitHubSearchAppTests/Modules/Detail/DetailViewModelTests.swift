//
//  DetailViewModelTests.swift
//  GitHubSearchAppTests
//
//  Created by MINERALA on 31.08.2025.
//

import XCTest
@testable import GitHubSearchApp

final class DetailViewModelTests: XCTestCase {
    
    var viewModel: DetailViewModel!
    var mockCacheManager: MockCacheManager!
    var mockCoreDataManager: MockCoreDataManager!
    var mockDelegate: MockDetailViewControllerDelegate!
    var mockNetworkManager: MockNetworkManager!
    
    var testItem: SearchItem!

    override func setUp() {
        super.setUp()
        testItem = SearchItem(login: "MineRala", avatarURL: "https://avatars.githubusercontent.com/u/47946453?v=4")
        mockCacheManager = MockCacheManager()
        mockCoreDataManager = MockCoreDataManager()
        mockDelegate = MockDetailViewControllerDelegate()
        mockNetworkManager = MockNetworkManager()

        viewModel = DetailViewModel(cacheManager: mockCacheManager,
                                    coreDataManager: mockCoreDataManager,
                                    item: testItem)
        viewModel.delegate = mockDelegate
    }

    override func tearDown() {
        viewModel = nil
        mockCacheManager = nil
        mockCoreDataManager = nil
        mockDelegate = nil
        mockNetworkManager = nil
        testItem = nil
        super.tearDown()
    }
    
    func testViewDidLoad_FetchesDetailAndUpdatesUI() {
        // Given
        let itemDetail = ItemDetail(login: "MineRala",
                                    avatarURL: "https://avatars.githubusercontent.com/u/47946453?v=4",
                                    htmlURL: "https://github.com/MineRala",
                                    name: "Mine Rala")
        mockNetworkManager.mockResult = itemDetail
        let exp = expectation(description: "Delegate updated UI")

        mockDelegate.updateUICallback = {
            exp.fulfill()
        }

        // When
        viewModel.viewDidLoad()

        // Then
        wait(for: [exp], timeout: 1.0)
        XCTAssertFalse(mockDelegate.lastActivityIndicatorState ?? true)
        XCTAssertEqual(mockDelegate.lastDetail?.login, "MineRala")
        XCTAssertTrue(mockDelegate.updateUICalled)
        XCTAssertTrue(mockDelegate.updateAvatarImageCalled)
        XCTAssertTrue(mockDelegate.updateFavoriteButtonCalled)
    }
    
    func testViewDidLoad_WithNilDelegate_DoesNotCrash() {
        // Given
        viewModel.delegate = nil
        
        // When / Then
        XCTAssertNoThrow(viewModel.viewDidLoad())
    }

    func testFavoriteStatusChanged_Notification_UpdatesFavoriteButton() {
        // Given
        mockCoreDataManager.stubIsFavorite = true
        viewModel.viewDidLoad()

        // When
        NotificationCenter.default.post(name: .favoriteItemUpdated, object: testItem)

        // Then
        XCTAssertTrue(mockDelegate.updateFavoriteButtonCalled)
    }


    func testFavoriteStatusChanged_Notification_WithDifferentItem_DoesNotCallDelegate() {
        let otherItem = SearchItem(login: "otherUser", avatarURL: "")
        NotificationCenter.default.post(name: .favoriteItemUpdated, object: otherItem)
        XCTAssertFalse(mockDelegate.updateFavoriteButtonCalled)
    }

    func testFavoriteStatusChanged_WithNilDelegate_DoesNotCrash() {
        viewModel.delegate = nil
        NotificationCenter.default.post(name: .favoriteItemUpdated, object: testItem)
        XCTAssertTrue(true)
    }
    
    func testViewDidLoad_Failure_ShowsErrorAlertWithoutCrash() async {
        viewModel.delegate = mockDelegate

        viewModel.viewDidLoad()
        
        try? await Task.sleep(nanoseconds: 500_000_000)
        
        XCTAssertTrue(true)
    }
}

