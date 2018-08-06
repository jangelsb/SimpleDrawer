//
//  ViewController.swift
//  PanGestureTest
//
//  Created by Josh Angelsberg on 7/8/18.
//  Copyright © 2018 Josh Angelsberg. All rights reserved.
//

import UIKit

class DrawerTestViewController: UIViewController, UIGestureRecognizerDelegate, DrawerDelegate {
    
    func closeDrawer() {
        // animate to the initial position
        
        
//        if let offset = drawerOffSetEek {
            animateTransitionOriginAndHeight(fromY: 0, toYOrigin: drawerInitOriginY, toYHeight: drawerInitHeight, for: drawer)
//            self.drawerOffSetEek = nil
//        } else {
//            animateTransitionOriginY(fromY: 0, toY: drawerInitOriginY, for: drawer)
//        }
        
        self.currentDrawerState = .closed
    }
    
    func openDrawer() {
        // animate to the ending position
        
        
        animateTransitionOriginY(fromY: 0, toY: 0, for: drawer)
        self.currentDrawerState = .open
    }
    

    @IBOutlet var drawer: UIView!
    
    var drawerDragGR: UIPanGestureRecognizer?

    var innerScrollPanGR: UIPanGestureRecognizer?
    
//    var drawerOffSetEek: CGFloat?

    var stackedVC: StackedViewController?
    
    var drawerListener: DrawerListener?

    var prevY: CGFloat = 0
    
    var currentDrawerState: DrawerState = .closed {
        didSet{
            print("Drawer is now \(currentDrawerState)")
            
            if let drawerListener = self.drawerListener {
                drawerListener.drawerStateChanged(to: currentDrawerState)
            }
            
            let scrollView = ((stackedVC?.topVC as? HistoryTableViewController)?.tableView)!

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
                
                // TODO: check if mid bounc
                if scrollView.isBouncingBottom {
                    print("Bouncing!!!!")
//                    let bottom = CGPoint(x: 0, y: scrollView.contentSize.height - scrollView.bounds.size.height)
//
//                    let step = CGPoint(x: 0, y: min((scrollView.contentOffset.y - (drawerDragGR?.velocity(in: self.view).y)!), bottom.y))
//
//                    scrollView.setContentOffset(step, animated: false)
//
//
////
////                    scrollView.contentOffset.y > scrollView.contentSize.height - scrollView.bounds.height + scrollView.contentInset.bottom
//
//

//                    scrollView.bounces = false

                    
                } else {
                    scrollView.bounces = false
                }
                break
            default:
//                scrollView.isScrollEnabled = false
                
                
                break
            }
        }
    }
        
    
    enum DrawerState {
        case closed
        case beingDragged
        case animating
        case open
    }
    
    let drawerClosedHeight: CGFloat = 150.0
    
    var drawerOpenHeight: CGFloat {
        return self.view.frame.maxY + drawerClosedHeight
    }

    var drawerInitOriginY: CGFloat = 0.0
    var drawerInitHeight: CGFloat = 0.0

    var drawerOriginY: CGFloat {
        return drawer.frame.minY
    }
    
    var drawerHeightYPos: CGFloat {
        return drawer.frame.maxY
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        stackedVC = self.childViewControllers.first as? StackedViewController
        
        if let sVC = stackedVC {
            drawerListener = sVC
            
            if let historyVC = sVC.topVC as? HistoryTableViewController {
                historyVC.drawerDelegate = self
            }
        }

        let panGesture = UIPanGestureRecognizer(target: self,
                                                action: #selector(handleDrawerDrag))
        panGesture.delegate = self
        panGesture.maximumNumberOfTouches = 1
        drawer.addGestureRecognizer(panGesture)
        drawerDragGR = panGesture
        
        currentDrawerState = .closed
        
        self.drawerInitOriginY = drawerClosedHeight - (self.view.frame.maxY + drawerClosedHeight)
        

        drawer.frame = CGRect(x: self.view.frame.origin.x, y: drawerInitOriginY, width: self.view.frame.size.width, height: drawerOpenHeight)
        
        self.drawerInitHeight = drawerOpenHeight
        
        let scrollView = ((stackedVC?.topVC as? HistoryTableViewController)?.tableView)!

//        scrollView.panGestureRecognizer.addTarget(self, action: #selector(handleScrollDrag))
        
        innerScrollPanGR = scrollView.panGestureRecognizer
        
        innerScrollPanGR?.maximumNumberOfTouches = 1

    }
    
    @objc func handleDrawerDrag() {

        guard let panGesture = drawerDragGR, let view = panGesture.view, let scrollView = (stackedVC?.topVC as?HistoryTableViewController)?.tableView else { return }
        
        var oldFrame = view.frame
        let touchLocationY = panGesture.location(in: self.view).y
        let velocityY = panGesture.velocity(in: self.view).y
        
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
        
        
        // only do this if passed the bottom
        if currentDrawerState == .open && scrollView.isBouncingBottom && velocityY <= 0 {
            
            
            // animate the drawer up to the bottom of the scroll view somehow
            // animate up while simultaneously scroll the scrollView down?
            let offset = scrollView.contentOffset.y - (scrollView.contentSize.height - scrollView.frame.size.height)

            animateTransitionHeight(fromY: 0, toY: oldFrame.maxY - offset, for: view, animationCompletion: {
                scrollView.bounces = false
                
                
                if self.drawer.frame.height != self.drawerInitHeight {
                    self.drawer.frame = CGRect(x: self.drawer.frame.origin.x, y: self.drawer.frame.origin.y - offset, width: self.drawer.frame.size.width, height: self.drawerInitHeight)
                    
                    oldFrame = self.drawer.frame
                    
                }
                
            })
        }
        
        if currentDrawerState == .animating {
            print("drawer is mid animation")
            // TODO: maybe cancel animation?
            
//            return
        }
        
        // if new y is less drawerClosedHeight, do nothing
        if drawerHeightYPos + (touchLocationY - prevY) < drawerClosedHeight && velocityY <= 0{
            print("new y is smaller than initial height")

            prevY = touchLocationY
            
            currentDrawerState = .closed
            return
        }
        
        // if new y is greater than the drawerOpenHeight, do nothing
        if drawerHeightYPos + (touchLocationY - prevY) > drawerOpenHeight && velocityY > 0 {
            print("new y is greater than screen height")
            
            prevY = touchLocationY
            
            currentDrawerState = .open

            return
        }
        
        currentDrawerState = .beingDragged
        
        switch panGesture.state {
        case .began:
            print("began")
            
            prevY = touchLocationY
//            fallthrough

        case .changed:
            print("changed")

            // hmm, keeps it at the bottom but a little bumpy
//            let vc = (stackedVC?.topVC as? HistoryTableViewController)!
//            vc.tableView.contentOffset = CGPoint(x: 0.0, y: vc.tableView.contentSize.height - vc.tableView.frame.size.height)

            view.frame = CGRect(x: oldFrame.origin.x, y: oldFrame.origin.y + (touchLocationY - prevY), width: oldFrame.size.width, height: oldFrame.size.height)
            
            prevY = touchLocationY
            
        case .ended:
            print("ended")

            
            prevY = 0
        
//            currentDrawerState = .animating
            if panGesture.velocity(in: self.view).y > 150 {
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
    
   
    @objc func handleScrollDrag() {
       
        guard let panGesture = innerScrollPanGR, let view = panGesture.view else { return }

        
        switch panGesture.state {
        case .began:
            print("handleScrollDrag began")
            fallthrough
        case .changed:
            print("handleScrollDrag changed")
            
            
            
            
        case .ended:
            print("handleScrollDrag ended")
            
        case .cancelled:
            print("handleScrollDrag cancelled")
            
        default:
            
            print("handleScrollDrag default")
            
            break
        }
    }

    func animateTransitionOriginY(fromY: CGFloat, toY: CGFloat, for view: UIView, animateAlongside: (() -> Void)? = nil, animationCompletion: (() -> Void)? = nil) {

        
        let animator = makeAnimator(fromY: fromY, toY: toY, for: view)
        
        animator.addAnimations {
            view.frame = CGRect(x: view.frame.origin.x, y: toY, width: view.frame.size.width, height: view.frame.size.height)
            animateAlongside?()
        }
        
        animator.addCompletion { endingPosition in
    
            animationCompletion?()
        }
        
        animator.startAnimation()
    }
    
    func animateTransitionHeight(fromY: CGFloat, toY: CGFloat, for view: UIView, animateAlongside: (() -> Void)? = nil, animationCompletion: (() -> Void)? = nil) {
        
        
        let animator = makeAnimator(fromY: fromY, toY: toY, for: view)
        
        animator.addAnimations {
            view.frame = CGRect(x: view.frame.origin.x, y: view.frame.origin.y, width: view.frame.size.width, height: toY)
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
            view.frame = CGRect(x: view.frame.origin.x, y: toYOrigin, width: view.frame.size.width, height: toYHeight)
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
 
    
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {

        // only shouldRecognizeSimultaneously if it is this pan gesture and the scrollView
        if gestureRecognizer == drawerDragGR && otherGestureRecognizer == innerScrollPanGR {
            return true
        }

        return false
    }

    
//    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
//        if gestureRecognizer == drawerDragGR && otherGestureRecognizer == innerScrollPanGR {
//            return true
//        }
//        return false
//    }
//
//    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
//        // drawer is open, we are NOT at the bottom, do nothing
////        if currentDrawerState == .open && (stackedVC?.topVC as? HistoryTableViewController)?.atBottom == false {
//
//
//        let velocityY = drawerDragGR!.velocity(in: self.view).y
//
//        if currentDrawerState == .open && (stackedVC?.topVC as? HistoryTableViewController)?.atBottom == true && velocityY > 0 {
//            return false
//        }
//
//
//        // drawer is open, we are at the bottom and the user is trying to scroll up, do nothing
//        if currentDrawerState == .open && (stackedVC?.topVC as? HistoryTableViewController)?.atBottom == false {
//            return false
//        }
//
//        return true
//    }
}

