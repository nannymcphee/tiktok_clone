//
//  UIImageView+Ext.swift
//  42Events
//
//  Created by Nguyên Duy on 19/05/2021.
//

import Kingfisher

extension UIImageView {
    public func setImage(url: String, placeholder: UIImage? = nil) {
        guard let url = URL(string: url) else {
            self.image = placeholder
            return
        }
        self.kf.indicatorType = .activity
        self.kf.setImage(with: url, placeholder: placeholder, options: nil, completionHandler: nil)
    }
}
