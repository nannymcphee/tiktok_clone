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

extension UIImage {
    convenience init?(color: UIColor, size: CGSize = CGSize(width: 1, height: 1)) {
      let rect = CGRect(origin: .zero, size: size)
      UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0)
      color.setFill()
      UIRectFill(rect)
      let image = UIGraphicsGetImageFromCurrentImageContext()
      UIGraphicsEndImageContext()
      
      guard let cgImage = image?.cgImage else { return nil }
      self.init(cgImage: cgImage)
    }
}
