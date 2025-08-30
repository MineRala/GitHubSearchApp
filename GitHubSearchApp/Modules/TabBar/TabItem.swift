//
//  TabItem.swift
//  GitHubSearchApp
//
//  Created by MINERALA on 29.08.2025.
//

import UIKit


enum TabItem {
    case home
    case favorites

    var title: String {
        switch self {
        case .home: return AppStrings.home
        case .favorites: return AppStrings.favorites
        }
    }
    
    var icon: UIImage? {
        switch self {
        case .home: return AppIcons.homeFill
        case .favorites: return AppIcons.starFill
        }
    }
    
    var tag: Int {
        switch self {
        case .home: return 0
        case .favorites: return 1
        }
    }
}
