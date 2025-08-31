//
//  UIImageView+Ext.swift
//  GitHubSearchApp
//
//  Created by MINERALA on 31.08.2025.
//

import UIKit

extension UIImageView {
    func setImage(from dataTask: Task<Data?, Never>, placeholder: UIImage? = AppImages.placeholder) {
        self.image = placeholder
        Task { [weak self] in
            guard let self = self else { return }
            if let data = await dataTask.value {
                self.image = UIImage(data: data)
            }
        }
    }
}
