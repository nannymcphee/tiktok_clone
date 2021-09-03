//
//  BaseViewController.swift
//  Object Detector
//
//  Created by Duy Nguyen on 21/08/2021.
//

import RxSwift
import RxSwiftExt

class BaseViewController: UIViewController {    
    var isSwipeBackEnabled: Bool = false {
        didSet {
            self.navigationController?.interactivePopGestureRecognizer?.isEnabled = isSwipeBackEnabled
        }
    }
    let kAnimationDuration: TimeInterval = 0.2
    
    private let kBtnBackWidth: CGFloat = 36
    
    deinit {
        Logger.i("\(String(describing: type(of: self))) deinit", tag: "🔴🔴🔴🔴")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpColors()
    }
    
    open func showLoading(loadingMessage: String? = nil) {
        DispatchQueue.main.async {
            LoadingViewHelper.showLoading(in: self.view,
                                          loadingMessage: loadingMessage)
        }
    }
    
    open func hideLoading() {
        DispatchQueue.main.async {
            LoadingViewHelper.hideLoading()
        }
    }
    
    open func closeViewController() {
        self.view.endEditing(true)
        if let navigation = self.navigationController {
            if navigation.viewControllers.count == 1 {
                self.dismiss(animated: true, completion: nil)
            } else {
                navigation.popViewController(animated: true)
            }
        } else {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    open func setUpColors() {}
    
    open func setUpLocalize() {}
    
    func getIconBarButtonItem(icon: UIImage?,
                              target: UIViewController? = nil,
                              action: Selector? = nil) -> UIBarButtonItem {
        let barButton = UIBarButtonItem(image: icon, style: .plain, target: target, action: action)
        barButton.tintColor = .white
        return barButton
    }
}

extension Reactive where Base: BaseViewController {
    var isLoading: Binder<Bool> { Binder(base) { $1 ? $0.showLoading() : $0.hideLoading() }}
}
