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
    
    var tabBarRouter: StrongRouter<TabbarRoute>?
    
    // MARK: Overrides
    override func prepareTransition(for route: AppRoute) -> NavigationTransition {
        switch route {
        case .tabBar:
            tabBarRouter = TabbarCoordinator().strongRouter
            return .presentFullScreen(tabBarRouter!)
        }
    }
}
