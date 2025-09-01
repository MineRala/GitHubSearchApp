//
//  TableViewCellViewModel.swift
//  GitHubSearchApp
//
//  Created by MINERALA on 31.08.2025.
//

import Foundation

protocol TableViewCellViewModelProtocol {
    var login: String { get }
    var isFavorite: Bool { get }
    var delegate: TableViewCellDelegate? { get set }

    func favoriteButtonTapped()
    func imageTaskCancel()
    func setImageTask()
}

// MARK: - TableViewCellViewModel
final class TableViewCellViewModel {
    private let coreDataManager: CoreDataManagerProtocol
    private let cacheManager: CacheManagerProtocol
    
    public weak var delegate: TableViewCellDelegate?
    
    private let item: SearchItem
    private var imageTask: Task<Data?, Never>?
    
    var avatarURL: String {
        item.avatarURL
    }
    
    // MARK: - Initializer
    init(item: SearchItem, coreDataManager: CoreDataManagerProtocol, cacheManager: CacheManagerProtocol) {
        self.item = item
        self.coreDataManager = coreDataManager
        self.cacheManager = cacheManager
    }
    
    private func toggleFavorite() {
        coreDataManager.toggleFavorite(user: item)
        NotificationCenter.default.post(name: .favoriteItemUpdated, object: item)
    }
}

// MARK: - TableViewCellViewModelProtocol
extension TableViewCellViewModel: TableViewCellViewModelProtocol {
    var login: String {
        item.login
    }
    
    var isFavorite: Bool {
        coreDataManager.isFavorite(login: item.login)
    }
    
    func favoriteButtonTapped() {
        toggleFavorite()
        delegate?.updateFavoriteButton(isFavorite: isFavorite)
    }
    
    func imageTaskCancel() {
        imageTask?.cancel()
        imageTask = nil
    }
    
    func setImageTask() {
        let task = Task { await cacheManager.loadImage(from: avatarURL) }
        imageTask = task
        delegate?.updateImageView(with: task)
    }
}
