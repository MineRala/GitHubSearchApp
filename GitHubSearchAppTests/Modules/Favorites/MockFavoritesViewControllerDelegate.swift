//
//  MockFavoritesViewControllerDelegate.swift
//  GitHubSearchAppTests
//
//  Created by MINERALA on 31.08.2025.
//

import Foundation
@testable import GitHubSearchApp

// MARK: - MockFavoritesViewControllerDelegate
final class MockFavoritesViewControllerDelegate: FavoritesViewControllerProtocol {
    
    var tableReloadCalled = false
    var updateEmptyStateCalled = false
    var lastEmptyStateValue: Bool?
    
    func tableReload() {
        tableReloadCalled = true
    }
    
    func updateEmptyState(isEmpty: Bool) {
        updateEmptyStateCalled = true
        lastEmptyStateValue = isEmpty
    }
}

