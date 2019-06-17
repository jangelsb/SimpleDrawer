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
    
    var isBouncingBottom: Bool {
        return contentOffset.y > abs(contentSize.height - frame.size.height + contentInset.bottom + adjustedContentInset.bottom) + 4
    }
    
    var distanceFromBottom: CGFloat {
        if !isBouncingBottom {
            return 0.0
        }
        
        return contentOffset.y - (contentSize.height - frame.size.height + contentInset.bottom)
    }
    
    func scrollToBottom(animated: Bool) {
        let bottomOffset = CGPoint(x: 0, y: contentSize.height - bounds.size.height + adjustedContentInset.bottom)
        setContentOffset(bottomOffset, animated: animated)
        
//        self.scrollRectToVisible(CGRect(x: 0, y: 0, width: 1, height: 1), animated: animated)
//        self.scrollRectToVisible(CGRect(x: 0, y: contentSize.height + adjustedContentInset.bottom, width: 1, height: 1), animated: animated)
    }
}
