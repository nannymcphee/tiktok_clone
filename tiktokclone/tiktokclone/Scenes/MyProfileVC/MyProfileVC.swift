//
//  MyProfileVC.swift
//  tiktokclone
//
//  Created by Duy Nguyen on 03/09/2021.
//

import UIKit
import RxSwift
import RxCocoa
import Resolver

final class MyProfileVM: BaseVM, ViewModelTransformable, EventPublisherType, ViewModelTrackable {
    // MARK: - Input
    struct Input {
        let viewDidLoadTrigger: Observable<Void>
        let logOutTrigger: Observable<Void>
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
    
    @Injected private var authService: AuthUseCase
    
    // MARK: - Public functions
    func transform(input: Input) -> Output {
        // Logout trigger
        input.logOutTrigger
            .flatMapLatest(weakObj: self) { viewModel, _ in
                viewModel.authService.signOut()
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

// MARK: - Private functions
private extension MyProfileVM {
    
}

final class MyProfileVC: RxBaseViewController<MyProfileVM> {
    // MARK: - IBOutlets
    
    private lazy var vNonLogin: NonLoginView = {
        let view = NonLoginView(frame: CGRect(x: 0, y: 0,
                                              width: Device.screenWidth,
                                              height: Device.screenHeight))
        return view
    }()
    
    // MARK: - Variables
    private let viewDidLoadTrigger = PublishSubject<Void>()
    private let logOutTrigger = PublishSubject<Void>()
    
    // MARK: - Overrides
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUI()
        bindViewModel()
        bindingUI()
    }
    
    override func setUpColors() {
        
    }
    
    
    // MARK: - Private functions
    private func bindViewModel() {
        let input = Input(viewDidLoadTrigger: viewDidLoadTrigger,
                          logOutTrigger: logOutTrigger,
                          registerTrigger: vNonLogin.registerTriggerObservable)
        let output = viewModel.transform(input: input)
        
        // Is authenticated
        output.isAuthenticated
            .drive(vNonLogin.rx.isHidden)
            .disposed(by: disposeBag)
        
        viewDidLoadTrigger.onNext(())
    }
    
    private func bindingUI() {
        
    }
    
    private func setUpUI() {
        setUpNonLoginView()
        
        title = Text.myProfileScreenTitle
        let btnLogout = getIconBarButtonItem(icon: R.image.ic_close())
        btnLogout.tintColor = .white
        btnLogout.rx.tap
            .bind(to: logOutTrigger)
            .disposed(by: disposeBag)
        navigationItem.setRightBarButton(btnLogout, animated: true)
    }
    
    private func setUpNonLoginView() {
        vNonLogin.isHidden = true
        view.addSubview(vNonLogin)
        vNonLogin.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}

// MARK: - Extensions
