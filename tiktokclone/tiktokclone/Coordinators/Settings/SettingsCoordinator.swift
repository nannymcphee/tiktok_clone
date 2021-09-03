//
//  SettingsCoordinator.swift
//  tiktokclone
//
//  Created by Duy Nguyen on 03/09/2021.
//

import UIKit
import XCoordinator

enum SettingsRoute: Route {
    case settings
}

class SettingsCoordinator: NavigationCoordinator<SettingsRoute> {
    // MARK: Initialization
    init() {
        super.init(initialRoute: .settings)
    }

    // MARK: Overrides
    override func prepareTransition(for route: SettingsRoute) -> NavigationTransition {
        switch route {
        case .settings:
            let viewController = SettingsVC()
            return .push(viewController)
        }
    }
}
