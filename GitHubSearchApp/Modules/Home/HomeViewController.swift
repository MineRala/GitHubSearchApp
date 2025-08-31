//
//  ViewController.swift
//  GitHubSearchApp
//
//  Created by MINERALA on 29.08.2025.
//

import UIKit
import SnapKit

protocol HomeViewControllerProtocol: AnyObject {
    func tableReload()
    func showErrorAlert(title: String, message: String)
    func scrollUp()
    func shouldShowCancelButton(_ isShow: Bool)
    func showTable(_ isVisible: Bool)
    func emptyStateViewConfigure(_ state: EmptyStateType )
    func showEmptyStateView(_ isVisible: Bool)
    func isActivityIndicatorAnimating(_ isAnimating: Bool)
    func reloadRow(at indexPath: IndexPath)
    func isTableViewVisible() -> Bool
}

// MARK: - HomeViewController
final class HomeViewController: UIViewController {

    // MARK: - UI Components
    private lazy var searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.placeholder = AppStrings.placeholderSearchBar
        searchBar.delegate = self
        searchBar.showsCancelButton = false
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        return searchBar
    }()

    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(TableViewCell.self, forCellReuseIdentifier: TableViewConstants.cellIdentifier)
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

    private var viewModel: HomeViewModelProtocol
   
    // MARK:  Initializer
    init(viewModel: HomeViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        self.viewModel.delegate = self
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        viewModel.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.viewWillAppear()
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
}

// MARK: - UITableViewDataSource & Delegate
extension HomeViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.itemsCount
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: TableViewConstants.cellIdentifier, for: indexPath) as? TableViewCell else {
            return UITableViewCell()
        }
        
        guard indexPath.row < viewModel.itemsCount else { return cell }
        
        let item = viewModel.getItem(index: indexPath.row)
        let cellViewModel = TableViewCellViewModel(item: item, coreDataManager: viewModel.coreDataManager, cacheManager: viewModel.cacheManager)
        cell.configure(with: cellViewModel)
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat { TableViewConstants.rowHeight }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
       
        let detailViewModel = DetailViewModel(cacheManager: viewModel.cacheManager, coreDataManager: viewModel.coreDataManager, item: viewModel.getItem(index: indexPath.row))
        let detailViewController = DetailViewController(viewModel: detailViewModel)
        
        self.navigationController?.pushViewController(detailViewController, animated: true)
    }
}

// MARK: - UISearchBarDelegate
extension HomeViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        viewModel.textDidChange(searchText: searchText)
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        viewModel.searchButtonClicked(with: searchBar.text)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            searchBar.text = ""
            searchBar.resignFirstResponder()
            self.viewModel.searchCancelButtonClicked()
            searchBar.showsCancelButton = false
        }
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        viewModel.searchBarTextDidBeginEditing(text: searchBar.text)
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = false
    }
}

// MARK: - HomeViewControllerProtocol
extension HomeViewController: HomeViewControllerProtocol {
    func reloadRow(at indexPath: IndexPath) {
        DispatchQueue.main.async {
            if let visibleRows = self.tableView.indexPathsForVisibleRows,
               visibleRows.contains(indexPath) {
                self.tableView.reloadRows(at: [indexPath], with: .automatic)
            } else {
                self.tableView.reloadData()
            }
        }
    }
    
    func isTableViewVisible() -> Bool {
        return tableView.window != nil
    }
    
    func isActivityIndicatorAnimating(_ isAnimating: Bool) {
        isAnimating ? activityIndicator.startAnimating() :  activityIndicator.stopAnimating()
    }
    
    func showEmptyStateView(_ isVisible: Bool) {
        emptyStateView.isHidden = !isVisible
    }
    
    func emptyStateViewConfigure(_ state: EmptyStateType) {
        emptyStateView.configure(for: state)
    }
    
    func showTable(_ isVisible: Bool) {
        tableView.isHidden = !isVisible
    }
    
    func shouldShowCancelButton(_ isShow: Bool) {
        searchBar.showsCancelButton = isShow
    }
    
    func scrollUp() {
        DispatchQueue.main.async {
            self.tableView.layoutIfNeeded()
            self.tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: false)
        }
    }
    
    func showErrorAlert(title: String, message: String) {
        self.showAlert(title: title, message: message)
    }
    
    func tableReload() {
        tableView.reloadData()
    }
}
