//
//  TabBarBuilder.swift
//  GitHubSearchApp
//
//  Created by MINERALA on 29.08.2025.
//

import UIKit

struct TabBarBuilder {
    static func build(networkManager: NetworkManagerProtocol, cacheManager: CacheManagerProtocol, coreDataManager: CoreDataManagerProtocol) -> UITabBarController {
        let tabBarController = UITabBarController()
        let appearance = UITabBar.appearance()
        appearance.tintColor = .systemPurple
        appearance.unselectedItemTintColor = .gray
        appearance.backgroundColor = .white
        
        let font = UIFont.montserrat(.semiBold, size: 10)

        let normalAttributes: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: UIColor.gray
        ]

        let selectedAttributes: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: UIColor.systemPurple
        ]

        let homeViewModel = HomeViewModel(networkManager: networkManager, cacheManager: cacheManager, coreDataManager: coreDataManager)
        let homeViewController = HomeViewController(viewModel: homeViewModel)
        let homeNav = UINavigationController(rootViewController: homeViewController)

        let favoritesViewModel = FavoritesViewModel(networkManager: networkManager, cacheManager: cacheManager, coreDataManager: coreDataManager)
        let favoritesViewController = FavoritesViewController(viewModel: favoritesViewModel)
        let favoritesNav = UINavigationController(rootViewController: favoritesViewController)
        
        let homeItem = UITabBarItem(title: TabItem.home.title, image: TabItem.home.icon, tag: TabItem.home.tag)
        homeItem.setTitleTextAttributes(normalAttributes, for: .normal)
        homeItem.setTitleTextAttributes(selectedAttributes, for: .selected)
        homeNav.tabBarItem = homeItem
        
        let favoritesItem = UITabBarItem(title: TabItem.favorites.title, image: TabItem.favorites.icon, tag: TabItem.favorites.tag)
        favoritesItem.setTitleTextAttributes(normalAttributes, for: .normal)
        favoritesItem.setTitleTextAttributes(selectedAttributes, for: .selected)
        favoritesNav.tabBarItem = favoritesItem
        
        tabBarController.tabBar.isTranslucent = false
        tabBarController.viewControllers = [homeNav, favoritesNav]
        
        return tabBarController
    }
}
