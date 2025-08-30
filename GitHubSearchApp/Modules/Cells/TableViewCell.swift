//
//  TableViewCell.swift
//  GitHubSearchApp
//
//  Created by MINERALA on 29.08.2025.
//

import UIKit
import SnapKit

final class TableViewCell: UITableViewCell {
    // MARK: - UI Elements
    private lazy var itemImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private lazy var itemNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.numberOfLines = 2
        label.lineBreakMode = .byTruncatingTail
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var favoriteButton: UIButton = {
        let button = UIButton()
        button.layer.cornerRadius = 18
        button.layer.masksToBounds = true
        button.tintColor = .systemPurple
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(favoriteButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private var item: SearchItem?
    private var coreDataManager: CoreDataManagerProtocol?

    
    // MARK: - Initializer
      override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
          super.init(style: style, reuseIdentifier: reuseIdentifier)
          setupUI()
      }

      required init?(coder: NSCoder) {
          fatalError("init(coder:) has not been implemented")
      }

      override func prepareForReuse() {
          super.prepareForReuse()
          itemNameLabel.text = nil
          itemImageView.image = nil
          favoriteButton.setImage(AppIcons.star, for: .normal)
      }
}


// MARK: - UI
extension TableViewCell {
    private func setupUI() {
        self.selectedBackgroundView = UIView()
        self.selectionStyle = .none

        contentView.addSubview(itemImageView)
        contentView.addSubview(itemNameLabel)
        contentView.addSubview(favoriteButton)
        
        itemImageView.snp.makeConstraints { make in
            make.top.equalTo(contentView.snp.top).offset(10)
            make.left.equalTo(contentView.snp.left)
            make.bottom.equalTo(contentView.snp.bottom).offset(-10)
            make.width.equalToSuperview().multipliedBy(0.3)
        }

        itemNameLabel.snp.makeConstraints { make in
            make.top.equalTo(contentView.snp.top).offset(20)
            make.left.equalTo(itemImageView.snp.right)
            make.right.equalToSuperview().offset(-20)
            make.height.greaterThanOrEqualTo(20)
            make.height.lessThanOrEqualTo(40)
        }
        
        favoriteButton.snp.makeConstraints { make in
            make.top.equalTo(itemNameLabel.snp.bottom).offset(4)
            make.left.equalTo(itemNameLabel.snp.left)
            make.width.height.equalTo(32)
        }
    }
}

extension TableViewCell {
    func configure(with item: SearchItem, cacheManager: CacheManagerProtocol?, coreDataManager: CoreDataManagerProtocol?) {
        self.item = item
        self.coreDataManager = coreDataManager
        itemNameLabel.text = item.login
        
        if let cacheManager {
            let currentURL = item.avatarURL  // snapshot of the current item
            cacheManager.loadImage(from: currentURL) { [weak self] image in
                guard let self = self else { return }
                // Hücre reuse edilmişse eski item için image uygulanmaz
                if self.item?.avatarURL == currentURL {
                    self.itemImageView.image = image
                }
            }
        }
        updateFavoriteButton()
    }
    
    @objc private func favoriteButtonTapped() {
        guard let item, let coreDataManager else { return }
        
        coreDataManager.toggleFavorite(user: item)
        updateFavoriteButton()
        NotificationCenter.default.post(name: .favoriteItemUpdated, object: item)
    }
    
    private func updateFavoriteButton() {
        guard let item else { return }
        
        favoriteButton.setImage(item.isFavorite ? AppIcons.starFill : AppIcons.star, for: .normal)
    }
}
