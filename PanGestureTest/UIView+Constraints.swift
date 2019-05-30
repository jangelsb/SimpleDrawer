//
//  UIView+Constraints.swift
//  PanGestureTest
//
//  Created by Josh Angelsberg on 5/29/19.
//  Copyright © 2019 Josh Angelsberg. All rights reserved.
//

import UIKit

extension UIView {
    public func clearConstraints() {
        for subview in self.subviews {
            subview.clearConstraints()
        }
        self.removeConstraints(self.constraints)
    }
    
    public func removeAllConstraints() {
        var _superview = self.superview
        
        while let superview = _superview {
            for constraint in superview.constraints {
                
                if let first = constraint.firstItem as? UIView, first == self {
                    superview.removeConstraint(constraint)
//                    (constraint.secondItem as? UIView)?.translatesAutoresizingMaskIntoConstraints = true
                }
                
                if let second = constraint.secondItem as? UIView, second == self {
                    superview.removeConstraint(constraint)
//                    (constraint.firstItem as? UIView)?.translatesAutoresizingMaskIntoConstraints = true
                }
            }
            
            _superview = superview.superview
        }
        
        self.removeConstraints(self.constraints)
        self.translatesAutoresizingMaskIntoConstraints = true
    }
}

//
//public func removeAllConstraints() {
//    var _superview: UIView? = self
//    
//    while let superview = _superview {
//        for constraint in superview.constraints {
//            
//            if let first = constraint.firstItem as? UIView, first == self {
//                superview.removeConstraint(constraint)
//                //                    (constraint.secondItem as? UIView)?.translatesAutoresizingMaskIntoConstraints = true
//            }
//            
//            if let second = constraint.secondItem as? UIView, second == self {
//                superview.removeConstraint(constraint)
//                //                    (constraint.firstItem as? UIView)?.translatesAutoresizingMaskIntoConstraints = true
//            }
//        }
//        
//        _superview = superview.superview
//    }
//    
//    //        self.removeConstraints(self.constraints)
//    self.translatesAutoresizingMaskIntoConstraints = true
//}
