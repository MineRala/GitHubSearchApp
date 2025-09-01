//
//  FavoritesViewModel.swift
//  GitHubSearchApp
//
//  Created by MINERALA on 31.08.2025.
//

import Foundation

protocol FavoritesViewModelProtocol {
    var networkManager: NetworkManagerProtocol { get }
    var cacheManager: CacheManagerProtocol { get }
    var coreDataManager: CoreDataManagerProtocol { get }
    var delegate: FavoritesViewControllerDelegate? { get set }
    
    var allFavoritesCount: Int { get }
    func viewDidLoad()
    func getItem(index: Int) -> SearchItem
}

// MARK: - FavoritesViewModel
final class FavoritesViewModel {
    public let networkManager: NetworkManagerProtocol
    public let cacheManager: CacheManagerProtocol
    public let coreDataManager: CoreDataManagerProtocol
    
    public weak var delegate: FavoritesViewControllerDelegate?
    
    private var allFavorites: [SearchItem] = []

    // MARK: - Initializer
    init(networkManager: NetworkManagerProtocol, cacheManager: CacheManagerProtocol, coreDataManager: CoreDataManagerProtocol) {
        self.networkManager = networkManager
        self.cacheManager = cacheManager
        self.coreDataManager = coreDataManager
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    private func addNotificationObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(fetchFavorites), name: .favoriteItemUpdated, object: nil)
    }
    
    @objc private func fetchFavorites() {
        DispatchQueue.main.async {
            self.allFavorites = self.convertSearchItem()
            self.updateUIState()
        }
    }
    
    private func convertSearchItem() -> [SearchItem] {
        return coreDataManager.fetchFavorites().map { item in
            SearchItem(login: item.login ?? "", avatarURL: item.avatarURL ?? "")
        }
    }
    
    private func updateUIState() {
        if allFavorites.isEmpty {
            delegate?.updateEmptyState(isEmpty: true)
        } else {
            delegate?.updateEmptyState(isEmpty: false)
            delegate?.tableReload()
        }
    }
}

// MARK: - FavoritesViewModelProtocol
extension FavoritesViewModel: FavoritesViewModelProtocol {
    var allFavoritesCount: Int {
        allFavorites.count
    }
    
    func viewDidLoad() {
        fetchFavorites()
        addNotificationObserver()
    }
    
    func getItem(index: Int) -> SearchItem {
        allFavorites[index]
    }
}
