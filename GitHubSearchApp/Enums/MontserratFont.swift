//
//  MontserratFont.swift
//  GitHubSearchApp
//
//  Created by MINERALA on 31.08.2025.
//

import UIKit

enum MontserratFont: String {
    case regular = "Montserrat-Regular"
    case bold = "Montserrat-Bold"
    case medium = "Montserrat-Medium"
    case semiBold = "Montserrat-SemiBold"
    case light = "Montserrat-Light"
    case thin = "Montserrat-Thin"
}

extension UIFont {
    static func montserrat(_ style: MontserratFont, size: CGFloat) -> UIFont {
        return UIFont(name: style.rawValue, size: size) ?? UIFont.systemFont(ofSize: size)
    }
}
