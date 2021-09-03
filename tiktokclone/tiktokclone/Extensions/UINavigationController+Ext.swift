//
//  UINavigationController+Ext.swift
//  tiktokclone
//
//  Created by Duy Nguyen on 03/09/2021.
//

import UIKit

extension UINavigationController {
    func transparentNavigationBar() {
        navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationBar.shadowImage = UIImage()
        navigationBar.isTranslucent = true
    }

    func setTintColor(_ color: UIColor) {
        navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: color]
        navigationBar.tintColor = color
    }

    func backgroundColor(_ color: UIColor) {
        navigationBar.setBackgroundImage(nil, for: .default)
        navigationBar.barTintColor = color
        navigationBar.shadowImage = UIImage()
        navigationBar.isTranslucent = false
    }
}
