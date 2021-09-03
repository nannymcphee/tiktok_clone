//
//  MyProfileCoordinator.swift
//  tiktokclone
//
//  Created by Duy Nguyen on 03/09/2021.
//

import UIKit
import RxSwift
import XCoordinator

enum MyProfileRoute: Route {
    case main
    case register
}

class MyProfileCoordinator: NavigationCoordinator<MyProfileRoute>, EventPublisherType {
    private let disposeBag = DisposeBag()
    private var myProfileVM: MyProfileVM?
    
    // MARK: - Event
    enum Event {
        case loginSuccess
    }
    
    let eventPublisher = PublishSubject<Event>()
    
    // MARK: - Initialization
    init() {
        super.init(initialRoute: .main)
    }

    // MARK: Overrides
    override func prepareTransition(for route: MyProfileRoute) -> NavigationTransition {
        switch route {
        case .main:
            myProfileVM = MyProfileVM()
            let vc = MyProfileVC(viewModel: myProfileVM!)
            
            myProfileVM?.eventPublisher
                .asDriverOnErrorJustComplete()
                .drive(with: self, onNext: { owner, event in
                    switch event {
                    case .navigateToRegister:
                        owner.trigger(.register)
                    }
                })
                .disposed(by: disposeBag)
            
            return .push(vc)
            
        case .register:
            let vm = RegisterVM()
            let vc = RegisterVC(viewModel: vm)
            
            vm.eventPublisher
                .asDriverOnErrorJustComplete()
                .drive(with: self, onNext: { owner, event in
                    switch event {
                    case .dismiss:
                        vc.dismiss(animated: true, completion: nil)
                    case .loginSuccess:
                        owner.eventPublisher.onNext(.loginSuccess)
                    }
                })
                .disposed(by: disposeBag)
            
            return .present(vc)
        }
    }
}
