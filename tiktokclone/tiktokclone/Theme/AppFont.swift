//
//  AppFont.swift
//  tiktokclone
//
//  Created by Duy Nguyen on 03/09/2021.
//

import UIKit

protocol AppFontProtocol {
    func hairline(_ size: CGFloat)      -> UIFont
    func thin(_ size: CGFloat)          -> UIFont
    func extraLight(_ size: CGFloat)    -> UIFont
    func light(_ size: CGFloat)         -> UIFont
    func regular(_ size: CGFloat)       -> UIFont
    func medium(_ size: CGFloat)        -> UIFont
    func semiBold(_ size: CGFloat)      -> UIFont
    func bold(_ size: CGFloat)          -> UIFont
    func extraBold(_ size: CGFloat)     -> UIFont
    func heavy(_ size: CGFloat)         -> UIFont
    func black(_ size: CGFloat)         -> UIFont
    func book(_ size: CGFloat)          -> UIFont
}

struct MilliardFont: AppFontProtocol {
    func hairline(_ size: CGFloat)      -> UIFont { UIFont(name: "Milliard-Hairline", size: size) ?? .systemFont(ofSize: size) }
    func thin(_ size: CGFloat)          -> UIFont { UIFont(name: "Milliard-Thin", size: size) ?? .systemFont(ofSize: size) }
    func extraLight(_ size: CGFloat)    -> UIFont { UIFont(name: "Milliard-ExtrLight", size: size) ?? .systemFont(ofSize: size) }
    func light(_ size: CGFloat)         -> UIFont { UIFont(name: "Milliard-Light", size: size) ?? .systemFont(ofSize: size) }
    func regular(_ size: CGFloat)       -> UIFont { UIFont(name: "Milliard-Regular", size: size) ?? .systemFont(ofSize: size) }
    func medium(_ size: CGFloat)        -> UIFont { UIFont(name: "Milliard-Medium", size: size) ?? .systemFont(ofSize: size) }
    func semiBold(_ size: CGFloat)      -> UIFont { UIFont(name: "Milliard-SemiBold", size: size) ?? .systemFont(ofSize: size) }
    func bold(_ size: CGFloat)          -> UIFont { UIFont(name: "Milliard-Bold", size: size) ?? .systemFont(ofSize: size) }
    func extraBold(_ size: CGFloat)     -> UIFont { UIFont(name: "Milliard-ExtraBold", size: size) ?? .systemFont(ofSize: size) }
    func heavy(_ size: CGFloat)         -> UIFont { UIFont(name: "Milliard-Heavy", size: size) ?? .systemFont(ofSize: size) }
    func black(_ size: CGFloat)         -> UIFont { UIFont(name: "Milliard-Black", size: size) ?? .systemFont(ofSize: size) }
    func book(_ size: CGFloat)          -> UIFont { UIFont(name: "Milliard-Book", size: size) ?? .systemFont(ofSize: size) }
}
