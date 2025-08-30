//
//  Detail.swift
//  GitHubSearchApp
//
//  Created by MINERALA on 29.08.2025.
//

import UIKit
import SnapKit

final class DetailViewController: UIViewController {
    private let item: SearchItem
    private var detailData: ItemDetail?
    
    private lazy var avatarImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.layer.cornerRadius = 24
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private lazy var usernameLabel: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 20)
        label.textAlignment = .center
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18)
        label.textAlignment = .center
        label.textColor = .darkGray
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var urlLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16)
        label.textAlignment = .center
        label.textColor = .systemBlue
        label.isUserInteractionEnabled = true
        label.numberOfLines = 3
        label.translatesAutoresizingMaskIntoConstraints = false
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(openURL))
        label.addGestureRecognizer(tapGesture)
        return label
    }()

    private lazy var favoriteButton: UIButton = {
        let button = UIButton(type: .system)
        button.tintColor = .systemPurple
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(favoriteButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.color = .systemPurple
        indicator.hidesWhenStopped = true
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()

    private lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [avatarImageView, usernameLabel, nameLabel, favoriteButton, urlLabel])
        stackView.axis = .vertical
        stackView.spacing = 12
        stackView.alignment = .center
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    private let cacheManager = CacheManager()
    private let coreDataManager = CoreDataManager()
    
    init(item: SearchItem) {
        self.item = item
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: .favoriteItemUpdated, object: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        fetchUserDetail()
        addNotificationObserver()
    }

    private func setupUI() {
        view.backgroundColor = .white
        view.addSubview(stackView)
        view.addSubview(activityIndicator)

        stackView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(20)
            make.left.right.equalToSuperview().inset(20)
        }

        avatarImageView.snp.makeConstraints { $0.width.height.equalTo(220) }
        favoriteButton.snp.makeConstraints { $0.width.height.equalTo(44) }
        activityIndicator.snp.makeConstraints { $0.center.equalToSuperview() }

    }

    private func updateUI() {
        guard let detail = detailData else { return }

        usernameLabel.text = detail.login

        if let name = detail.name, !name.isEmpty {
            nameLabel.isHidden = false
            nameLabel.text = name
        } else {
            nameLabel.isHidden = true
        }

        urlLabel.text = detail.htmlURL
        
        updateFavoriteButton()

        cacheManager.loadImage(from: item.avatarURL) { [weak self] image in
            guard let self else { return }
            if let image { self.avatarImageView.image = image }
        }
    }
    
    @objc private func favoriteStatusChanged(_ notif: Notification) {
        guard let updatedItem = notif.object as? SearchItem,
              updatedItem.login == self.item.login else { return }
        
        updateFavoriteButton()
    }

    @objc private func openURL() {
        guard let urlString = urlLabel.text,
              let url = URL(string: urlString) else { return }
        UIApplication.shared.open(url)
    }

    private func addNotificationObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(favoriteStatusChanged(_:)), name: .favoriteItemUpdated, object: nil)
    }
    
    private func fetchUserDetail() {
        activityIndicator.startAnimating()
        NetworkManager().makeRequest(endpoint: .getUserDetail(userName: item.login), type: ItemDetail.self) { [weak self] result in
            DispatchQueue.main.async {
                guard let self else { return }
                self.activityIndicator.stopAnimating()
                switch result {
                case .success(let detail):
                    self.detailData = detail
                    self.updateUI()
                case .failure(let error):
                    self.showAlert(title: "Error", message: error.errorMessage)
                }
            }
        }
    }
    
    @objc private func favoriteButtonTapped() {        
        coreDataManager.toggleFavorite(user: item)
        NotificationCenter.default.post(name: .favoriteItemUpdated, object: item)
    }
    
    private func updateFavoriteButton() {
        favoriteButton.setImage(item.isFavorite ? AppIcons.starFill : AppIcons.star, for: .normal)
    }
}

