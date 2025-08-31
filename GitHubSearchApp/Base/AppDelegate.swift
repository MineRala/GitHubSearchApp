//
//  AppDelegate.swift
//  GitHubSearchApp
//
//  Created by MINERALA on 29.08.2025.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {

        let window = UIWindow(frame: UIScreen.main.bounds)
        
        let networkManager = NetworkManager()
        let cacheManager = CacheManager()
        let coreDataManager = CoreDataManager()

        window.rootViewController = TabBarBuilder.build(networkManager: networkManager, cacheManager: cacheManager, coreDataManager: coreDataManager)
        window.makeKeyAndVisible()
        self.window = window

        return true
    }
}
