//
//  TableViewCellViewModelTests.swift
//  GitHubSearchAppTests
//
//  Created by MINERALA on 31.08.2025.
//

import XCTest
@testable import GitHubSearchApp

final class TableViewCellViewModelTests: XCTestCase {
    
    var viewModel: TableViewCellViewModel!
    var mockCoreDataManager: MockCoreDataManager!
    var mockCacheManager: MockCacheManager!
    var mockDelegate: MockTableViewCellDelegate!
    var testUser: SearchItem!
    
    override func setUp() {
        super.setUp()
        testUser = SearchItem(login: "MineRala", avatarURL: "https://example.com/avatar.png")
        mockCoreDataManager = MockCoreDataManager()
        mockCacheManager = MockCacheManager()
        mockDelegate = MockTableViewCellDelegate()
        viewModel = TableViewCellViewModel(item: testUser,
                                           coreDataManager: mockCoreDataManager,
                                           cacheManager: mockCacheManager)
        viewModel.delegate = mockDelegate
    }
    
    override func tearDown() {
        viewModel = nil
        mockCoreDataManager = nil
        mockCacheManager = nil
        mockDelegate = nil
        testUser = nil
        super.tearDown()
    }
    
    // MARK: - Image Task
    
    func testSetImageTask_DelegateReceivesTaskAndData() async {
        // Given
        mockCacheManager.stubbedData = Data([0x01, 0x02, 0x03])
        
        // When
        viewModel.setImageTask()
        let task = mockDelegate.receivedImageTask
        let data = await task?.value
        
        // Then
        XCTAssertNotNil(task)
        XCTAssertTrue(mockCacheManager.loadImageCalled)
        XCTAssertTrue(mockDelegate.updateImageViewCalled)
        XCTAssertEqual(data, mockCacheManager.stubbedData)
    }
    
    func testSetImageTask_WithNilDelegate_DoesNotCrash() {
        // Given
        viewModel.delegate = nil
        mockCacheManager.stubbedData = Data([0x01])
        
        // Then
        XCTAssertNoThrow(viewModel.setImageTask())
    }
    
    func testImageTaskCancel_CancelsExistingTask() async {
        // Given
        mockCacheManager.stubbedData = Data([0x01, 0x02])
        viewModel.setImageTask()
        let task = mockDelegate.receivedImageTask
        XCTAssertNotNil(task)
        
        // When
        viewModel.imageTaskCancel()
        
        // Then
        XCTAssertTrue(task?.isCancelled ?? false)
    }
    
    func testImageTaskCancel_WhenNoTask_DoesNotCrash() {
        // Then
        XCTAssertNoThrow(viewModel.imageTaskCancel())
    }
    
    // MARK: - Properties
    
    func testAvatarURLProperty_ReturnsCorrectURL() {
        // Then
        XCTAssertEqual(viewModel.avatarURL, testUser.avatarURL)
    }
    
    func testLoginProperty_ReturnsCorrectLogin() {
        // Then
        XCTAssertEqual(viewModel.login, testUser.login)
    }
    
    func testIsFavoriteProperty_ReturnsCoreDataValue() {
        // Given
        mockCoreDataManager.stubIsFavorite = true
        
        // Then
        XCTAssertTrue(viewModel.isFavorite)
        
        // Given
        mockCoreDataManager.stubIsFavorite = false
        
        // Then
        XCTAssertFalse(viewModel.isFavorite)
    }
}
