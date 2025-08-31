//
//  UISearchBar+Ext.swift
//  GitHubSearchApp
//
//  Created by MINERALA on 31.08.2025.
//

import UIKit

extension UISearchBar {
    func setPlaceholder(_ text: String, font: UIFont, color: UIColor = .gray) {
        if let textField = self.value(forKey: "searchField") as? UITextField {
            textField.attributedPlaceholder = NSAttributedString(
                string: text,
                attributes: [.font: font, .foregroundColor: color]
            )
            textField.font = font
        }
    }
}
