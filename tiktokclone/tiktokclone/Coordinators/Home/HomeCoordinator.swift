//
//  HomeCoordinator.swift
//  tiktokclone
//
//  Created by Duy Nguyen on 03/09/2021.
//

import UIKit
import RxSwift
import XCoordinator

enum HomeRoute: Route {
    case main
    case comment
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
                        Logger.d("didTapComment \(video)")
                        owner.trigger(.comment)
                    }
                })
                .disposed(by: disposeBag)
            
            return .push(viewController)
            
        case .comment:
            let vc = UIViewController()
            vc.view.backgroundColor = .white
            return .present(vc)
        }
    }
}
