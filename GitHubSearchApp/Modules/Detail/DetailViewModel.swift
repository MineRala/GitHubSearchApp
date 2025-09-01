//
//  DetailViewModel.swift
//  GitHubSearchApp
//
//  Created by MINERALA on 31.08.2025.
//

import Foundation

protocol DetailViewModelProtocol {
    var cacheManager: CacheManagerProtocol { get }
    var coreDataManager: CoreDataManagerProtocol { get }
    var delegate: DetailViewControllerDelegate? { get set }
    
    func viewDidLoad()
    func favoriteButtonTapped()
}

// MARK: - DetailViewModel
final class DetailViewModel {
    public let cacheManager: CacheManagerProtocol
    public let coreDataManager: CoreDataManagerProtocol
    
    public weak var delegate: DetailViewControllerDelegate?
    
    private let item: SearchItem
    private var detailData: ItemDetail?
    private var imageTask: Task<Data?, Never>?

    // MARK: - Initializer
    init(cacheManager: CacheManagerProtocol, coreDataManager: CoreDataManagerProtocol, item: SearchItem) {
        self.cacheManager = cacheManager
        self.coreDataManager = coreDataManager
        self.item = item
    }
    
    deinit {
        imageTask?.cancel()
        NotificationCenter.default.removeObserver(self, name: .favoriteItemUpdated, object: nil)
    }
    
    private func fetchUserDetail() {
        delegate?.isActivityIndicatorAnimating(true)
        NetworkManager().makeRequest(endpoint: .getUserDetail(userName: item.login), type: ItemDetail.self) { [weak self] result in
            guard let self else { return }
            DispatchQueue.main.async { [self] in
                self.delegate?.isActivityIndicatorAnimating(false)
                switch result {
                case .success(let detail):
                    self.detailData = detail
                    self.updateUI()
                case .failure(let error):
                    self.delegate?.showErrorAlert(title: "Error", message: error.errorMessage)
                }
            }
        }
    }
    
    private func addNotificationObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(favoriteStatusChanged(_:)), name: .favoriteItemUpdated, object: nil)
    }
    
    @objc private func favoriteStatusChanged(_ notif: Notification) {
        guard let updatedItem = notif.object as? SearchItem,
              updatedItem.login == self.item.login else { return }
        
        updateFavoriteButton()
    }
    
    private func updateFavoriteButton() {
        delegate?.updateFavoriteButton(isFavorite: coreDataManager.isFavorite(login: item.login))
    }
    
    private func updateUI() {
        guard let detail = detailData else { return }

        delegate?.updateUI(detail: detail)

        updateFavoriteButton()

        let task = Task { await cacheManager.loadImage(from: detail.avatarURL) }
        imageTask = task
        delegate?.updateAvatarImage(with: task)
    }

}

// MARK: - DetailViewModelProtocol
extension DetailViewModel: DetailViewModelProtocol {
    func viewDidLoad() {
        fetchUserDetail()
        addNotificationObserver()
    }
    
    func favoriteButtonTapped() {
        coreDataManager.toggleFavorite(user: item)
        NotificationCenter.default.post(name: .favoriteItemUpdated, object: item)
    }
}
