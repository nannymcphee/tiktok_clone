//
//  HomeCoordinator.swift
//  tiktokclone
//
//  Created by Duy Nguyen on 03/09/2021.
//

import UIKit
import XCoordinator

enum HomeRoute: Route {
    case main
}

class HomeCoordinator: NavigationCoordinator<HomeRoute> {
    // MARK: Initialization
    init() {
        super.init(initialRoute: .main)
    }

    // MARK: Overrides
    override func prepareTransition(for route: HomeRoute) -> NavigationTransition {
        switch route {
        case .main:
            let vm = HomeVM()
            let viewController = HomeVC(viewModel: vm)
            return .push(viewController)
        }
    }
}
