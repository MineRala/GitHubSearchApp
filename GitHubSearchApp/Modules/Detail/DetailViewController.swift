//
//  Detail.swift
//  GitHubSearchApp
//
//  Created by MINERALA on 29.08.2025.
//

import UIKit
import SnapKit

protocol DetailViewControllerProtocol: AnyObject {
    func isActivityIndicatorAnimating(_ isAnimating: Bool)
    func updateFavoriteButton(isFavorite: Bool)
    func updateUI(detail: ItemDetail)
    func updateAvatarImage(with dataTask: Task<Data?, Never>)
    func showErrorAlert(title: String, message: String)
}

// MARK: - DetailViewController
final class DetailViewController: UIViewController {
    // MARK: - UI Components
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
        label.font = .montserrat(.bold, size: 20)
        label.textAlignment = .center
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.font = .montserrat(.regular, size: 18)
        label.textAlignment = .center
        label.textColor = .darkGray
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var urlLabel: UILabel = {
        let label = UILabel()
        label.font = .montserrat(.regular, size: 16)
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
    
    private var viewModel: DetailViewModelProtocol
    
    // MARK: - Initializer
    init(viewModel: DetailViewModelProtocol) {
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
    
    private func setupNavigaitonBar() {
        let appearance = UINavigationBarAppearance()
        appearance.backButtonAppearance.normal.titleTextAttributes = [
            .font: UIFont.montserrat(.medium, size: 16)
        ]
        navigationController?.navigationBar.standardAppearance = appearance
    }

    @objc private func openURL() {
        guard let urlString = urlLabel.text,
              let url = URL(string: urlString) else { return }
        UIApplication.shared.open(url)
    }

    @objc private func favoriteButtonTapped() {        
        viewModel.favoriteButtonTapped()
    }
}

// MARK: - DetailViewControllerProtocol
extension DetailViewController: DetailViewControllerProtocol {
    func isActivityIndicatorAnimating(_ isAnimating: Bool) {
        isAnimating ? activityIndicator.startAnimating() :  activityIndicator.stopAnimating()
    }
        
    func updateFavoriteButton(isFavorite: Bool) {
        favoriteButton.setImage(isFavorite ? AppIcons.starFill : AppIcons.star, for: .normal)
    }
    
    func updateUI(detail: ItemDetail) {
        usernameLabel.text = detail.login
        if let name = detail.name, !name.isEmpty {
            nameLabel.isHidden = false
            nameLabel.text = name
        } else {
            nameLabel.isHidden = true
        }
        urlLabel.text = detail.htmlURL
    }
    
    func updateAvatarImage(with dataTask: Task<Data?, Never>) {
        avatarImageView.setImage(from: dataTask)
    }
    
    func showErrorAlert(title: String, message: String) {
        self.showAlert(title: title, message: message)
    }
}
