//
//  BaseView.swift
//  tiktokclone
//
//  Created by Duy Nguyen on 03/09/2021.
//

import UIKit
import RxSwift

open class BaseView: UIView, NibLoadable {
    @IBOutlet weak var subView: UIView!
    
    var disposeBag = DisposeBag()
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        bindService()
        initialize()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
//        nibSetup()
//        bindService()
//        initialize()
    }
    
    open override func awakeFromNib() {
        super.awakeFromNib()
        
        initialize()
        bindService()
    }
    
    private func bindService() {
        
    }
    
    open func localizeChanged() {}
    
    open func themeChanged() {}
    
    open func initialize() {}
    
    open func reset() {
        self.disposeBag = DisposeBag()
    }
    
    public func nibSetup() {
        subView                    = loadViewFromNib()
        subView.frame              = bounds
        subView.autoresizingMask   = [.flexibleWidth, .flexibleHeight]
        subView.translatesAutoresizingMaskIntoConstraints = true
        subView.backgroundColor    = .clear
        backgroundColor            = .clear
        addSubview(subView)
    }
    
    private func loadViewFromNib() -> UIView {
        let bundle  = Bundle(for: type(of: self))
        let nib     = UINib(nibName: String(describing: type(of: self)), bundle: bundle)
        let nibView = nib.instantiate(withOwner: self, options: nil).first as! UIView
        return nibView
    }
}
