//
//  WKWebView+Ext.swift
//  42Events
//
//  Created by Duy Nguyen on 07/06/2021.
//

import WebKit
import RxSwift

extension WKWebView {
    func requestDesktopMode() {
        self.customUserAgent = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_10_5) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/48.0.2564.109 Safari/537.36"
    }
}

extension Reactive where Base: WKWebView {
    
    var loading: Observable<Bool> {
        return observeWeakly(Bool.self, "loading", options: [.initial, .new]) .map { $0 ?? false }
    }
    
}
