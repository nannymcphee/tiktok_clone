//
//  HomeCoordinator.swift
//  tiktokclone
//
//  Created by Duy Nguyen on 03/09/2021.
//

import UIKit
import RxSwift
import FittedSheets
import XCoordinator

enum HomeRoute: Route {
    case main
    case comments(TTVideo)
}

class HomeCoordinator: NavigationCoordinator<HomeRoute> {
    // MARK: Initialization
    init() {
        super.init(initialRoute: .main)
    }
    
    private let disposeBag = DisposeBag()

    // MARK: Overrides
    override func prepareTransition(for route: HomeRoute) -> NavigationTransition {
        switch route {
        case .main:
            let vm = HomeVM()
            let viewController = HomeVC(viewModel: vm)
            
            vm.eventPublisher
                .asDriverOnErrorJustComplete()
                .drive(with: self, onNext: { owner, event in
                    switch event {
                    case .didTapComment(let video):
                        owner.trigger(.comments(video))
                    }
                })
                .disposed(by: disposeBag)
            
            return .push(viewController)
            
        case .comments(let video):
            let vm = CommentsVM(video: video)
            let vc = CommentsVC(viewModel: vm)
            let sheetVC = SheetViewController(controller: vc, sizes: [.percent(0.75)], options: .tikTokDefault)
            sheetVC.overlayColor = .clear
            sheetVC.allowPullingPastMaxHeight = false
            sheetVC.autoAdjustToKeyboard = false
            sheetVC.contentBackgroundColor = AppColors.primaryBackground
            sheetVC.handleScrollView(vc.tbComments)
            
            vm.eventPublisher
                .asDriverOnErrorJustComplete()
                .drive(with: self, onNext: { owner, event in
                    switch event {
                    case .dismiss:
                        sheetVC.dismiss(animated: true, completion: nil)
                    }
                })
                .disposed(by: disposeBag)
            
            return .present(sheetVC)
        }
    }
}
