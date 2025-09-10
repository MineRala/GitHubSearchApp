//
//  HomeViewModelTests.swift
//  GitHubSearchAppTests
//
//  Created by MINERALA on 31.08.2025.
//

import XCTest
@testable import GitHubSearchApp

final class HomeViewModelTests: XCTestCase {
    
    var viewModel: HomeViewModel!
    var mockDelegate: MockHomeViewControllerDelegate!
    var mockNetworkManager: MockNetworkManager!
    var mockCoreDataManager: MockCoreDataManager!
    var mockCacheManager: MockCacheManager!

    override func setUp() {
        super.setUp()
        mockDelegate = MockHomeViewControllerDelegate()
        mockNetworkManager = MockNetworkManager()
        mockCoreDataManager = MockCoreDataManager()
        mockCacheManager = MockCacheManager()

        viewModel = HomeViewModel(networkManager: mockNetworkManager,
                                  cacheManager: mockCacheManager,
                                  coreDataManager: mockCoreDataManager)
        viewModel.delegate = mockDelegate
    }

    override func tearDown() {
        viewModel = nil
        mockDelegate = nil
        mockNetworkManager = nil
        mockCoreDataManager = nil
        mockCacheManager = nil
        super.tearDown()
    }

    func testViewDidLoad_SetsIdleStateAndUpdatesUI() {
        let exp = expectation(description: "Wait for main async UI update")
        
        viewModel.viewDidLoad()
        
        DispatchQueue.main.async {
            XCTAssertTrue(self.mockDelegate.showTableCalled)
            XCTAssertEqual(self.mockDelegate.lastShowTableState, false)
            XCTAssertTrue(self.mockDelegate.showEmptyStateViewCalled)
            XCTAssertEqual(self.mockDelegate.lastShowEmptyStateViewState, true)
            XCTAssertFalse(self.mockDelegate.lastActivityIndicatorState ?? true)
            XCTAssertEqual(self.mockDelegate.lastEmptyStateType, .initialSearch)
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
    }

    func testTextDidChange_EmptyText_SetsIdleState() {
        viewModel.textDidChange(searchText: "")
        XCTAssertTrue(mockDelegate.shouldShowCancelButtonCalled)
        XCTAssertEqual(mockDelegate.lastShouldShowCancelButtonState, false)
    }

    func testTextDidChange_NonEmptyText_TriggersSearchAndSetsLoading() async {
        let searchItem = SearchItem(login: "MineRala", avatarURL: "")
        let searchResponse = SearchResponse(items: [searchItem])
        mockNetworkManager.mockResult = searchResponse
        
        viewModel.textDidChange(searchText: "MineRala")
        
        // debounce + async network
        try? await Task.sleep(nanoseconds: 600_000_000)
        
        XCTAssertTrue(mockDelegate.shouldShowCancelButtonCalled)
        XCTAssertEqual(mockDelegate.lastShouldShowCancelButtonState, true)

        XCTAssertTrue(mockDelegate.showTableCalled)
    }

    func testSearchButtonClicked_WithText_TriggersSearch() async {
        let searchItem = SearchItem(login: "MineRala", avatarURL: "")
        let searchResponse = SearchResponse(items: [searchItem])
        mockNetworkManager.mockResult = searchResponse

        viewModel.searchButtonClicked(with: "MineRala")
        
        try? await Task.sleep(nanoseconds: 100_000_000)
        
        XCTAssertTrue(mockDelegate.showTableCalled)
    }

    func testSearchCancelButtonClicked_ResetsState() {
        let exp = expectation(description: "Wait for main async UI update")
        
        viewModel.searchCancelButtonClicked()
        
        DispatchQueue.main.async {
            XCTAssertTrue(self.mockDelegate.showTableCalled)
            XCTAssertEqual(self.mockDelegate.lastShowTableState, false)
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
    }

    func testHandleFavoriteUpdated_Notification_DoesNotCrash_WhenItemsEmpty() {
        let item = SearchItem(login: "MineRala", avatarURL: "")
        XCTAssertNoThrow(
            NotificationCenter.default.post(name: .favoriteItemUpdated, object: item)
        )
    }

    func testViewWillAppear_ReloadsTableIfNeeded() {
        // When
        viewModel.viewWillAppear()

        // Then
        XCTAssertFalse(mockDelegate.tableReloadCalled)
    }
    
    func testSearchBarTextDidBeginEditing_NonEmptyText_ShowsCancelButton() {
        // Given
        let searchText = "MineRala"
        
        // When
        viewModel.searchBarTextDidBeginEditing(text: searchText)
        
        // Then
        XCTAssertTrue(mockDelegate.shouldShowCancelButtonCalled)
        XCTAssertEqual(mockDelegate.lastShouldShowCancelButtonState, true)
    }

    func testSearchBarTextDidBeginEditing_EmptyText_DoesNotShowCancelButton() {
        // Given
        let searchText = ""
        
        // When
        viewModel.searchBarTextDidBeginEditing(text: searchText)
        
        // Then
        XCTAssertFalse(mockDelegate.shouldShowCancelButtonCalled)
    }
}
