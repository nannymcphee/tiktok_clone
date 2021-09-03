//
//  ChatCoordinator.swift
//  tiktokclone
//
//  Created by Duy Nguyen on 03/09/2021.
//

import UIKit
import XCoordinator

enum ChatRoute: Route {
    case chatList
    case chat
}

class ChatCoordinator: NavigationCoordinator<ChatRoute> {
    // MARK: Initialization
    init() {
        super.init(initialRoute: .chatList)
    }

    // MARK: Overrides
    override func prepareTransition(for route: ChatRoute) -> NavigationTransition {
        switch route {
        case .chatList:
            let viewController = ChatListVC()
            return .push(viewController)
            
        case .chat:
            let viewController = ChatVC()
            return .push(viewController)
        }
    }
}
