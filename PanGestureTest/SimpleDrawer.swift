//
//  ViewController.swift
//  PanGestureTest
//
//  Created by Josh Angelsberg on 7/8/18.
//  Copyright © 2018 Josh Angelsberg. All rights reserved.
//

import UIKit

struct SimpleDrawerInfo {
//    - [ ] DrawerContentVC
//    - [ ] DrawerHandleView
//    - Use it’s height
    
    
    var drawerInView: UIView
    var drawerContentViewController: UIViewController
    var drawerHandleView: UIView
    
    var embeddedScrollView: UIScrollView?
}

class SimpleDrawer: NSObject, UIGestureRecognizerDelegate {
    
    var drawerInfo: SimpleDrawerInfo
    
    var drawerView: UIView!
//    var combindedDrawer: UIView!

    var drawerDragGR: UIPanGestureRecognizer?

    var innerScrollPanGR: UIPanGestureRecognizer?
    
    var prevY: CGFloat = 0
    
    var drawerHandleStartPoint: CGFloat = 0.0
    var drawerHandleEndPoint: CGFloat = 0.0

    var currentDrawerState: DrawerState = .closed {
        didSet{
            print("Drawer is now \(currentDrawerState)")
            
            if let scrollView = self.drawerInfo.embeddedScrollView {
                
                switch currentDrawerState {
                case .closed:
                    scrollView.isScrollEnabled = false
                    scrollView.bounces = false
                    
                    break
                case .open:
                    scrollView.isScrollEnabled = true
                    scrollView.bounces = true
                    break
                    
                case .beingDragged:
                    scrollView.bounces = false
                    break
                    
                default:
                    // don't change anything
                    break
                }
            }
        }
    }
        
    
    enum DrawerState {
        case closed
        case beingDragged
        case animating
        case open
    }
    
//    var drawerClosedHeight: CGFloat {
////        return 150.0
//        return self.drawerInfo.drawerHandleView.frame.height
//    }
    
//    var drawerHandleHeight: CGFloat = 0.0
//
//    var drawerClosedMaxY: CGFloat = 0.0
//
//    var drawerOpenHeight: CGFloat {
////        return self.view.frame.maxY + drawerClosedHeight
//        return self.drawerInfo.drawerInView.frame.maxY + drawerHandleHeight
//    }


//    var drawerInitOriginY: CGFloat = 0.0
//    var drawerInitHeight: CGFloat = 0.0

//    var drawerOriginY: CGFloat {
//        return combindedDrawer.frame.minY
//    }
//
//    var drawerHeightYPos: CGFloat {
//        return combindedDrawer.frame.maxY
//    }

    init(with drawerInfo: SimpleDrawerInfo) {
        
        
        self.drawerInfo = drawerInfo
        
        super.init()

        self.setUp()
    }
    
    func setUp() {
        
        
        // make new view that contains the handle and the content
        
        let h = self.drawerInfo.drawerHandleView.frame.height + self.drawerInfo.drawerContentViewController.view.frame.height
        let y = self.drawerInfo.drawerHandleView.frame.maxY - h
        
        let oldHandleFrame = self.drawerInfo.drawerHandleView.frame
//        let drawerView = UIView(frame: CGRect(x: 0, y: y, width: self.drawerInfo.drawerHandleView.frame.width, height: h))
        drawerView = UIView(frame: CGRect(x: 0, y: y, width: self.drawerInfo.drawerHandleView.frame.width, height: h))

        
        
        self.drawerInfo.drawerHandleView.removeFromSuperview()
        
        drawerView.addSubview(self.drawerInfo.drawerContentViewController.view)
        drawerView.addSubview(self.drawerInfo.drawerHandleView)
        
        self.drawerInfo.drawerInView.addSubview(drawerView)
        
        

        
//        self.drawerHandleHeight = self.drawerInfo.drawerHandleView.frame.height
        self.drawerHandleStartPoint = self.drawerView.frame.minY
        self.drawerHandleEndPoint = 0
        
//        self.drawerInfo.drawerContentViewController.view.frame.origin.y = (0 - self.drawerInfo.drawerContentViewController.view.frame.height)
        
        self.drawerInfo.drawerContentViewController.view.frame.origin.y = 0
        self.drawerInfo.drawerHandleView.frame.origin.y = self.drawerInfo.drawerContentViewController.view.frame.maxY
        

        
        
//        self.drawerInfo.drawerContentViewController.view.frame = CGRect(x: 0,
//                                                                        y: self.drawerInfo.drawerHandleView.frame.minY - self.drawerInfo.drawerContentViewController.view.frame.height,//  - self.drawerInfo.drawerHandleView.frame.height,
//                                                                        width: self.drawerInfo.drawerHandleView.frame.width,
//                                                                        height:  self.drawerInfo.drawerContentViewController.view.frame.height)
        
//        self.drawerClosedMaxY = self.drawerInfo.drawerHandleView.frame.maxY

//        self.drawerInfo.drawerInView.addSubview(self.drawerInfo.drawerContentViewController.view)
//        self.drawerInfo.drawerHandleView.addSubview(self.drawerInfo.drawerContentViewController.view)

        
//        self.combindedDrawer = self.drawerInfo.drawerHandleView
//        self.combindedDrawer.frame = CGRect(x: self.drawerInfo.drawerContentViewController.view.frame.origin.x,
//                                            y: self.drawerInfo.drawerContentViewController.view.frame.origin.y,
//                                            width: self.drawerInfo.drawerContentViewController.view.frame.width,
//                                            height: self.drawerInfo.drawerHandleView.frame.height + self.drawerInfo.drawerContentViewController.view.frame.height)

        // uncomment to add pulling down drawer
        let panGesture = UIPanGestureRecognizer(target: self,
                                                action: #selector(handleDrawerDrag))
        panGesture.delegate = self
        panGesture.maximumNumberOfTouches = 1
        drawerView.addGestureRecognizer(panGesture)
        drawerDragGR = panGesture
        
        currentDrawerState = .closed
        
//        self.drawerInitOriginY = drawerClosedMaxY - (self.drawerInfo.drawerInView.frame.maxY + drawerClosedMaxY)
//        self.drawerInitOriginY = self.drawerInfo.drawerContentViewController.view.frame.origin.y

//        drawer.frame = CGRect(x: 0, y: drawerInitOriginY, width: self.drawerInfo.drawerContentViewController.view.frame.size.width, height: drawerOpenHeight)
        
        innerScrollPanGR = self.drawerInfo.embeddedScrollView?.panGestureRecognizer
        innerScrollPanGR?.maximumNumberOfTouches = 1

    }
    
    @objc func handleDrawerDrag() {

        guard let panGesture = drawerDragGR, let view = panGesture.view, let scrollView = self.drawerInfo.embeddedScrollView else { return }
        
        let touchLocationY = panGesture.location(in: self.drawerInfo.drawerInView).y
        let velocityY = panGesture.velocity(in: self.drawerInfo.drawerInView).y
        
        // drawer is open, we are NOT at the bottom, do nothing
        if currentDrawerState == .open && scrollView.atBottomStrict == false && scrollView.isBouncingBottom == false {
            prevY = touchLocationY
            return
        }

        // drawer is open, we are at the bottom and the user is trying to scroll up, do nothing
        if currentDrawerState == .open && scrollView.atBottomStrict == true && velocityY > 0 {
            prevY = touchLocationY
            return
        }
        
        
        // REDO THIS
        
        // only do this if passed the bottom
        // drawer is open, we are at the bottom, the user is trying to scroll up and the scroll view is currently bouncing
        //      animate the drawer up and restore the the height
//        if currentDrawerState == .open && scrollView.isBouncingBottom && velocityY <= 0 {
//
//
//            // animate the drawer up to the bottom of the scroll view by setting the height of the drawer its height minus offset
//            // and then restoring after if needed (the drawer could be already closed or open)
//            let offset = scrollView.contentOffset.y - (scrollView.contentSize.height - scrollView.frame.size.height)
//
//            animateTransitionHeight(fromY: 0, toY: oldFrame.maxY - offset, for: view, animationCompletion: {
//                scrollView.bounces = false
//
//                // TODO investigate
////                if self.combindedDrawer.frame.height != self.drawerOpenHeight {
////                    self.combindedDrawer.frame = CGRect(x: self.combindedDrawer.frame.origin.x, y: self.combindedDrawer.frame.origin.y - offset, width: self.combindedDrawer.frame.size.width, height: self.drawerOpenHeight)
////
////                    // update the oldFrame so the that the current pan gesture stays correct
////                    // TODO: investigate if needed
//////                    oldFrame = self.combindedDrawer.frame
////                    oldFrame = self.drawerInfo.drawerHandleView.frame
////
////                }
//            })
//        }
        
        // only do this if passed the bottom
        // drawer is open, we are at the bottom, the user is trying to scroll up and the scroll view is currently bouncing
        //      animate the drawer up and restore the the height
        if currentDrawerState == .open && scrollView.isBouncingBottom && velocityY <= 0 {
            
            
            // animate the drawer up to the bottom of the scroll view by setting the height of the drawer its height minus offset
            // and then restoring after if needed (the drawer could be already closed or open)
            let offset = scrollView.contentOffset.y - (scrollView.contentSize.height - scrollView.frame.size.height)
            let prevHeight = view.frame.height
            
            animateTransitionHeight(fromHeight: 0, toHeight: view.frame.maxY - offset, for: view, animateAlongside: {
                view.frame = CGRect(x: view.frame.origin.x, y: view.frame.origin.y - offset, width: view.frame.size.width, height: prevHeight)
            })
        }
        
        if currentDrawerState == .animating {
            print("drawer is mid animation")
            // ???: maybe cancel animation?
            
//            return
        }
        
        let nextY = drawerView.frame.minY + (touchLocationY - prevY)
        
        // if new y is less drawerClosedHeight and the user is scrolling up (trying to close the drawer), do nothing
        if nextY < self.drawerHandleStartPoint && velocityY <= 0{
//            if drawerHeightYPos + (touchLocationY - prevY) < drawerClosedMaxY && velocityY <= 0{
            print("new y is smaller than initial height")

            prevY = touchLocationY
            currentDrawerState = .closed
            return
        }
        
        // if new y is greater than the drawerOpenHeight and the user is scrolling down (trying to open the drawer), do nothing
        if nextY > self.drawerHandleEndPoint && velocityY > 0 {
//        if drawerHeightYPos + (touchLocationY - prevY) > drawerOpenHeight && velocityY > 0 {
            print("new y is greater than screen height")
            
            prevY = touchLocationY
            currentDrawerState = .open
            
            // TODO: investigate why this function gets called so quickly. Maybe I should compare offset or velocity or something
            openDrawer()
//            view.frame = CGRect(x: view.frame.origin.x, y: 0, width: view.frame.size.width, height: drawerOpenHeight)
//            view.frame.origin.y = self.drawerHandleEndPoint
            return
        }
        
        currentDrawerState = .beingDragged
        
        switch panGesture.state {
        case .began:
            print("began")
            
            prevY = touchLocationY
            
            // TOOD: investigate if this is needed or not. I currently have it commented out because we need a prevY
//            fallthrough

        case .changed:
            print("changed")

//            view.frame = CGRect(x: oldFrame.origin.x, y: oldFrame.origin.y + (touchLocationY - prevY), width: oldFrame.size.width, height: oldFrame.size.height)
            view.frame.origin.y += (touchLocationY - prevY)

            prevY = touchLocationY
            
        case .ended:
            print("ended")

            
            prevY = 0
        
//            currentDrawerState = .animating
            if panGesture.velocity(in: self.drawerInfo.drawerInView).y > 150 {
                openDrawer()
            } else {
               closeDrawer()
            }
            
        case .cancelled:
            print("cancelled")
            
            // animate to the initial position
            closeDrawer()
            
        default:
            
            print("default")
            closeDrawer()

            break
        }
    }
    
    
    // MARK: - UIGestureRecognizer
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        
        // only shouldRecognizeSimultaneously if it is this pan gesture and the scrollView
        if gestureRecognizer == drawerDragGR && otherGestureRecognizer == innerScrollPanGR {
            return true
        }
        
        return false
    }
    
    
    // MARK: - Animations
    func closeDrawer() {
        // animate to the initial position
        animateTransitionOriginAndHeight(fromY: 0, toYOrigin: self.drawerHandleStartPoint, toYHeight: 0.0, for: drawerView)
        self.currentDrawerState = .closed
    }
    
    func openDrawer() {
        // animate to the ending position
        animateTransitionOriginAndHeight(fromY: 0, toYOrigin: self.drawerHandleEndPoint, toYHeight: 0.0, for: drawerView)
        self.currentDrawerState = .open
    }

//    func animateTransitionOriginY(fromY: CGFloat, toY: CGFloat, for view: UIView, animateAlongside: (() -> Void)? = nil, animationCompletion: (() -> Void)? = nil) {
//
//        let animator = makeAnimator(fromY: fromY, toY: toY, for: view)
//
//        animator.addAnimations {
//            view.frame = CGRect(x: view.frame.origin.x, y: toY, width: view.frame.size.width, height: view.frame.size.height)
//            animateAlongside?()
//        }
//
//        animator.addCompletion { endingPosition in
//            animationCompletion?()
//        }
//
//        animator.startAnimation()
//    }
    
    func animateTransitionHeight(fromHeight: CGFloat, toHeight: CGFloat, for view: UIView, animateAlongside: (() -> Void)? = nil, animationCompletion: (() -> Void)? = nil) {
        
        let animator = makeAnimator(fromY: fromHeight, toY: toHeight, for: view)
        
        animator.addAnimations {
            view.frame.size.height = toHeight
            animateAlongside?()
        }
        
        animator.addCompletion { endingPosition in
            animationCompletion?()
        }
        
        animator.startAnimation()
    }
    
    func animateTransitionOriginAndHeight(fromY: CGFloat, toYOrigin: CGFloat, toYHeight: CGFloat, for view: UIView, animateAlongside: (() -> Void)? = nil, animationCompletion: (() -> Void)? = nil) {
        
        let animator = makeAnimator(fromY: fromY, toY: toYOrigin, for: view)
        
        animator.addAnimations {
            
//            view.frame.offsetBy(dx: 0.0, dy: fromY - toYOrigin)
//            view.frame = CGRect(x: view.frame.origin.x, y: toYOrigin, width: view.frame.size.width, height: toYHeight)
            
            // TODO: it's animating the handle, needs to animate the handle and the content... how to make as one?????
            // opening: when opening set the origin to be the position where the handle is completely off screen
            //  content goes to 0.0, handle goes to screen.maxY
            // closing:
            //  handle goes back to original origin
            //  content goes back to: handle.minY - content.height
            //

            view.frame.origin.y = toYOrigin;
            animateAlongside?()
        }
        
        animator.addCompletion { endingPosition in
            animationCompletion?()
        }
        
        animator.startAnimation()
    }
    
    private func makeAnimator(fromY: CGFloat, toY: CGFloat, for view: UIView) -> UIViewPropertyAnimator {
        
        // TODO: does setting the duration do anything?
        
        // have the duration be proportional to the distance traveled
        // borrowed from DrawerKit's AnimationSupport
//        let fractionToGo = abs(toY - fromY) / view.frame.height
        let duration = 0.4 // * TimeInterval(fractionToGo)
        
        // TODO: maybe make the duration be a fraction of the velocity 
        return UIViewPropertyAnimator(duration: duration,
                                      timingParameters: UISpringTimingParameters())
    }
}

