//
//  AppDelegate.swift
//  tiktokclone
//
//  Created by Duy Nguyen on 03/09/2021.
//

import UIKit
import Resolver
import Firebase
import GoogleSignIn

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    let appCoordinator = AppCoordinator()
    private lazy var mainWindow = UIWindow()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        appCoordinator.strongRouter.setRoot(for: mainWindow)
        // Dependency Injection
        Resolver.registerAllServices()
        Resolver.registerMockServices()
        setUpTabBarTheme()
        setUpNavigationBarTheme()
        return true
    }
    
    @available(iOS 9.0, *)
    func application(_ application: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any]) -> Bool {
        return GIDSignIn.sharedInstance.handle(url)
    }
}

private extension AppDelegate {
    func setUpNavigationBarTheme() {
        let appearance = UINavigationBar.appearance()
        appearance.setBackgroundImage(UIImage(), for: .default)
        appearance.shadowImage = UIImage()
        appearance.isTranslucent = true
        appearance.backgroundColor = .clear
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white,
                                          .font: R.font.milliardSemiBold(size: 18)!]
    }
    
    func setUpTabBarTheme() {
        UITabBar.appearance().tintColor = .white
        UITabBarItem.appearance().setTitleTextAttributes([.font: R.font.milliardLight(size: 10)!,
                                                          .foregroundColor: UIColor.white],
                                                         for: .normal)
    }
}

