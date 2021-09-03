//
//  Device.swift
//  tiktokclone
//
//  Created by Duy Nguyen on 03/09/2021.
//

import UIKit

public struct Device {
    // iDevice detection code
    public static let isIpad             = UIDevice.current.userInterfaceIdiom == .pad
    public static let isIphone           = UIDevice.current.userInterfaceIdiom == .phone
    public static let isRetina           = UIScreen.main.scale >= 2.0
    
    public static let screenWidth        = UIScreen.main.bounds.size.width
    public static let screenHeight       = UIScreen.main.bounds.size.height
    public static let screenMaxLength    = max(screenWidth, screenHeight)
    public static let screenMinLength    = min(screenWidth, screenHeight)
    public static let ratio              = UIScreen.main.bounds.size.width / CGFloat(375)
    
    public static let isIphone4OrLess    = isIphone && screenMaxLength  < 568
    public static let isIphone5OrLess    = isIphone && screenMaxLength <= 568
    public static let isIphone6OrLess    = isIphone && screenMaxLength <= 736
    public static let isIphone5          = isIphone && screenMaxLength == 568
    public static let isIphone6          = isIphone && screenMaxLength == 736
    public static let isIphone6P         = isIphone && screenMaxLength == 736
    public static let isIphoneX          = isIphone && screenMaxLength == 812
    public static let isIphoneXOrAbove   = isIphone && Device.hasTopNotch
    
    public static var hasTopNotch: Bool {
        if #available(iOS 11.0, tvOS 11.0, *) {
            return UIApplication.shared.delegate?.window??.safeAreaInsets.top ?? 0 > 20
        }
        return false
    }
}
