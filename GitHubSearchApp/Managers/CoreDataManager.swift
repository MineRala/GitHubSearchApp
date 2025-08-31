//
//  CoreDataManager.swift
//  GitHubSearchApp
//
//  Created by MINERALA on 29.08.2025.
//

import CoreData
import UIKit

protocol CoreDataManagerProtocol {
    func saveFavorite(user: SearchItem)
    func removeFavorite(login: String)
    func isFavorite(login: String) -> Bool
    func toggleFavorite(user: SearchItem)
    func fetchFavorites() -> [FavoriteUser]
}

final class CoreDataManager: CoreDataManagerProtocol {
    private let persistentContainer: NSPersistentContainer

    init() {
        persistentContainer = NSPersistentContainer(name: AppStrings.favoriteEntityName)
        persistentContainer.loadPersistentStores { (_, error) in }
    }

    private var context: NSManagedObjectContext {
        return persistentContainer.viewContext
    }

    // MARK: - Save
    func saveFavorite(user: SearchItem) {
        let favorite = FavoriteUser(context: context)
        favorite.login = user.login
        favorite.avatarURL = user.avatarURL
        saveContext()
    }

    // MARK: - Remove
    func removeFavorite(login: String) {
        let fetchRequest: NSFetchRequest<FavoriteUser> = FavoriteUser.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "login == %@", login)

        if let result = try? context.fetch(fetchRequest), let objectToDelete = result.first {
            context.delete(objectToDelete)
            saveContext()
        }
    }

    // MARK: - Check
    func isFavorite(login: String) -> Bool {
        let fetchRequest: NSFetchRequest<FavoriteUser> = FavoriteUser.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "login == %@", login)

        let count = (try? context.count(for: fetchRequest)) ?? 0
        return count > 0
    }

    // MARK: - Toggle
    func toggleFavorite(user: SearchItem) {
        if isFavorite(login: user.login) {
            removeFavorite(login: user.login)
        } else {
            saveFavorite(user: user)
        }
    }

    // MARK: - Fetch All
    func fetchFavorites() -> [FavoriteUser] {
        let fetchRequest: NSFetchRequest<FavoriteUser> = FavoriteUser.fetchRequest()
        do {
            return try context.fetch(fetchRequest)
        } catch {
            print("Error retrieving favorites list: \(error)")
            return []
        }
    }

    // MARK: - Save Context
    private func saveContext() {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                print("Failed to save Core Data: \(error.localizedDescription)")
            }
        }
    }
}
