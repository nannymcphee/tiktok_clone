//
//  RxBaseViewController.swift
//  Object Detector
//
//  Created by Duy Nguyen on 30/08/2021.
//

import UIKit
import RxSwift

class RxBaseViewController<T: ViewModelTransformable>: BaseVC {
    typealias Input = T.Input
    
    let viewModel: T
    let disposeBag = DisposeBag()
    let refreshControl = UIRefreshControl()
    let refreshTrigger = PublishSubject<Void>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initRefreshControl()
    }
    
    init(viewModel: T, nibName: String? = nil) {
        self.viewModel = viewModel
        super.init(nibName: nibName, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func keyboardHeight() -> Observable<(height: CGFloat, notification: Notification)> {
        return Observable
            .merge([
                NotificationCenter.default.rx.notification(UIResponder.keyboardWillShowNotification)
                    .map { notification -> (height: CGFloat, notification: Notification) in
                        let height = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.height ?? 0
                        return (height: height, notification: notification)
                    },
                NotificationCenter.default.rx.notification(UIResponder.keyboardWillHideNotification)
                    .map { notification -> (height: CGFloat, notification: Notification) in
                        return (height: 0, notification: notification)
                    }
            ])
    }
    
    private func initRefreshControl() {
        refreshControl.rx
            .controlEvent(.valueChanged)
            .asObservable()
            .bind(to: refreshTrigger)
            .disposed(by: disposeBag)
    }
}
