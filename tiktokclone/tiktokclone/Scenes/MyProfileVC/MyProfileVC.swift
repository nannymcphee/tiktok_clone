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
    private let logOutTrigger = PublishSubject<Void>()
    
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
                          logOutTrigger: logOutTrigger,
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
            .map { $0.y > 0 ? AppColors.secondaryBackground : AppColors.primaryBackground }
            .asDriverOnErrorJustComplete()
            .drive(with: self, onNext: { viewController, color in
                viewController.navigationController?.backgroundColor(color)
            })
            .disposed(by: disposeBag)
    }
    
    private func setUpUI() {
        setUpNonLoginView()
        setUpUserInfoView()
        
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
    
    private func setUpUserInfoView() {
        vUserInfoContainer.addSubview(vUserInfo)
        vUserInfo.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        vUserInfoContainer.changeHeight(to: vUserInfo.kDefaultHeight)
    }
}

// MARK: - Extensions
