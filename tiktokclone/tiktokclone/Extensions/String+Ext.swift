//
//  String+Ext.swift
//  42Events
//
//  Created by Nguyên Duy on 20/05/2021.
//

import UIKit

extension String {
    var capitalizeFirst:String {
        var result: String = self
        result.replaceSubrange(startIndex...startIndex, with: String(self[startIndex]).capitalized)
        return result
    }
    
    func labelSize(font: UIFont, considering maxWidth: CGFloat) -> CGSize {
        let attributedText = NSAttributedString(string: self, attributes: [.font: font])
        let constraintBox = CGSize(width: maxWidth, height: .greatestFiniteMagnitude)
        let rect = attributedText.boundingRect(with: constraintBox, options: [.usesLineFragmentOrigin, .usesFontLeading], context: nil).integral
        return CGSize(width: ceil(rect.size.width), height: ceil(rect.size.height))
    }
    
    func replace(_ target: String, withString: String) -> String {
        return self.replacingOccurrences(of: target, with: withString, options: NSString.CompareOptions.literal, range: nil)
    }
}
