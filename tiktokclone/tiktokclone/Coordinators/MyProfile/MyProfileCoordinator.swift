//
//  MyProfileCoordinator.swift
//  tiktokclone
//
//  Created by Duy Nguyen on 03/09/2021.
//

import UIKit
import XCoordinator

enum MyProfileRoute: Route {
    case main
}

class MyProfileCoordinator: NavigationCoordinator<MyProfileRoute> {
    // MARK: Initialization
    init() {
        super.init(initialRoute: .main)
    }

    // MARK: Overrides
    override func prepareTransition(for route: MyProfileRoute) -> NavigationTransition {
        switch route {
        case .main:
            let viewController = MyProfileVC()
            return .push(viewController)
        }
    }
}
