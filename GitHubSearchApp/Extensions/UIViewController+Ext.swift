//
//  UIViewController.swift
//  GitHubSearchApp
//
//  Created by MINERALA on 29.08.2025.
//

import UIKit

extension UIViewController {
    func showAlert(title: String = AppStrings.error, message: String, buttonTitle: String = AppStrings.ok) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: buttonTitle, style: .default))
            self.present(alert, animated: true)
        }
    }
}
