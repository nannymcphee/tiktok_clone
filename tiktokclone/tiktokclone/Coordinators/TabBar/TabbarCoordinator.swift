//
//  TabbarCoordinator.swift
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

class TabbarCoordinator: TabBarCoordinator<TabbarRoute> {
    // MARK: Stored properties

    private let homeRouter: StrongRouter<HomeRoute>
    private let searchRouter: StrongRouter<SearchRoute>
    private let videoUploadRouter: StrongRouter<VideoUploadRoute>
    private let chatRouter: StrongRouter<ChatRoute>
    private let myProfileRouter: StrongRouter<MyProfileRoute>
    
    // MARK: Initialization
    convenience init() {
        let homeCoordinator = HomeCoordinator()
        homeCoordinator.rootViewController.tabBarItem = UITabBarItem(tabBarSystemItem: .recents, tag: 0)

        let searchCoordinator = SearchCoordinator()
        searchCoordinator.rootViewController.tabBarItem = UITabBarItem(tabBarSystemItem: .search, tag: 1)
        
        let videoUploadCoordinator = VideoUploadCoordinator()
        videoUploadCoordinator.rootViewController.tabBarItem = UITabBarItem(tabBarSystemItem: .more, tag: 2)
        
        let chatCoordinator = ChatCoordinator()
        chatCoordinator.rootViewController.tabBarItem = UITabBarItem(tabBarSystemItem: .history, tag: 3)
        
        let myProfileCoordinator = MyProfileCoordinator()
        myProfileCoordinator.rootViewController.tabBarItem = UITabBarItem(tabBarSystemItem: .contacts, tag: 4)

        self.init(homeRouter: homeCoordinator.strongRouter,
                  searchRouter: searchCoordinator.strongRouter,
                  videoUploadRouter: videoUploadCoordinator.strongRouter,
                  chatRouter: chatCoordinator.strongRouter,
                  myProfileRouter: myProfileCoordinator.strongRouter)
    }

    init(homeRouter: StrongRouter<HomeRoute>,
         searchRouter: StrongRouter<SearchRoute>,
         videoUploadRouter: StrongRouter<VideoUploadRoute>,
         chatRouter: StrongRouter<ChatRoute>,
         myProfileRouter: StrongRouter<MyProfileRoute>) {
        self.homeRouter = homeRouter
        self.searchRouter = searchRouter
        self.videoUploadRouter = videoUploadRouter
        self.chatRouter = chatRouter
        self.myProfileRouter = myProfileRouter
        super.init(tabs: [homeRouter, searchRouter, videoUploadRouter, chatRouter, myProfileRouter], select: homeRouter)
    }

    // MARK: Overrides
    override func prepareTransition(for route: TabbarRoute) -> TabBarTransition {
        switch route {
        case .home:
            return .select(homeRouter)
        case .search:
            return .select(searchRouter)
        case .videoUpload:
            return .select(videoUploadRouter)
        case .chat:
            return .select(chatRouter)
        case .myProfile:
            return .select(myProfileRouter)
        }
    }

}
