//
//  MockCoreDataManager.swift
//  GitHubSearchAppTests
//
//  Created by MINERALA on 31.08.2025.
//

import UIKit
import CoreData
@testable import GitHubSearchApp

final class MockCoreDataManager: CoreDataManagerProtocol {

    // MARK: - Call tracking
    var saveFavoriteCalled = false
    var removeFavoriteCalled = false
    var isFavoriteCalled = false
    var toggleFavoriteCalled = false
    var fetchFavoritesCalled = false

    // MARK: - Stub data
    var stubFavorites: [FavoriteUser] = []
    var stubIsFavorite: Bool = false

    func saveFavorite(user: SearchItem) {
        saveFavoriteCalled = true
        let favorite = FavoriteUser(context: NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType))
        favorite.login = user.login
        favorite.avatarURL = user.avatarURL
        stubFavorites.append(favorite)
    }

    func removeFavorite(login: String) {
        removeFavoriteCalled = true
        stubFavorites.removeAll { $0.login == login }
    }

    func isFavorite(login: String) -> Bool {
        isFavoriteCalled = true
        return stubIsFavorite || stubFavorites.contains { $0.login == login }
    }

    func toggleFavorite(user: SearchItem) {
        toggleFavoriteCalled = true
        if isFavorite(login: user.login) {
            removeFavorite(login: user.login)
        } else {
            saveFavorite(user: user)
        }
    }

    func fetchFavorites() -> [FavoriteUser] {
        fetchFavoritesCalled = true
        return stubFavorites
    }
}
