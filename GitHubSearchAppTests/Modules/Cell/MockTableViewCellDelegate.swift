//
//  MockTableViewCellDelegate.swift
//  GitHubSearchAppTests
//
//  Created by MINERALA on 31.08.2025.
//

import UIKit
@testable import GitHubSearchApp

// MARK: - MockTableViewCellDelegate
final class MockTableViewCellDelegate: TableViewCellDelegate {
    
    var updateFavoriteButtonCalled = false
    var updateFavoriteButtonState: Bool?
    
    var updateImageViewCalled = false
    var receivedImageTask: Task<Data?, Never>?
    
    func updateFavoriteButton(isFavorite: Bool) {
        updateFavoriteButtonCalled = true
        updateFavoriteButtonState = isFavorite
    }
    
    func updateImageView(with task: Task<Data?, Never>) {
        updateImageViewCalled = true
        receivedImageTask = task
    }
}
