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
        animateTransition(fromY: 0, toY: drawerInitOriginY, for: drawer)
        self.currentDrawerState = .closed
    }
    
    func openDrawer() {
        // animate to the ending position
        animateTransition(fromY: 0, toY: 0, for: drawer)
        self.currentDrawerState = .open
    }
    

    @IBOutlet var drawer: UIView!
    
    var drawerDragGR: UIPanGestureRecognizer?
    
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
                break
            case .open:
                scrollView.isScrollEnabled = true
                break
            default:
                scrollView.isScrollEnabled = false
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
    }
    
    @objc func handleDrawerDrag() {

        guard let panGesture = drawerDragGR, let view = panGesture.view else { return }
        
        let oldFrame = view.frame
        let touchLocationY = panGesture.location(in: self.view).y
        let velocityY = panGesture.velocity(in: self.view).y
        
        // drawer is open, we are NOT at the bottom, do nothing
        if currentDrawerState == .open && (stackedVC?.topVC as? HistoryTableViewController)?.atBottom == false {
            prevY = touchLocationY
            return
        }

        // drawer is open, we are at the bottom and the user is trying to scroll up, do nothing
        if currentDrawerState == .open && (stackedVC?.topVC as? HistoryTableViewController)?.atBottom == true && velocityY > 0 {
            prevY = touchLocationY
            return
        }
        
        if currentDrawerState == .animating {
            print("drawer is mid animation")
            // TODO: maybe cancel animation?
        }
        
        // if new y is less drawerClosedHeight, do nothing
        if drawerHeightYPos + (touchLocationY - prevY) < drawerClosedHeight {
            print("new y is smaller than initial height")

            prevY = touchLocationY
            
            currentDrawerState = .closed
            return
        }
        
        // if new y is greater than the drawerOpenHeight, do nothing
        if drawerHeightYPos + (touchLocationY - prevY) > drawerOpenHeight {
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
    
    
    func animateTransition(fromY: CGFloat, toY: CGFloat, for view: UIView, animateAlongside: (() -> Void)? = nil, animationCompletion: (() -> Void)? = nil) {

//        let (startingPositionY, endingPositionY) = positionsY(startingState: startingState,
//                                                              endingState: endingState)
        
        let animator = makeAnimator(fromY: fromY, toY: toY, for: view)
//
//        let presentingVC = presentingViewController
//        let presentedVC = presentedViewController
//
//        let presentedViewFrame = presentedView?.frame ?? .zero
//
//        var startingFrame = presentedViewFrame
//        startingFrame.origin.y = startingPositionY
//
//        var endingFrame = presentedViewFrame
//        endingFrame.origin.y = endingPositionY
//
//        let geometry = AnimationSupport.makeGeometry(containerBounds: containerViewBounds,
//                                                     startingFrame: startingFrame,
//                                                     endingFrame: endingFrame,
//                                                     presentingVC: presentingVC,
//                                                     presentedVC: presentedVC)
//
//        let info = AnimationSupport.makeInfo(startDrawerState: startingState,
//                                             targetDrawerState: endingState,
//                                             configuration,
//                                             geometry,
//                                             animator.duration,
//                                             endingPositionY < startingPositionY)
//
//        let endingHandleViewAlpha = handleViewAlpha(at: endingState)
//        let autoAnimatesDimming = configuration.handleViewConfiguration?.autoAnimatesDimming ?? false
//        if autoAnimatesDimming { self.handleView?.alpha = handleViewAlpha(at: startingState) }
//
//        let presentingAnimationActions = self.presentingDrawerAnimationActions
//        let presentedAnimationActions = self.presentedDrawerAnimationActions
//
//        AnimationSupport.clientPrepareViews(presentingDrawerAnimationActions: presentingAnimationActions,
//                                            presentedDrawerAnimationActions: presentedAnimationActions,
//                                            info)
//
//        targetDrawerState = endingState
        
        animator.addAnimations {
            view.frame = CGRect(x: view.frame.origin.x, y: toY, width: view.frame.size.width, height: view.frame.size.height)
            animateAlongside?()
        }
        
        animator.addCompletion { endingPosition in
//            if autoAnimatesDimming { self.handleView?.alpha = endingHandleViewAlpha }
//
//            let isStartingStateCollapsed = (startingState == .collapsed)
//            let isEndingStateCollapsed = (endingState == .collapsed)
//
//            let shouldDismiss =
//                (isStartingStateCollapsed && endingPosition == .start) ||
//                    (isEndingStateCollapsed && endingPosition == .end)
//
//            if shouldDismiss {
//                self.presentedViewController.dismiss(animated: true)
//            }
//
//            let isStartingStateCollapsedOrFullyExpanded =
//                (startingState == .collapsed || startingState == .fullyExpanded)
//
//            let isEndingStateCollapsedOrFullyExpanded =
//                (endingState == .collapsed || endingState == .fullyExpanded)
//
//            let shouldSetCornerRadiusToZero =
//                (isEndingStateCollapsedOrFullyExpanded && endingPosition == .end) ||
//                    (isStartingStateCollapsedOrFullyExpanded && endingPosition == .start)
//
//            if maxCornerRadius != 0 && shouldSetCornerRadiusToZero {
//                self.currentDrawerCornerRadius = 0
//            }
//
//            if endingPosition != .end {
//                self.targetDrawerState = GeometryEvaluator.drawerState(for: self.currentDrawerY,
//                                                                       drawerPartialHeight: self.drawerPartialY,
//                                                                       containerViewHeight: self.containerViewHeight,
//                                                                       configuration: self.configuration)
//            }
//
//            AnimationSupport.clientCleanupViews(presentingDrawerAnimationActions: presentingAnimationActions,
//                                                presentedDrawerAnimationActions: presentedAnimationActions,
//                                                endingPosition,
//                                                info)
//
//            completion?()
    
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
    
//    private func positionsY(startingState: DrawerState,
//                            endingState: DrawerState) -> (starting: CGFloat, ending: CGFloat) {
//        let drawerFullY = configuration.fullExpansionBehaviour.drawerFullY
//        let startingPositionY =
//            GeometryEvaluator.drawerPositionY(for: startingState,
//                                              drawerPartialHeight: drawerPartialHeight,
//                                              containerViewHeight: containerViewHeight,
//                                              drawerFullY: drawerFullY)
//
//        let endingPositionY =
//            GeometryEvaluator.drawerPositionY(for: endingState,
//                                              drawerPartialHeight: drawerPartialHeight,
//                                              containerViewHeight: containerViewHeight,
//                                              drawerFullY: drawerFullY)
//
//        return (startingPositionY, endingPositionY)
//    }
    
    
    
//    func isItemsAvailabe(gesture: UIPanGestureRecognizer) -> Bool {
//        if gesture.translation(in: drawer).y > 0 {
//            // check if we have some values in down if yes return true else false
//            return true
//        } else if gesture.translation(in: drawer).y < 0 {
//
//            // check if we have some values in up if yes return true else false
//        }
//        return false
//    }
//
//
//    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
//                           shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
//
//        guard let panGesture = drawerDragGR, let swipeGesture = (stackedVC?.topVC as? HistoryTableViewController)?.tableView.gestureRecognizers?[1] as? UIPanGestureRecognizer else { return false }
//
//        // Do not begin the pan until the swipe fails.
//        if gestureRecognizer == panGesture &&
//            otherGestureRecognizer == swipeGesture && isItemsAvailabe(gesture: otherGestureRecognizer as! UIPanGestureRecognizer) {
//            return true
//        }
//        return false
//    }
    
    
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        
        
        
//        let gesture = (gestureRecognizer as! UIPanGestureRecognizer)
//        let direction = gesture.velocity(in: view).y
//
//        let scrollView = ((stackedVC?.topVC as? HistoryTableViewController)?.tableView)!
//        let atBottom = scrollView.contentOffset.y >= scrollView.contentSize.height - scrollView.frame.size.height
//
//        let atBottom2 = abs((scrollView.contentSize.height - scrollView.frame.size.height) - scrollView.contentOffset.y) < 0.001
//
//        if atBottom2 && direction < 0 {
//            return true
//        } else {
//            return false
//        }
//
        
        return true
    }
}

