//
//  ViewController.swift
//  GitHubSearchApp
//
//  Created by MINERALA on 29.08.2025.
//

import UIKit
import SnapKit

// MARK: - HomeViewController
final class HomeViewController: UIViewController {

    // MARK: - UI Components
    private lazy var searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.placeholder = "Please enter a username"
        searchBar.delegate = self
        searchBar.showsCancelButton = false
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        return searchBar
    }()

    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(TableViewCell.self, forCellReuseIdentifier: "TableViewCell")
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    private lazy var activityIndicator: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.color = .systemPurple
        activityIndicator.hidesWhenStopped = true
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        return activityIndicator
    }()

    private lazy var emptyStateView = EmptyStateView()

    // MARK: - Dependencies & State
    private let networkManager = NetworkManager()
    private let cacheManager = CacheManager()
    private let coreDataManager = CoreDataManager()
    
    // MARK: - Debounce
    private let debounceQueue = DispatchQueue(label: "com.githubsearchapp.debounce")
    private var pendingRequestWorkItem: DispatchWorkItem?
    
    private var items: [SearchItem] = []
    private var needsReload = false

    private var state: HomeState = .idle {
        didSet {
            DispatchQueue.main.async { [weak self] in
                guard let self else { return }
                self.updateUI(for: self.state)
            }
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: .favoriteItemUpdated, object: nil)
    }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        addNotificationObserver()
        state = .idle
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if needsReload {
            tableView.reloadData()
        }
     }

    // MARK: - UI Setup
    private func setupUI() {
        view.backgroundColor = .white
        navigationItem.title = AppStrings.home

        [searchBar, tableView, emptyStateView, activityIndicator].forEach { view.addSubview($0) }

        searchBar.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            $0.left.right.equalToSuperview()
        }

        tableView.snp.makeConstraints {
            $0.top.equalTo(searchBar.snp.bottom)
            $0.left.right.bottom.equalToSuperview()
        }

        emptyStateView.snp.makeConstraints { $0.edges.equalToSuperview() }
        activityIndicator.snp.makeConstraints { $0.center.equalToSuperview() }

        view.bringSubviewToFront(searchBar)
    }

    // MARK: - Search
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
                    self.showAlert(title: "Network Error", message: error.errorMessage)
                }
            }
        }
    }

  // MARK: - UI Update
    private func updateUI(for state: HomeState) {
        switch state {
        case .idle:
            self.items = []
            tableView.isHidden = true
            emptyStateView.configure(for: .initialSearch)
            emptyStateView.isHidden = false
            activityIndicator.stopAnimating()

        case .loading:
            self.items = []
            tableView.isHidden = true
            emptyStateView.isHidden = true
            activityIndicator.startAnimating()

        case .populated(let items):
            self.items = items
            emptyStateView.isHidden = true
            activityIndicator.stopAnimating()
            tableView.isHidden = false
            tableView.reloadData()
            scrollUp()

        case .empty:
            self.items = []
            tableView.isHidden = true
            activityIndicator.stopAnimating()
            emptyStateView.configure(for: .searchNoResults)
            emptyStateView.isHidden = false
        }
    }
    
    private func scrollUp () {
        if !items.isEmpty {
            DispatchQueue.main.async {
                self.tableView.layoutIfNeeded()
                self.tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: false)
            }
           
        }
    }

// MARK: - Refresh
    private func addNotificationObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleFavoriteUpdated(_:)), name: .favoriteItemUpdated, object: nil)
    }

    @objc private func handleFavoriteUpdated(_ notif: Notification) {
        guard let updatedItem = notif.object as? SearchItem else { return }
        updateItemInTable(updatedItem)
    }
    
    private func updateItemInTable(_ updatedItem: SearchItem) {
        guard let index = items.firstIndex(where: { $0.login == updatedItem.login }) else { return }

        items[index] = updatedItem
        let indexPath = IndexPath(row: index, section: 0)

        DispatchQueue.main.async {
            if self.tableView.window != nil {
                if let visibleRows = self.tableView.indexPathsForVisibleRows,
                   visibleRows.contains(indexPath) {
                    self.tableView.reloadRows(at: [indexPath], with: .automatic)
                } else {
                    self.tableView.reloadData()
                }
            } else {
                self.needsReload = true
            }
        }
    }
}

// MARK: - UITableViewDataSource & Delegate
extension HomeViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        items.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let cell = tableView.dequeueReusableCell(withIdentifier: "TableViewCell", for: indexPath) as? TableViewCell else {
            return UITableViewCell()
        }

        let item = items[indexPath.row]
        cell.configure(with: item, cacheManager: cacheManager, coreDataManager: coreDataManager)

        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat { 100 }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let item = items[indexPath.row]
        let vc = DetailViewController(item: item)
        
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

// MARK: - UISearchBarDelegate
extension HomeViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        pendingRequestWorkItem?.cancel()

        if searchText.isEmpty {
            searchBar.showsCancelButton = false
            state = .idle
            return
        }

        searchBar.showsCancelButton = true

        let workItem = DispatchWorkItem { [weak self] in
            self?.searchUsers(with: searchText)
        }
        pendingRequestWorkItem = workItem
        debounceQueue.asyncAfter(deadline: .now() + 0.5, execute: workItem)
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        pendingRequestWorkItem?.cancel()
        
        if let query = searchBar.text, !query.isEmpty {
            searchUsers(with: query)
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        DispatchQueue.main.async { [weak self] in
            searchBar.text = ""
            searchBar.resignFirstResponder()
            self?.pendingRequestWorkItem?.cancel()
            self?.state = .idle
            searchBar.showsCancelButton = false
        }
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        if let searchText = searchBar.text, !searchText.isEmpty {
            searchBar.showsCancelButton = true
        }
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = false
    }
}
