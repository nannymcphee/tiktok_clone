//
//  NonLoginView.swift
//  tiktokclone
//
//  Created by Duy Nguyen on 03/09/2021.
//

import UIKit
import RxSwift

class NonLoginView: BaseView {
    // MARK: - UI Elements
    private lazy var stackViewContainer: UIStackView = {
        let stackView = UIStackView()
        stackView.alignment = .center
        stackView.axis = .vertical
        stackView.spacing = 20
        stackView.distribution = .equalSpacing
        return stackView
    }()
    
    private lazy var ivMain: UIImageView = {
        let imageView = UIImageView()
        imageView.tintColor = AppColors.lightGray
        imageView.contentMode = .scaleAspectFill
        imageView.image = R.image.ic_user()
        return imageView
    }()
    
    private lazy var lbTitle: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = AppColors.lightGray
        label.text = Text.registerAccount
        label.font = R.font.milliardLight(size: 14)
        return label
    }()
    
    private lazy var btnRegister: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(Text.register, for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = AppColors.red
        button.titleLabel?.font = R.font.milliardMedium(size: 16)
        button.customBorder(cornerRadius: 2, borderWidth: 1, color: .clear)
        return button
    }()
    
    // MARK: - Variables
    private let _registerTriggerSubject = PublishSubject<Void>()
    var registerTriggerObservable: Observable<Void> {
        return _registerTriggerSubject.asObservable()
    }
    
    // MARK: - Overrides
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpView()
        bindingUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Private functions
    private func setUpView() {
        addSubview(stackViewContainer)
        stackViewContainer.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        stackViewContainer.addArrangedSubview(ivMain)
        ivMain.snp.makeConstraints { make in
            make.size.equalTo(75)
        }
        
        stackViewContainer.addArrangedSubview(lbTitle)
        stackViewContainer.addArrangedSubview(btnRegister)
        btnRegister.snp.makeConstraints { make in
            let leftRightPadding: CGFloat = 80
            make.height.equalTo(45)
            make.width.equalTo(Device.screenWidth - leftRightPadding)
        }
    }
    
    private func bindingUI() {
        btnRegister.rx.tap
            .throttle(.seconds(1), scheduler: MainScheduler.instance)
            .mapToVoid()
            .bind(to: _registerTriggerSubject)
            .disposed(by: disposeBag)
    }
}
