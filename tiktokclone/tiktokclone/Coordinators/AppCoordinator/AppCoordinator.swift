//
//  AppCoordinator.swift
//  tiktokclone
//
//  Created by Duy Nguyen on 03/09/2021.
//

import UIKit
import XCoordinator

enum AppRoute: Route {
    case tabBar
}

class AppCoordinator: NavigationCoordinator<AppRoute> {
    // MARK: - Initialization
    init() {
        super.init(initialRoute: .tabBar)
    }
    
    // MARK: Overrides
    override func prepareTransition(for route: AppRoute) -> NavigationTransition {
        switch route {
        case .tabBar:
            let tabBarRouter = TabbarCoordinator().strongRouter
            return .presentFullScreen(tabBarRouter)
        }
    }
}

enum TabbarRoute: Route {
    case home
    case search
    case videoUpload
    case chat
    case myProfile
}
