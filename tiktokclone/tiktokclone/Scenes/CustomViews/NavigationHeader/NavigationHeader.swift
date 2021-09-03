//
//  NavigationHeader.swift
//  tiktokclone
//
//  Created by Duy Nguyen on 03/09/2021.
//

import UIKit
import RxSwift
import RxCocoa

open class NavigationHeader: BaseView {
    @IBOutlet private weak var lbTitle: UILabel!
    @IBOutlet private weak var btnLeft: UIButton!
    @IBOutlet private weak var btnRight: UIButton!
    
    //Rx
    fileprivate let _leftTrigger = PublishSubject<Void>()
    public var leftTrigger: Observable<Void> {
        return _leftTrigger.asObservable()
    }
    
    fileprivate let _rightTrigger = PublishSubject<Void>()
    public var rightTrigger: Observable<Void> {
        return _rightTrigger.asObservable()
    }
    
    public override func initialize() {
        setDefaultUI()
        bindingUI()
    }
    
    private func setDefaultUI() {
        self.lbTitle.text = ""
        self.lbTitle.font = R.font.milliardSemiBold(size: 18)
        self.btnLeft.setImage(nil, for: .normal)
        self.btnRight.setImage(nil, for: .normal)
        self.backgroundColor = .clear
    }
    
    public func setTitleHeader(text: String,
                               font: UIFont? = nil) {
        self.lbTitle.text = text
        self.lbTitle.font = font ?? R.font.milliardSemiBold(size: 18)
        self.lbTitle.adjustsFontSizeToFitWidth = true
        self.lbTitle.minimumScaleFactor = 0.6
    }
    
    public func setLeftTitleButton(title: String,
                                   font: UIFont? = nil) {
        self.btnLeft.setImage(nil, for: .normal)
        self.btnLeft.setTitle(title, for: .normal)
        self.btnLeft.titleLabel?.font = font ?? R.font.milliardSemiBold(size: 18)
    }
    
    public func setRightTitleButton(title: String,
                                    font: UIFont? = nil) {
        self.btnRight.setImage(nil, for: .normal)
        self.btnRight.setTitle(title, for: .normal)
        self.btnRight.titleLabel?.font = font ?? R.font.milliardSemiBold(size: 16)
    }
    
    public func setTheme(titleColor: UIColor,
                         leftButtonColor: UIColor  = .clear,
                         rightButtonColor: UIColor = .clear,
                         bgColor: UIColor = .clear) {
        self.lbTitle.textColor              = titleColor
        self.btnLeft.tintColor              = leftButtonColor
        self.btnLeft.setTitleColor(leftButtonColor, for: .normal)
        self.btnRight.setTitleColor(rightButtonColor, for: .normal)
        self.btnRight.tintColor             = rightButtonColor
        self.backgroundColor                = bgColor
    }
    
    public func setIconButton(leftIcon : UIImage?,
                              rightIcon: UIImage?) {
        self.btnLeft.setImage(leftIcon, for: .normal)
        self.btnRight.setImage(rightIcon, for: .normal)
    }
    
    public func constraint(to view: UIView) {
        guard self.superview == nil else { return }
        view.addSubview(self)
        translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
            trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0),
            topAnchor.constraint(equalTo: view.topAnchor, constant: 0),
            bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0)
        ])
    }
    
    private func bindingUI() {
        //Left Button
        btnLeft.rx.tap
            .asObservable()
            .bind(to: _leftTrigger)
            .disposed(by: disposeBag)
        
        //Right Button
        btnRight.rx.tap
            .asObservable()
            .bind(to: _rightTrigger)
            .disposed(by: disposeBag)
    }
}
