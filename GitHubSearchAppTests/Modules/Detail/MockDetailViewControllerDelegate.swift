//
//  MockDetailViewControllerDelegate.swift
//  GitHubSearchAppTests
//
//  Created by MINERALA on 31.08.2025.
//

import Foundation
@testable import GitHubSearchApp

final class MockDetailViewControllerDelegate: DetailViewControllerDelegate {
    
    // MARK: - Properties to track calls
    var isActivityIndicatorAnimatingCalled = false
    var lastActivityIndicatorState: Bool?

    var updateFavoriteButtonCalled = false
    var lastFavoriteButtonState: Bool?

    var updateUICalled = false
    var updateUICallback: (() -> Void)?
    var lastDetail: ItemDetail?

    var updateAvatarImageCalled = false
    var receivedAvatarTask: Task<Data?, Never>?

    var showErrorAlertCalled = false
    var lastErrorTitle: String?
    var lastErrorMessage: String?

    // MARK: - Protocol Methods
    
    func isActivityIndicatorAnimating(_ isAnimating: Bool) {
        isActivityIndicatorAnimatingCalled = true
        lastActivityIndicatorState = isAnimating
    }
    
    func updateFavoriteButton(isFavorite: Bool) {
        updateFavoriteButtonCalled = true
        lastFavoriteButtonState = isFavorite
    }
    
    func updateUI(detail: ItemDetail) {
        updateUICalled = true
        updateUICallback?()
        lastDetail = detail
    }
    
    func updateAvatarImage(with dataTask: Task<Data?, Never>) {
        updateAvatarImageCalled = true
        receivedAvatarTask = dataTask
    }
    
    func showErrorAlert(title: String, message: String) {
        showErrorAlertCalled = true
        lastErrorTitle = title
        lastErrorMessage = message
    }
}
