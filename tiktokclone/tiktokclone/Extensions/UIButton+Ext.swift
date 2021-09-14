//
//  UIButton+Ext.swift
//  tiktokclone
//
//  Created by Duy Nguyen on 12/09/2021.
//

import UIKit

extension UIButton {
    func alignImageAndTitleVertically(padding: CGFloat = 3.0) {
        guard let titleText = titleLabel?.text, let imageSize = imageView?.image?.size else { return }
        let labelString = NSString(string: titleText)
        let titleSize = labelString.size(withAttributes: [kCTFontAttributeName as NSAttributedString.Key: titleLabel?.font ?? UIFont.systemFont(ofSize: 16)])
        let leftConstraint = self.bounds.width - titleSize.width
        titleEdgeInsets = UIEdgeInsets.init(top: 0.0, left: -leftConstraint, bottom: -(imageSize.height + padding), right: 0.0)
        self.imageEdgeInsets = UIEdgeInsets.init(top: -(titleSize.height + padding), left: 0.0, bottom: 0.0, right: -titleSize.width)
        let edgeOffset = abs(titleSize.height - imageSize.height) / 2.0;
        self.contentEdgeInsets = UIEdgeInsets.init(top: edgeOffset, left: 0.0, bottom: edgeOffset, right: 0.0)
    }
    
    /// Fits the image and text content with a given spacing
    /// - Parameters:
    ///   - spacing: Spacing between the Image and the text
    ///   - contentXInset: The spacing between the view to the left image and the right text to the view
    func setHorizontalMargins(imageTextSpacing: CGFloat, contentXInset: CGFloat = 0) {
        let imageTextSpacing = imageTextSpacing / 2
        
        contentEdgeInsets = UIEdgeInsets(top: 0, left: (imageTextSpacing + contentXInset), bottom: 0, right: (imageTextSpacing + contentXInset))
        imageEdgeInsets = UIEdgeInsets(top: 0, left: -imageTextSpacing, bottom: 0, right: imageTextSpacing)
        titleEdgeInsets = UIEdgeInsets(top: 0, left: imageTextSpacing, bottom: 0, right: -imageTextSpacing)
    }
}
