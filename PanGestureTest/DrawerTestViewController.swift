//
//  ViewController.swift
//  PanGestureTest
//
//  Created by Josh Angelsberg on 7/8/18.
//  Copyright © 2018 Josh Angelsberg. All rights reserved.
//

import UIKit

class DrawerTestViewController: UIViewController, UIGestureRecognizerDelegate {
    
    func closeDrawer() {
        // animate to the initial position
        animateTransitionOriginAndHeight(fromY: 0, toYOrigin: drawerInitOriginY, toYHeight: drawerInitHeight, for: drawer)
        self.currentDrawerState = .closed
    }
    
    func openDrawer() {
        // animate to the ending position
        animateTransitionOriginAndHeight(fromY: 0, toYOrigin: 0, toYHeight: drawerInitHeight, for: drawer)
        self.currentDrawerState = .open
    }

    @IBOutlet var drawer: UIView!
    
    var drawerDragGR: UIPanGestureRecognizer?

    var innerScrollPanGR: UIPanGestureRecognizer?
    
    var stackedVC: StackedViewController?
    
    var prevY: CGFloat = 0
    
    var currentDrawerState: DrawerState = .closed {
        didSet{
            print("Drawer is now \(currentDrawerState)")
            
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
                scrollView.bounces = false
                break

            default:
                // don't change anything
                
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
        // drawer is open, we are at the bottom, the user is trying to scroll up and the scroll view is currently bouncing
        //      animate the drawer up and restore the the height
        if currentDrawerState == .open && scrollView.isBouncingBottom && velocityY <= 0 {
            
            
            // animate the drawer up to the bottom of the scroll view by setting the height of the drawer its height minus offset
            // and then restoring after if needed (the drawer could be already closed or open)
            let offset = scrollView.contentOffset.y - (scrollView.contentSize.height - scrollView.frame.size.height)

            animateTransitionHeight(fromY: 0, toY: oldFrame.maxY - offset, for: view, animationCompletion: {
                scrollView.bounces = false
                
                if self.drawer.frame.height != self.drawerInitHeight {
                    self.drawer.frame = CGRect(x: self.drawer.frame.origin.x, y: self.drawer.frame.origin.y - offset, width: self.drawer.frame.size.width, height: self.drawerInitHeight)
                    
                    // update the oldFrame so the that the current pan gesture stays correct
                    // TODO: investigate if needed
                    oldFrame = self.drawer.frame
                }
            })
        }
        
        if currentDrawerState == .animating {
            print("drawer is mid animation")
            // ???: maybe cancel animation?
            
//            return
        }
        
        // if new y is less drawerClosedHeight and the user is scrolling up (trying to close the drawer), do nothing
        if drawerHeightYPos + (touchLocationY - prevY) < drawerClosedHeight && velocityY <= 0{
            print("new y is smaller than initial height")

            prevY = touchLocationY
            currentDrawerState = .closed
            return
        }
        
        // if new y is greater than the drawerOpenHeight and the user is scrolling down (trying to open the drawer), do nothing
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
            
            // TOOD: investigate if this is needed or not. I currently have it commented out because we need a prevY
//            fallthrough

        case .changed:
            print("changed")

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
}

