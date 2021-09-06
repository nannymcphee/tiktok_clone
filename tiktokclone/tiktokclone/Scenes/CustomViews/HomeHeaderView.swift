//
//  HomeHeaderView.swift
//  tiktokclone
//
//  Created by Duy Nguyen on 06/09/2021.
//

import UIKit
import RxSwift

class HomeHeaderView: BaseView, EventPublisherType {
    // MARK: - UI Elements
    private lazy var vContainerButtons: UIStackView = {
        let stackView = UIStackView()
        stackView.alignment = .center
        stackView.axis = .horizontal
        stackView.spacing = 10
        stackView.distribution = .equalSpacing
        return stackView
    }()
    
    private lazy var vHorizontalSeparator: UIView = {
        let view = UIView()
        view.backgroundColor = AppColors.lightGray.withAlphaComponent(0.3)
        return view
    }()
    
    private lazy var btnFollowing: UIButton = {
        let button = UIButton()
        button.setAttributedTitle(NSAttributedString(string: Text.following, attributes: normalAttributes), for: .normal)
        button.setAttributedTitle(NSAttributedString(string: Text.following, attributes: selectedAttributes), for: .selected)
        return button
    }()
    
    private lazy var btnForYou: UIButton = {
        let button = UIButton()
        button.setAttributedTitle(NSAttributedString(string: Text.forYou, attributes: normalAttributes), for: .normal)
        button.setAttributedTitle(NSAttributedString(string: Text.forYou, attributes: selectedAttributes), for: .selected)
        return button
    }()
    
    private lazy var btnLive: UIButton = {
        let button = UIButton(type: .custom)
        button.tintColor = .white
        button.setImage(R.image.ic_live(), for: .normal)
        return button
    }()
    
    private lazy var btnSearch: UIButton = {
        let button = UIButton(type: .custom)
        button.tintColor = .white
        button.setImage(R.image.ic_search(), for: .normal)
        return button
    }()
    
    // MARK: - Event
    enum Event {
        case didTapLiveStream
        case didTapSearch
        case didSelectTab(Int)
    }
    
    // MARK: - Variables
    var eventPublisher = PublishSubject<Event>()
    
    private var tabButtons = [UIButton]()
    private let normalAttributes: [NSAttributedString.Key: Any] = [
        .foregroundColor: UIColor.white.withAlphaComponent(0.7),
        .font: R.font.milliardMedium(size: 16)!
    ]
    private let selectedAttributes: [NSAttributedString.Key: Any] = [
        .foregroundColor: UIColor.white,
        .font: R.font.milliardSemiBold(size: 18)!
    ]
    
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
        addSubview(btnLive)
        btnLive.snp.makeConstraints { make in
            make.size.equalTo(30)
            make.left.equalToSuperview().offset(20)
            make.centerY.equalToSuperview()
        }
        
        addSubview(btnSearch)
        btnSearch.snp.makeConstraints { make in
            make.size.equalTo(30)
            make.right.equalToSuperview().inset(20)
            make.centerY.equalToSuperview()
        }
        
        addSubview(vContainerButtons)
        vContainerButtons.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        vContainerButtons.addArrangedSubview(btnFollowing)
        vContainerButtons.addArrangedSubview(vHorizontalSeparator)
        vContainerButtons.addArrangedSubview(btnForYou)
        
        vHorizontalSeparator.snp.makeConstraints { make in
            make.height.equalTo(10)
            make.width.equalTo(1)
        }
        
        tabButtons = [btnFollowing, btnForYou]
        tabButtons.forEach { $0.isSelected = false }
        tabButtons[1].isSelected = true
    }
    
    private func bindingUI() {
        // LiveStream tapped
        btnLive.rx.tap
            .throttle(.seconds(1), scheduler: MainScheduler.instance)
            .map { Event.didTapLiveStream }
            .bind(to: eventPublisher)
            .disposed(by: disposeBag)
        
        // Search tapped
        btnSearch.rx.tap
            .throttle(.seconds(1), scheduler: MainScheduler.instance)
            .map { Event.didTapSearch }
            .bind(to: eventPublisher)
            .disposed(by: disposeBag)
        
        // Did select tab
        let tabButtonsIndexObservable = tabButtons.enumerated()
            .map { ($0.0, $0.1.rx.tap.mapToVoid()) }
            .map { index, observable in
                observable.map { index }
            }
        
        Observable.merge(tabButtonsIndexObservable)
            .do(onNext: { [weak self] selectedIndex in
                self?.tabButtons.enumerated().forEach { index, button in
                    UIView.transition(with: button, duration: 0.5, options: .transitionCrossDissolve) {
                        button.isSelected = index == selectedIndex
                    }
                }
            })
            .map { Event.didSelectTab($0) }
            .bind(to: eventPublisher)
            .disposed(by: disposeBag)
    }
}
