//
//  HomeViewModel.swift
//  GitHubSearchApp
//
//  Created by MINERALA on 30.08.2025.
//

import Foundation

protocol HomeViewModelProtocol {
    var networkManager: NetworkManagerProtocol { get }
    var cacheManager: CacheManagerProtocol { get }
    var coreDataManager: CoreDataManagerProtocol { get }
    var delegate: HomeViewControllerProtocol? { get set }
    
    var itemsCount: Int { get }
    func viewDidLoad()
    func viewWillAppear()
    func getItem(index: Int) -> SearchItem
    func textDidChange(searchText: String)
    func searchButtonClicked(with text: String?)
    func searchCancelButtonClicked()
    func searchBarTextDidBeginEditing(text: String?)
}

// MARK: - HomeViewModel
final class HomeViewModel {
    public let networkManager: NetworkManagerProtocol
    public let cacheManager: CacheManagerProtocol
    public let coreDataManager: CoreDataManagerProtocol
    
    public weak var delegate: HomeViewControllerProtocol?
    
    private var items: [SearchItem] = []
    private var needsReload = false
    private let debounceQueue = DispatchQueue(label: "com.githubsearchapp.debounce")
    private var pendingRequestWorkItem: DispatchWorkItem?
  
    private var state: HomeState = .idle {
        didSet {
            DispatchQueue.main.async { [weak self] in
                guard let self else { return }
                updateUI(for: self.state)
            }
        }
    }

    // MARK: - Initializer
    init(networkManager: NetworkManagerProtocol, cacheManager: CacheManagerProtocol, coreDataManager: CoreDataManagerProtocol) {
        self.networkManager = networkManager
        self.cacheManager = cacheManager
        self.coreDataManager = coreDataManager
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    private func updateUI(for state: HomeState) {
        switch state {
        case .idle:
            items = []
            delegate?.showTable(false)
            delegate?.emptyStateViewConfigure(.initialSearch)
            delegate?.showEmptyStateView(true)
            delegate?.isActivityIndicatorAnimating(false)
            
        case .loading:
            items = []
            delegate?.showTable(false)
            delegate?.showEmptyStateView(false)
            delegate?.isActivityIndicatorAnimating(true)
            
        case .populated(let items):
            self.items = items
            delegate?.showEmptyStateView(false)
            delegate?.isActivityIndicatorAnimating(false)
            delegate?.showTable(true)
            delegate?.tableReload()
            scrollUp()
            
        case .empty:
            items = []
            delegate?.showTable(false)
            delegate?.isActivityIndicatorAnimating(false)
            delegate?.emptyStateViewConfigure(.searchNoResults)
            delegate?.showEmptyStateView(true)
        }
    }
        
    private func scrollUp () {
        if !items.isEmpty {
            delegate?.scrollUp()
        }
    }
    
    @objc private func handleFavoriteUpdated(_ notif: Notification) {
        guard let updatedItem = notif.object as? SearchItem else { return }
        
        guard let index = items.firstIndex(where: { $0.login == updatedItem.login }) else { return }
        
        items[index] = updatedItem
        let indexPath = IndexPath(row: index, section: 0)
        
        if delegate?.isTableViewVisible() == true, index < items.count {
            delegate?.reloadRow(at: indexPath)
        } else {
            needsReload = true
        }
    }
    
    private func searchUsers(with query: String) {
        guard !query.isEmpty else { return }
        
        state = .loading
        
        networkManager.makeRequest(endpoint: .searchUsers(searchText: query), type: SearchResponse.self) { [weak self] result in
            guard let self else { return }
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    self.state = response.items.isEmpty ? .empty : .populated(response.items)
                    
                case .failure(let error):
                    self.state = .empty
                    self.delegate?.showErrorAlert(title: AppStrings.networkErrorTitle, message: error.errorMessage)
                }
            }
        }
    }
}

// MARK: - HomeViewModelProtocol
extension HomeViewModel: HomeViewModelProtocol {
    var itemsCount: Int {
        items.count
    }
    
    func viewDidLoad() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleFavoriteUpdated(_:)), name: .favoriteItemUpdated, object: nil)
        state = .idle
    }
    
    func viewWillAppear() {
        if needsReload {
            delegate?.tableReload()
            needsReload = false
        }
    }
    
    func getItem(index: Int) -> SearchItem {
        items[index]
    }
    
    func textDidChange(searchText: String) {
        pendingRequestWorkItem?.cancel()

        if searchText.isEmpty {
            delegate?.shouldShowCancelButton(false)
            state = .idle
            return
        }

        delegate?.shouldShowCancelButton(true)

        let workItem = DispatchWorkItem { [weak self] in
            guard let self else { return }
            self.searchUsers(with: searchText)
        }
        pendingRequestWorkItem = workItem
        debounceQueue.asyncAfter(deadline: .now() + 0.5, execute: workItem)
    }
    
    func searchButtonClicked(with text: String?) {
        pendingRequestWorkItem?.cancel()
        
        if let query = text, !query.isEmpty {
            searchUsers(with: query)
        }
    }

    func searchCancelButtonClicked() {
        pendingRequestWorkItem?.cancel()
        state = .idle
    }
    
    func searchBarTextDidBeginEditing(text: String?) {
        if let searchText = text, !searchText.isEmpty {
            delegate?.shouldShowCancelButton(true)
        }
    }
}
