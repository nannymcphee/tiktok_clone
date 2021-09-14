//
//  InsetTextFIeld.swift
//  tiktokclone
//
//  Created by Duy Nguyen on 11/09/2021.
//

import UIKit

class InsetTextField: UITextField {
    let inset: CGFloat = 10

    override func textRect(forBounds bounds: CGRect) -> CGRect {
      return bounds.insetBy(dx: inset, dy: inset)
    }

    override func editingRect(forBounds bounds: CGRect) -> CGRect {
      return bounds.insetBy(dx: inset, dy: inset)
    }

    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
      return bounds.insetBy(dx: inset, dy: inset)
    }
}
