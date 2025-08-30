//
//  FavoritesViewController.swift
//  GitHubSearchApp
//
//  Created by MINERALA on 29.08.2025.
//

import UIKit
import SnapKit

final class FavoritesViewController: UIViewController {
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(TableViewCell.self, forCellReuseIdentifier: "TableViewCell")
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    private lazy var emptyStateView: EmptyStateView = {
        let emptyView = EmptyStateView()
        emptyView.configure(for: .noFavorites)
        return emptyView
    }()
    
    private let coreDataManager = CoreDataManager()
    private let cacheManager = CacheManager()
    
    private var allFavorites: [SearchItem] = []
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: .favoriteItemUpdated, object: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        fetchFavorites()
        addNotificationObserver()
    }

    
    private func setupUI() {
        view.backgroundColor = .white
        navigationItem.title = AppStrings.favorites

        [tableView, emptyStateView].forEach { view.addSubview($0) }

        tableView.snp.makeConstraints { $0.edges.equalToSuperview() }
        emptyStateView.snp.makeConstraints { $0.edges.equalToSuperview() }

    }
    
    private func updateUIState() {
        if allFavorites.isEmpty {
            tableView.isHidden = true
            emptyStateView.isHidden = false
        } else {
            tableView.isHidden = false
            emptyStateView.isHidden = true
            tableView.reloadData()
        }
    }
    
    private func addNotificationObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(fetchFavorites), name: .favoriteItemUpdated, object: nil)
    }

    private func convertSearchItem() -> [SearchItem] {
        return coreDataManager.fetchFavorites().map { item in
            SearchItem(login: item.login ?? "", avatarURL: item.avatarURL ?? "")
        }
    }
    
    @objc private func fetchFavorites() {
        DispatchQueue.main.async {
            self.allFavorites = self.convertSearchItem()
            self.updateUIState()
        }
    }
}

// MARK: - UITableViewDataSource & Delegate
extension FavoritesViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        allFavorites.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "TableViewCell", for: indexPath) as? TableViewCell else {
            return UITableViewCell()
        }

        let item = allFavorites[indexPath.row]
        cell.configure(with: item, cacheManager: cacheManager, coreDataManager: coreDataManager)

        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat { 100 }

}
