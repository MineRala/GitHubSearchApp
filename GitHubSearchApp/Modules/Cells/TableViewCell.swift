//
//  TableViewCell.swift
//  GitHubSearchApp
//
//  Created by MINERALA on 29.08.2025.
//

import UIKit
import SnapKit

protocol TableViewCellProtocol: AnyObject {
    func updateFavoriteButton(isFavorite: Bool)
    func updateImageView(with dataTask: Task<Data?, Never>)
}

// MARK: - TableViewCell
final class TableViewCell: UITableViewCell {
    // MARK: - UI Components
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
    
    private var viewModel: TableViewCellViewModelProtocol?

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
          
          guard let viewModel else { return }
          viewModel.imageTaskCancel()
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

// MARK: - Private
extension TableViewCell {
    @objc private func favoriteButtonTapped() {
        guard let viewModel else { return }
        viewModel.favoriteButtonTapped()
    }
}

// MARK: - Configure
extension TableViewCell {
    func configure(with viewModel: TableViewCellViewModelProtocol) {
        self.viewModel = viewModel
        self.viewModel?.delegate = self
        
        guard let viewModel = self.viewModel else { return }
        
        itemNameLabel.text = viewModel.login
        favoriteButton.setImage(viewModel.isFavorite ? AppIcons.starFill : AppIcons.star, for: .normal)
        
        viewModel.setImageTask()
    }
}

// MARK: - TableViewCellProtocol
extension TableViewCell: TableViewCellProtocol {
    func updateImageView(with dataTask: Task<Data?, Never>) {
        itemImageView.setImage(from: dataTask)
    }
    
    func updateFavoriteButton(isFavorite: Bool) {
        favoriteButton.setImage(isFavorite ? AppIcons.starFill : AppIcons.star, for: .normal)
    }
}
