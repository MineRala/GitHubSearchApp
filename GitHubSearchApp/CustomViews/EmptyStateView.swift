//
//  EmptyStateView.swift
//  GitHubSearchApp
//
//  Created by MINERALA on 29.08.2025.
//

import UIKit

// MARK: - Empty State View
final class EmptyStateView: UIView {

    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.tintColor = .systemPurple
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 20)
        label.textColor = .darkGray
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16)
        label.textColor = .gray
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var stackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [iconImageView, titleLabel, descriptionLabel])
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 12
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
        }
        
        iconImageView.snp.makeConstraints { make in
            make.width.height.equalTo(80)
        }
    }

    func configure(for type: EmptyStateType) {
        switch type {
        case .initialSearch:
            iconImageView.image = UIImage(systemName: "magnifyingglass")
            titleLabel.text = "Start your search"
            descriptionLabel.text = "Please enter a GitHub username above to begin searching."
        case .searchNoResults:
            iconImageView.image = UIImage(systemName: "xmark.circle")
            titleLabel.text = "No results found"
            descriptionLabel.text = "Try a different username or check the spelling."
        case .noFavorites:
            iconImageView.image = UIImage(systemName: "star")
            titleLabel.text = "No favorites yet"
            descriptionLabel.text = "Add some users to your favorites list."
        }

        alpha = 0
        isHidden = false
        UIView.animate(withDuration: 0.25) { self.alpha = 1 }
    }
}
