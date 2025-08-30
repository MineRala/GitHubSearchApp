//
//  TabBarBuilder.swift
//  GitHubSearchApp
//
//  Created by MINERALA on 29.08.2025.
//

import UIKit

struct TabBarBuilder {
    static func build() -> UITabBarController {
        let tabBarController = UITabBarController()
        let appearance = UITabBar.appearance()
        appearance.tintColor = .systemPurple
        appearance.unselectedItemTintColor = .gray
        appearance.backgroundColor = .white
        
        let homeVC = HomeViewController()
        let homeNav = UINavigationController(rootViewController: homeVC)

        let favoritesVC = FavoritesViewController()
        let favoritesNav = UINavigationController(rootViewController: favoritesVC)
        
        homeNav.tabBarItem = UITabBarItem(title: TabItem.home.title, image: TabItem.home.icon, tag: TabItem.home.tag)
        favoritesNav.tabBarItem = UITabBarItem(title: TabItem.favorites.title, image: TabItem.favorites.icon, tag: TabItem.favorites.tag)
        
        tabBarController.tabBar.isTranslucent = false
        tabBarController.viewControllers = [homeNav, favoritesNav]
        
        return tabBarController
    }
}
