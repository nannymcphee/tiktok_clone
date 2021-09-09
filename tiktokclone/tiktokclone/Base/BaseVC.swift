//
//  BaseVC.swift
//  Object Detector
//
//  Created by Duy Nguyen on 21/08/2021.
//

import RxSwift
import RxSwiftExt

class BaseVC: UIViewController, ErrorHandler {
    private lazy var lbScreenTitle: UILabel = {
        let lbTitle = UILabel(frame: CGRect(x: 0, y: 0, width: 150, height: 40))
        lbTitle.textColor = .white
        lbTitle.font = R.font.milliardSemiBold(size: 18)
        lbTitle.textAlignment = .center
        return lbTitle
    }()
    
    var topSafeArea: CGFloat = 0
    var statusBarHeight: CGFloat = 0
    var bottomSafeArea: CGFloat = 0
    var tabBarHeight: CGFloat {
        self.tabBarController?.tabBar.frame.size.height ?? 49
    }
    var keyWindow: UIWindow? {
        return UIApplication.shared.connectedScenes
            .filter { $0.activationState == .foregroundActive }
            .compactMap {$0 as? UIWindowScene }
            .first?.windows
            .filter(\.isKeyWindow).first
    }
    
    var topBarHeight: CGFloat {
        if #available(iOS 13.0, *) {
            return (view.window?.windowScene?.statusBarManager?.statusBarFrame.height ?? 0.0) +
                (self.navigationController?.navigationBar.frame.height ?? 0.0)
        } else {
            return UIApplication.shared.statusBarFrame.size.height +
                (self.navigationController?.navigationBar.frame.height ?? 0.0)
        }
    }
    
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
        if #available(iOS 13.0, *) {
            topSafeArea = keyWindow?.safeAreaInsets.top ?? 0
            bottomSafeArea = keyWindow?.safeAreaInsets.bottom ?? 0
            statusBarHeight = view.window?.windowScene?.statusBarManager?.statusBarFrame.height ?? 0
        } else {
            statusBarHeight = UIApplication.shared.statusBarFrame.height
            bottomSafeArea = bottomLayoutGuide.length
            topSafeArea = topLayoutGuide.length
        }
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
    
    func setScreenTitle(_ title: String,
                        font: UIFont? = nil,
                        textColor: UIColor = .white) {
        lbScreenTitle.text = title
        lbScreenTitle.font = font ?? R.font.milliardSemiBold(size: 18)
        lbScreenTitle.textColor = textColor
        navigationController?.navigationBar.topItem?.titleView = lbScreenTitle
    }
    
    func getIconBarButtonItem(icon: UIImage?,
                              target: UIViewController? = nil,
                              action: Selector? = nil) -> UIBarButtonItem {
        let barButton = UIBarButtonItem(image: icon, style: .plain, target: target, action: action)
        barButton.tintColor = .white
        return barButton
    }
}

extension Reactive where Base: BaseVC {
    var isLoading: Binder<Bool> { Binder(base) { $1 ? $0.showLoading() : $0.hideLoading() }}
    var error: Binder<(Error, ErrorAction)> {
        Binder(base) { (base: Base, payload: (err: Error, action: ErrorAction)) in
            base.handle(error: payload.err, action: payload.action)
        }
    }
}
