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
        
        let homeViewModel = HomeViewModel(networkManager: networkManager, cacheManager: cacheManager, coreDataManager: coreDataManager)
        let homeViewController = HomeViewController(viewModel: homeViewModel)
        let homeNav = UINavigationController(rootViewController: homeViewController)

        let favoritesViewModel = FavoritesViewModel(networkManager: networkManager, cacheManager: cacheManager, coreDataManager: coreDataManager)
        let favoritesViewController = FavoritesViewController(viewModel: favoritesViewModel)
        let favoritesNav = UINavigationController(rootViewController: favoritesViewController)
        
        homeNav.tabBarItem = UITabBarItem(title: TabItem.home.title, image: TabItem.home.icon, tag: TabItem.home.tag)
        favoritesNav.tabBarItem = UITabBarItem(title: TabItem.favorites.title, image: TabItem.favorites.icon, tag: TabItem.favorites.tag)
        
        tabBarController.tabBar.isTranslucent = false
        tabBarController.viewControllers = [homeNav, favoritesNav]
        
        return tabBarController
    }
}
