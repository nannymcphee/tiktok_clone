//
//  VideoUploadCoordinator.swift
//  tiktokclone
//
//  Created by Duy Nguyen on 03/09/2021.
//

import UIKit
import RxSwift
import XCoordinator

enum VideoUploadRoute: Route {
    case main
}

class VideoUploadCoordinator: NavigationCoordinator<VideoUploadRoute> {
    // MARK: Initialization
    init() {
        super.init(initialRoute: .main)
    }
    
    private let disposeBag = DisposeBag()
    
    // MARK: Overrides
    override func prepareTransition(for route: VideoUploadRoute) -> NavigationTransition {
        switch route {
        case .main:
            let vm = VideoUploadVM()
            let vc = VideoUploadVC(viewModel: vm)
            
            vm.eventPublisher
                .asDriverOnErrorJustComplete()
                .drive(with: self) { owner, event in
                    switch event {
                    case .uploadVideoSuccess:
                        AppDialog.withOk(controller: vc, message: Text.uploadVideoSuccess)
                        vm.resetData()
                        
                    case .showLoginPopup:
                        AppDialog.withOk(controller: vc,
                                         title: Text.youAreNotLoggedIn,
                                         message: Text.pleaseLoginToUploadVideo, ok: {
                                            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
                                            appDelegate.appCoordinator.tabBarRouter?.trigger(.myProfile)
                                         })
                    }
                }
                .disposed(by: disposeBag)
            
            return .push(vc)
        }
    }
}
