//
//  MyProfileVC.swift
//  tiktokclone
//
//  Created by Duy Nguyen on 03/09/2021.
//

import UIKit
import RxSwift

final class MyProfileVC: RxBaseViewController<MyProfileVM> {
    // MARK: - IBOutlets
    @IBOutlet weak var scvContent: UIScrollView!
    @IBOutlet weak var vUserInfoContainer: UIView!
    @IBOutlet weak var tbContent: UITableView!
    
    private lazy var vUserInfo: UserInfoView = {
        let view = UserInfoView.loadFromNib()
        return view
    }()
    
    private lazy var vNonLogin: NonLoginView = {
        let view = NonLoginView(frame: CGRect(x: 0, y: 0,
                                              width: Device.screenWidth,
                                              height: Device.screenHeight))
        return view
    }()
    
    // MARK: - Variables
    private let viewDidLoadTrigger = PublishSubject<Void>()
    private let settingsTrigger = PublishSubject<Void>()
    
    // MARK: - Overrides
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUI()
        bindViewModel()
        bindingUI()
    }
    
    override func setUpColors() {
        view.backgroundColor = AppColors.primaryBackground
    }
    
    // MARK: - Private functions
    private func bindViewModel() {
        let input = Input(viewDidLoadTrigger: viewDidLoadTrigger,
                          settingsTrigger: settingsTrigger,
                          registerTrigger: vNonLogin.registerTriggerObservable)
        let output = viewModel.transform(input: input)
        
        // Is authenticated
        output.isAuthenticated
            .drive(with: self, onNext: { viewController, isAuthenticated in
                viewController.vNonLogin.isHidden = isAuthenticated
                viewController.scvContent.isHidden = !isAuthenticated
            })
            .disposed(by: disposeBag)
        
        // User info
        output.currentUser
            .drive(with: self, onNext: {
                $0.vUserInfo.populateData(with: $1)
            })
            .disposed(by: disposeBag)
        
        viewDidLoadTrigger.onNext(())
    }
    
    private func bindingUI() {
        // Scrollview didScroll
        scvContent.rx.didScroll
            .withLatestFrom(scvContent.rx.contentOffset)
            .observe(on: MainScheduler.asyncInstance)
            .map { $0.y > 0 ? AppColors.secondaryBackground : AppColors.primaryBackground }
            .asDriverOnErrorJustComplete()
            .drive(with: self, onNext: { viewController, color in
                viewController.navigationController?.backgroundColor(color)
            })
            .disposed(by: disposeBag)
    }
    
    private func setUpUI() {
        setUpTableViewContent()
        setUpNonLoginView()
        setUpUserInfoView()
        
        title = Text.myProfileScreenTitle
        
        let btnSettings = getIconBarButtonItem(icon: R.image.ic_menu())
        btnSettings.tintColor = .white
        btnSettings.rx.tap
            .bind(to: settingsTrigger)
            .disposed(by: disposeBag)
        navigationItem.setRightBarButton(btnSettings, animated: true)
        
        let btnAddFriend = getIconBarButtonItem(icon: R.image.ic_add_user())
        btnAddFriend.tintColor = .white
        navigationItem.setLeftBarButton(btnAddFriend, animated: true)
    }
    
    private func setUpTableViewContent() {
        
    }
    
    private func setUpNonLoginView() {
        vNonLogin.isHidden = true
        view.addSubview(vNonLogin)
        vNonLogin.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    private func setUpUserInfoView() {
        vUserInfoContainer.addSubview(vUserInfo)
        vUserInfo.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        vUserInfoContainer.changeHeight(to: vUserInfo.kDefaultHeight)
    }
}

// MARK: - Extensions
