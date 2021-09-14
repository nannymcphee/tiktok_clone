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
    
    func createAttributedString(textToStyle: String, attributes: [NSAttributedString.Key : Any], styledAttributes: [NSAttributedString.Key : Any]) -> NSMutableAttributedString {
        let attributedResultText = NSMutableAttributedString(string: self, attributes: attributes)
        let range = (self as NSString).range(of: textToStyle)
        attributedResultText.addAttributes(styledAttributes, range: range)
        return attributedResultText
    }
    
    func matches(for regex: String) -> [String] {
        do {
            let regex = try NSRegularExpression(pattern: regex)
            let results = regex.matches(in: self,
                                        range: NSRange(self.startIndex..., in: self))
            return results.map {
                String(self[Range($0.range, in: self)!])
            }
        } catch let error {
            print("invalid regex: \(error.localizedDescription)")
            return []
        }
    }
}

extension NSMutableAttributedString {
    @discardableResult
    func customAddAttributes(_ attributes: [NSAttributedString.Key: Any], text: String) -> [NSRange] {
        var searchRange = NSRange(location: 0, length: self.string.utf16.count)
        var foundRange = NSRange()
        var foundRanges = [NSRange]()
        while searchRange.location < self.string.utf16.count {
            searchRange.length = self.string.utf16.count - searchRange.location
            foundRange = (self.string as NSString).range(of: text, options: NSString.CompareOptions.caseInsensitive, range: searchRange)
            if foundRange.location != NSNotFound {
                // found an occurrence of the substring! do stuff here
                searchRange.location = foundRange.location + foundRange.length
                self.addAttributes(attributes, range: foundRange)
                foundRanges.append(foundRange)
            } else {
                // no more substring to find
                break
            }
        }
        return foundRanges
    }
}
