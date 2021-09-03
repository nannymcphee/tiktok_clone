//
//  AppDelegate.swift
//  tiktokclone
//
//  Created by Duy Nguyen on 03/09/2021.
//

import UIKit
import Resolver

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    private let router = AppCoordinator().strongRouter
    private lazy var mainWindow = UIWindow()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        router.setRoot(for: mainWindow)
        // Dependency Injection
        Resolver.registerAllServices()
        UITabBar.appearance().tintColor = .white
        return true
    }
}

