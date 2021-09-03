//
//  UIEdgeInsets+Ext.swift
//  42Events
//
//  Created by Nguyên Duy on 20/05/2021.
//

import UIKit

extension UIEdgeInsets {
    init(all value: CGFloat) {
        self.init(top: value, left: value, bottom: value, right: value)
    }
    
    var vertical: CGFloat {
        return top + bottom
    }
    
    var horizontal: CGFloat {
        return left + right
    }
}
