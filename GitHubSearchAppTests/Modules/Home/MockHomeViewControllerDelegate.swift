//
//  MockHomeViewControllerDelegate.swift
//  GitHubSearchAppTests
//
//  Created by MINERALA on 31.08.2025.
//

import UIKit
@testable import GitHubSearchApp

final class MockHomeViewControllerDelegate: HomeViewControllerProtocol {

    // MARK: - Call tracking
    var tableReloadCalled = false
    var showErrorAlertCalled = false
    var lastErrorTitle: String?
    var lastErrorMessage: String?
    
    var scrollUpCalled = false
    var shouldShowCancelButtonCalled = false
    var lastShouldShowCancelButtonState: Bool?
    
    var showTableCalled = false
    var lastShowTableState: Bool?
    
    var emptyStateViewConfigureCalled = false
    var lastEmptyStateType: EmptyStateType?
    
    var showEmptyStateViewCalled = false
    var lastShowEmptyStateViewState: Bool?
    
    var isActivityIndicatorAnimatingCalled = false
    var lastActivityIndicatorState: Bool?
    
    var reloadRowCalled = false
    var lastReloadedIndexPath: IndexPath?
    
    var isTableViewVisibleReturnValue = true

    // MARK: - HomeViewControllerProtocol Methods
    
    func tableReload() {
        tableReloadCalled = true
    }
    
    func showErrorAlert(title: String, message: String) {
        showErrorAlertCalled = true
        lastErrorTitle = title
        lastErrorMessage = message
    }
    
    func scrollUp() {
        scrollUpCalled = true
    }
    
    func shouldShowCancelButton(_ isShow: Bool) {
        shouldShowCancelButtonCalled = true
        lastShouldShowCancelButtonState = isShow
    }
    
    func showTable(_ isVisible: Bool) {
        showTableCalled = true
        lastShowTableState = isVisible
    }
    
    func emptyStateViewConfigure(_ state: EmptyStateType) {
        emptyStateViewConfigureCalled = true
        lastEmptyStateType = state
    }
    
    func showEmptyStateView(_ isVisible: Bool) {
        showEmptyStateViewCalled = true
        lastShowEmptyStateViewState = isVisible
    }
    
    func isActivityIndicatorAnimating(_ isAnimating: Bool) {
        isActivityIndicatorAnimatingCalled = true
        lastActivityIndicatorState = isAnimating
    }
    
    func reloadRow(at indexPath: IndexPath) {
        reloadRowCalled = true
        lastReloadedIndexPath = indexPath
    }
    
    func isTableViewVisible() -> Bool {
        return isTableViewVisibleReturnValue
    }
}
