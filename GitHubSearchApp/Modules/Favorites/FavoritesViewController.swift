//
//  FavoritesViewController.swift
//  GitHubSearchApp
//
//  Created by MINERALA on 29.08.2025.
//

import UIKit
import SnapKit

protocol FavoritesViewControllerDelegate: AnyObject {
    func tableReload()
    func updateEmptyState(isEmpty: Bool)
}

// MARK: - FavoritesViewController
final class FavoritesViewController: UIViewController {
    // MARK: - UI Components
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(TableViewCell.self, forCellReuseIdentifier: TableViewConstants.cellIdentifier)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    private lazy var emptyStateView: EmptyStateView = {
        let emptyView = EmptyStateView()
        emptyView.configure(for: .noFavorites)
        return emptyView
    }()
    
    private var viewModel: FavoritesViewModelProtocol
    
    // MARK: - Initializer
    init(viewModel: FavoritesViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        self.viewModel.delegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        viewModel.viewDidLoad()
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        setupNavigaitonBar()
        
        [tableView, emptyStateView].forEach { view.addSubview($0) }

        tableView.snp.makeConstraints { $0.edges.equalToSuperview() }
        emptyStateView.snp.makeConstraints { $0.edges.equalToSuperview() }
    }
    
    private  func setupNavigaitonBar() {
        let titleFont = UIFont.montserrat(.semiBold, size: 20)
        navigationController?.navigationBar.titleTextAttributes = [
            .font: titleFont,
            .foregroundColor: UIColor.black
        ]
        navigationItem.title = AppStrings.favorites
    }
}

// MARK: - UITableViewDataSource & Delegate
extension FavoritesViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.allFavoritesCount
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: TableViewConstants.cellIdentifier, for: indexPath) as? TableViewCell else {
            return UITableViewCell()
        }

        let item = viewModel.getItem(index: indexPath.row)
        let cellViewModel = TableViewCellViewModel(item: item, coreDataManager: viewModel.coreDataManager, cacheManager: viewModel.cacheManager)
        cell.configure(with: cellViewModel)

        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat { TableViewConstants.rowHeight }

}

// MARK: - FavoritesViewControllerDelegate
extension FavoritesViewController: FavoritesViewControllerDelegate {
    func tableReload() {
        tableView.reloadData()
    }
    
    func updateEmptyState(isEmpty: Bool) {
        tableView.isHidden = isEmpty
        emptyStateView.isHidden = !isEmpty
    }
    
}
