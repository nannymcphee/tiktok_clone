//
//  UIView+Ext.swift
//  42Events
//
//  Created by Nguyên Duy on 19/05/2021.
//

import UIKit

extension UIView {
    func rotate() {
        let rotation : CABasicAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
        rotation.toValue = NSNumber(value: Double.pi * 2)
        rotation.duration = 3
        rotation.isCumulative = true
        rotation.repeatCount = Float.greatestFiniteMagnitude
        self.layer.add(rotation, forKey: "rotationAnimation")
    }
    
    func customBorder(cornerRadius: CGFloat, borderWidth: CGFloat, color: UIColor) {
        self.layer.cornerRadius = cornerRadius
        self.layer.borderWidth = borderWidth
        self.layer.borderColor = color.cgColor
        self.layer.masksToBounds = true
        self.clipsToBounds = true
    }
    
    func animationRotate90Degrees() {
        UIView.animate(withDuration: 0.25) { [weak self] in
            guard let self = self else { return }
            self.transform = CGAffineTransform(rotationAngle: .pi/2)
        }
    }
    
    func animationRotateBackToDefault() {
        UIView.animate(withDuration: 0.25) { [weak self] in
            guard let self = self else { return }
            self.transform = .identity
        }
    }
    
    // retrieves all constraints that mention the view
    func getAllConstraints() -> [NSLayoutConstraint] {
        
        // array will contain self and all superviews
        var views = [self]
        
        // get all superviews
        var view = self
        while let superview = view.superview {
            views.append(superview)
            view = superview
        }
        
        // transform views to constraints and filter only those
        // constraints that include the view itself
        return views.flatMap({ $0.constraints }).filter { constraint in
            return constraint.firstItem as? UIView == self ||
                constraint.secondItem as? UIView == self
        }
    }
    
    // Example 1: Get all width constraints involving this view
    // We could have multiple constraints involving width, e.g.:
    // - two different width constraints with the exact same value
    // - this view's width equal to another view's width
    // - another view's height equal to this view's width (this view mentioned 2nd)
    func getWidthConstraints() -> [NSLayoutConstraint] {
        return getAllConstraints().filter( {
            ($0.firstAttribute == .width && $0.firstItem as? UIView == self) ||
                ($0.secondAttribute == .width && $0.secondItem as? UIView == self)
        } )
    }
    
    func getLeadingConstraints() -> NSLayoutConstraint {
        return getAllConstraints().filter( {
            ($0.firstAttribute == .leading && $0.firstItem as? UIView == self) ||
                ($0.secondAttribute == .leading && $0.secondItem as? UIView == self)
        } ).first!
    }
    
    func getTrailingConstraints() -> NSLayoutConstraint {
        return getAllConstraints().filter( {
            ($0.firstAttribute == .trailing && $0.firstItem as? UIView == self) ||
                ($0.secondAttribute == .trailing && $0.secondItem as? UIView == self)
        } ).first!
    }
    
    // Example 2: Change width constraint(s) of this view to a specific value
    // Make sure that we are looking at an equality constraint (not inequality)
    // and that the constraint is not against another view
    func changeWidth(to value: CGFloat) {
        
        getAllConstraints().filter( {
            $0.firstAttribute == .width &&
                $0.relation == .equal &&
                $0.secondAttribute == .notAnAttribute
        } ).forEach( {$0.constant = value })
    }
    
    func changeSize(to value: CGFloat) {
        changeWidth(to: value)
        changeHeight(to: value)
    }
    
    // Example 3: Change leading constraints only where this view is
    // mentioned first. We could also filter leadingMargin, left, or leftMargin
    func changeLeading(to value: CGFloat) {
        getAllConstraints().filter( {
            $0.firstAttribute == .leading &&
                $0.firstItem as? UIView == self
        }).forEach({$0.constant = value})
    }
    
    func changeTrailing(to value: CGFloat) {
        getAllConstraints().filter( {
            $0.firstAttribute == .trailing &&
                $0.firstItem as? UIView == self
        }).forEach({$0.constant = value})
    }
    
    func getHeightConstraints() -> [NSLayoutConstraint] {
        return getAllConstraints().filter( {
            ($0.firstAttribute == .height && $0.firstItem as? UIView == self) ||
                ($0.secondAttribute == .height && $0.secondItem as? UIView == self)
        } )
    }
    
    func changeHeight(to value: CGFloat) {
        getAllConstraints().filter( {
            $0.firstAttribute == .height &&
                $0.relation == .equal &&
                $0.secondAttribute == .notAnAttribute
        } ).forEach( {$0.constant = value })
    }
    
    func layoutAttachAll(to view: UIView) {
        self.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
            self.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0),
            self.topAnchor.constraint(equalTo: view.topAnchor, constant: 0),
            self.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0)
        ])
    }
    
    func setTikTokButtonStyle() {
        customBorder(cornerRadius: 2, borderWidth: 1, color: .clear)
    }
}
