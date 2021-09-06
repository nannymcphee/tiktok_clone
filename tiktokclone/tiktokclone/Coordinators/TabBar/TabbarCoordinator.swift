//
//  TabbarCoordinator.swift
//  tiktokclone
//
//  Created by Duy Nguyen on 03/09/2021.
//

import UIKit
import XCoordinator
import RxSwift
import Resolver

enum TabbarRoute: Route {
    case home
    case search
    case videoUpload
    case chat
    case myProfile
}

class TabbarCoordinator: TabBarCoordinator<TabbarRoute> {
    // MARK: Stored properties
    private var homeCoordinator: HomeCoordinator?
    private var searchCoordinator: SearchCoordinator?
    private var videoUploadCoordinator: VideoUploadCoordinator?
    private var chatCoordinator: ChatCoordinator?
    private var myProfileCoordinator: MyProfileCoordinator?
    
    private let homeRouter: StrongRouter<HomeRoute>
    private let searchRouter: StrongRouter<SearchRoute>
    private let videoUploadRouter: StrongRouter<VideoUploadRoute>
    private let chatRouter: StrongRouter<ChatRoute>
    private let myProfileRouter: StrongRouter<MyProfileRoute>
    private let disposeBag = DisposeBag()
    
    @Injected private var userRepo: UserRepo
    
    // MARK: Initialization
    convenience init() {
        let homeCoordinator = HomeCoordinator()
        homeCoordinator.rootViewController.tabBarItem = UITabBarItem(title: Text.homeScreenTitle, image: R.image.ic_home(), tag: 0)
        homeCoordinator.rootViewController.isNavigationBarHidden = true

        let searchCoordinator = SearchCoordinator()
        searchCoordinator.rootViewController.tabBarItem = UITabBarItem(title: Text.searchScreenTitle, image: R.image.ic_search(), tag: 1)
        
        let videoUploadCoordinator = VideoUploadCoordinator()
        let videoUploadTabItem = UITabBarItem(title: nil, image: R.image.ic_plus_square(), tag: 2)
        videoUploadTabItem.imageInsets = UIEdgeInsets(top: 6, left: 0, bottom: -6, right: 0)
        videoUploadCoordinator.rootViewController.tabBarItem = videoUploadTabItem
        
        let chatCoordinator = ChatCoordinator()
        chatCoordinator.rootViewController.tabBarItem = UITabBarItem(title: Text.chatListScreenTitle, image: R.image.ic_chat(), tag: 3)
        
        let myProfileCoordinator = MyProfileCoordinator()
        myProfileCoordinator.rootViewController.tabBarItem = UITabBarItem(title: Text.myProfileScreenTitle, image: R.image.ic_user(), tag: 4)

        self.init(homeRouter: homeCoordinator.strongRouter,
                  searchRouter: searchCoordinator.strongRouter,
                  videoUploadRouter: videoUploadCoordinator.strongRouter,
                  chatRouter: chatCoordinator.strongRouter,
                  myProfileRouter: myProfileCoordinator.strongRouter)
        
        let animationDelegate = TabBarAnimationDelegate()
        
        self.homeCoordinator = homeCoordinator
        self.searchCoordinator = searchCoordinator
        self.videoUploadCoordinator = videoUploadCoordinator
        self.chatCoordinator = chatCoordinator
        self.myProfileCoordinator = myProfileCoordinator
        delegate = animationDelegate
        self.handleEvents()
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
        super.init(tabs: [homeRouter, searchRouter, videoUploadRouter, chatRouter, myProfileRouter],
                   select: 0)
    }

    // MARK: Overrides
    override func prepareTransition(for route: TabbarRoute) -> TabBarTransition {
        switch route {
        case .home:
            return .select(homeRouter)
        case .search:
            return .select(searchRouter)
        case .videoUpload:
            guard userRepo.currentUser != nil else {
                return .select(myProfileRouter)
            }
            return .select(videoUploadRouter)
        case .chat:
            return .select(chatRouter)
        case .myProfile:
            return .select(myProfileRouter)
        }
    }
    
    private func handleEvents() {
        myProfileCoordinator?.eventPublisher
            .subscribe(with: self, onNext: { owner, event in
                switch event {
                case .loginSuccess:
                    owner.trigger(.home)
                }
            })
            .disposed(by: disposeBag)
    }
}
