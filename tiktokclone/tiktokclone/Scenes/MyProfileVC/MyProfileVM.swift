//
//  MyProfileVM.swift
//  tiktokclone
//
//  Created by Duy Nguyen on 03/09/2021.
//

import RxSwift
import RxCocoa
import Resolver

final class MyProfileVM: BaseVM, ViewModelTransformable, EventPublisherType, ViewModelTrackable {
    // MARK: - Input
    struct Input {
        let viewDidLoadTrigger: Observable<Void>
        let settingsTrigger: Observable<Void>
        let registerTrigger: Observable<Void>
    }
    
    // MARK: - Output
    struct Output {
        let currentUser: Driver<TTUser>
        let isAuthenticated: Driver<Bool>
    }
    
    // MARK: - Event
    enum Event {
        case navigateToRegister
    }
    
    // MARK: - Variables
    let loadingIndicator = ActivityIndicator()
    let errorTracker = ErrorTracker()
    let eventPublisher = PublishSubject<Event>()
    let currentUserRelay = BehaviorRelay<TTUser?>(value: nil)
    
    @Injected private var userRepo: UserRepo
    
    // MARK: - Public functions
    func transform(input: Input) -> Output {
        // Initial load
        let userInfo = input.viewDidLoadTrigger
            .flatMapLatest(weakObj: self) { viewModel, _ in
                return viewModel.userRepo
                    .getCurrentUserInfo()
                    .trackError(viewModel.errorTracker, action: .alert)
                    .trackActivity(viewModel.loadingIndicator)
                    .catchErrorJustComplete()
            }
        
        Observable.merge(userInfo, userRepo.authObservable)
            .bind(to: currentUserRelay)
            .disposed(by: disposeBag)
        
        // Logout trigger
        input.settingsTrigger
            .flatMapLatest(weakObj: self) { viewModel, _ in
                viewModel.userRepo.signOut()
                    .trackError(viewModel.errorTracker, action: .alert)
                    .trackActivity(viewModel.loadingIndicator)
            }
            .subscribe(with: self, onNext: { viewModel, _ in
                viewModel.currentUserRelay.accept(nil)
            })
            .disposed(by: disposeBag)
        
        // Register trigger
        input.registerTrigger
            .map { Event.navigateToRegister }
            .bind(to: eventPublisher)
            .disposed(by: disposeBag)
        
        // Is authenticated
        let isAuthenticated = currentUserRelay
            .map { $0 != nil }
            .asDriverOnErrorJustComplete()
        
        return Output(currentUser: currentUserRelay.unwrap().asDriverOnErrorJustComplete(),
                      isAuthenticated: isAuthenticated)
    }
}
