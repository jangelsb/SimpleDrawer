//
//  UIScrollView+Bounce.swift
//  PanGestureTest
//
//  Created by Josh Angelsberg on 8/5/18.
//  Copyright © 2018 Josh Angelsberg. All rights reserved.
//

import UIKit

// taken from https://stackoverflow.com/a/42951161
extension UIScrollView {
    var isBouncing: Bool {
        return isBouncingTop || isBouncingLeft || isBouncingBottom || isBouncingRight
    }
    var isBouncingTop: Bool {
        return contentOffset.y < -contentInset.top
    }
    var isBouncingLeft: Bool {
        return contentOffset.x < -contentInset.left
    }
//    var isBouncingBottom: Bool {
//        let contentFillsScrollEdges = contentSize.height + contentInset.top + contentInset.bottom >= bounds.height
//        return contentFillsScrollEdges && contentOffset.y > contentSize.height - bounds.height + contentInset.bottom
//    }
    var isBouncingRight: Bool {
        let contentFillsScrollEdges = contentSize.width + contentInset.left + contentInset.right >= bounds.width
        return contentFillsScrollEdges && contentOffset.x > contentSize.width - bounds.width + contentInset.right
    }
    
    var atBottomStrict: Bool {
        return contentOffset.y >= contentSize.height - frame.size.height && contentOffset.y <= abs(contentSize.height - frame.size.height) + 4
    }
    
    // TODO: update all contentInset.bottom to (UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? 0.0) ???
    // TODO: update all contentInset.top to (UIApplication.shared.keyWindow?.safeAreaInsets.top ?? 0.0) ???
    var isBouncingBottom: Bool {
        let x = contentOffset.y > abs(contentSize.height - frame.size.height + (UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? 0.0)) + 4
        
        return x
    }
    
    var distanceFromBottom: CGFloat {
        if !isBouncingBottom {
            return 0.0
        }
        
        return contentOffset.y - (contentSize.height - frame.size.height + contentInset.bottom)
    }
    
//    func scrollToBottom(animated: Bool) {
//
//        // TODO: remove or unhardcode this
//        let bigTitleDiff = adjustedContentInset.top > 88 ? adjustedContentInset.top - 88 : 0
//
//        var y: CGFloat = -self.adjustedContentInset.top - 8 // set the content to the top, unless contentSize.height > frame.size.height
//
//        if contentSize.height > frame.size.height {
//            y = contentSize.height - frame.size.height //+ (UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? 0.0) - bigTitleDiff
//        }
//
//        let bottomOffset = CGPoint(x: 0, y: y)
//        setContentOffset(bottomOffset, animated: animated)
//    }
//
//    func scrollToTop(animated: Bool) {
//        // TODO: figure out a better way, instead of hard coding 8 (it is needed for the large title bars)
//        // It still works fine if the title bar is also small
//        let offset = CGPoint(
//            x: -self.adjustedContentInset.left,
//            y: -self.adjustedContentInset.top - 8)
//
//        self.setContentOffset(offset, animated: animated)
//    }
}



// https://stackoverflow.com/a/39018651/9605061
extension UIScrollView {
    
    // Scroll to a specific view so that it's top is at the top our scrollview
    func scrollToView(view:UIView, animated: Bool) {
        if let origin = view.superview {
            // Get the Y position of your child view
            let childStartPoint = origin.convert(view.frame.origin, to: self)
            // Scroll to a rectangle starting at the Y of your subview, with a height of the scrollview
            self.scrollRectToVisible(CGRect(x:0, y:childStartPoint.y,width: 1,height: self.frame.height), animated: animated)
        }
    }
    
    // Bonus: Scroll to top
    func scrollToTop(animated: Bool) {
        let topOffset = CGPoint(x: 0, y: -contentInset.top)
        setContentOffset(topOffset, animated: animated)
    }
    
    // Bonus: Scroll to bottom
    public func scrollToBottom(animated: Bool) {
        let bottomOffset = CGPoint(x: 0, y: contentSize.height - bounds.size.height + adjustedContentInset.bottom) //contentInset.bottom)
        if(bottomOffset.y > 0) {
            setContentOffset(bottomOffset, animated: animated)
        }
        
        // UIApplication.shared.keyWindow?.safeAreaInsets always has a bottom of 34
        
        
//        let bottomOffset = CGPoint(x: 0, y: scrollView.contentSize.height - scrollView.bounds.height + scrollView.)
//        scrollView.setContentOffset(bottomOffset, animated: true)
    }
    
}
