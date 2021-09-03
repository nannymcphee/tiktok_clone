//
//  SearchCoordinator.swift
//  tiktokclone
//
//  Created by Duy Nguyen on 03/09/2021.
//

import UIKit
import XCoordinator

enum SearchRoute: Route {
    case main
}

class SearchCoordinator: NavigationCoordinator<SearchRoute> {
    // MARK: Initialization
    init() {
        super.init(initialRoute: .main)
    }

    // MARK: Overrides
    override func prepareTransition(for route: SearchRoute) -> NavigationTransition {
        switch route {
        case .main:
            let viewController = SearchVC()
            return .push(viewController)
        }
    }
}
