//
//  RegisterVM.swift
//  tiktokclone
//
//  Created by Duy Nguyen on 03/09/2021.
//

import RxSwift
import RxCocoa
import Resolver

final class RegisterVM: BaseVM, ViewModelTransformable, EventPublisherType, ViewModelTrackable {
    // MARK: - Input
    struct Input {
        let registerMethodSelected: Observable<UtilityModel>
        let dismissTrigger: Observable<Void>
        let expandTableTrigger: Observable<Void>
    }
    
    // MARK: - Output
    struct Output {
        let registerMethods: Driver<[UtilityModel]>
        let tableViewHeight: Driver<(height: CGFloat, isExpand: Bool)>
    }
    
    // Event
    enum Event {
        case loginSuccess(TTUser)
        case dismiss
    }
    
    // MARK: - Variables
    var presentingViewController: UIViewController?
    
    let loadingIndicator = ActivityIndicator()
    let errorTracker = ErrorTracker()
    let kMethodTableRowHeight: CGFloat = 55
    let kIntialVisibleMethods: CGFloat = 4
    let eventPublisher = PublishSubject<Event>()

    @Injected private var authService: AuthUseCase
    
    private let methodsRelay = BehaviorRelay<[UtilityModel]>(value: [
        UtilityModel(iconName: R.image.ic_user.name,        title: Text.usePhoneNumberOrEmail,  tag: 0),
        UtilityModel(iconName: R.image.ic_facebook.name,    title: Text.continueWithFacebook,   tag: 1),
        UtilityModel(iconName: R.image.ic_apple.name,       title: Text.continueWithApple,      tag: 2),
        UtilityModel(iconName: R.image.ic_google.name,      title: Text.continueWithGoogle,     tag: 3),
        UtilityModel(iconName: R.image.ic_twitter.name,     title: Text.continueWithTwitter,    tag: 4),
        UtilityModel(iconName: R.image.ic_line.name,        title: Text.continueWithLine,       tag: 5),
        UtilityModel(iconName: R.image.ic_kakao_talk.name,  title: Text.continueWithKakaoTalk,  tag: 6),
    ])
    private let tableHeightRelay = BehaviorRelay<(height: CGFloat, isExpand: Bool)>(value: (0, false))
    
    // MARK: - Public functions
    func transform(input: Input) -> Output {
        let intialHeight = kMethodTableRowHeight * kIntialVisibleMethods
        tableHeightRelay.accept((height: intialHeight, isExpand: false))
        
        // Register method selected
        input.registerMethodSelected
            .map(\.tag)
            .subscribe(with: self, onNext: { $0.handleRegisterMethodSelected(tag: $1) })
            .disposed(by: disposeBag)
        
        // Dismiss trigger
        input.dismissTrigger
            .map { Event.dismiss }
            .bind(to: eventPublisher)
            .disposed(by: disposeBag)
        
        // Expand table
        input.expandTableTrigger
            .withUnretained(self)
            .map { viewModel, _ -> (height: CGFloat, isExpand: Bool) in
                let height = CGFloat(viewModel.methodsRelay.value.count + 1) * viewModel.kMethodTableRowHeight
                return (height: height, isExpand: true)
            }
            .bind(to: tableHeightRelay)
            .disposed(by: disposeBag)
        
        return Output(registerMethods: methodsRelay.asDriver(),
                      tableViewHeight: tableHeightRelay.asDriver())
    }
}

// MARK: - Private functions
private extension RegisterVM {
    func handleRegisterMethodSelected(tag: Int) {
        switch tag {
        case 3:
            guard let vc = presentingViewController else { return }
            authService.signInWithGoogle(presenting: vc)
                .trackError(errorTracker, action: .alert)
                .trackActivity(loadingIndicator)
                .subscribe(with: self, onNext: { viewModel, user in
                    viewModel.eventPublisher.onNext(.loginSuccess(user))
                    viewModel.eventPublisher.onNext(.dismiss)
                })
                .disposed(by: disposeBag)
        default:
            break
        }
    }
}
