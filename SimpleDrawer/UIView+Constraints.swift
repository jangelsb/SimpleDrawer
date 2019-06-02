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
            
            let constraints = superview.constraints.filter { (constraint) -> Bool in
                return constraint.firstItem as? UIView == self || constraint.secondItem as? UIView == self
            }
            
            superview.removeConstraints(constraints)
            _superview = superview.superview
        }
        
        self.removeConstraints(self.constraints)
        self.translatesAutoresizingMaskIntoConstraints = true
    }
    
    func removeConstraintsForAllSubViews() {
        for view in self.subviews {
            view.removeConstraintsForAllSubViews()
        }
        
        removeAllConstraints()
    }
}
