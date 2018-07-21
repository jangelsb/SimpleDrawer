//
//  ViewController.swift
//  PanGestureTest
//
//  Created by Josh Angelsberg on 7/8/18.
//  Copyright © 2018 Josh Angelsberg. All rights reserved.
//

import UIKit

class DrawerTestViewController: UIViewController {

    @IBOutlet var drawer: UIView!
    
    var drawerDragGR: UIPanGestureRecognizer?
    
    var embeddedVC: EmbeddedViewController?
    
    var prevY: CGFloat = 0
    
    var currentDrawerState: DrawerState = .closed
    
    enum DrawerState {
        case closed
        case beingDragged
        case animating
        case open
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        
        
        embeddedVC = self.childViewControllers.first as? EmbeddedViewController
        
        let panGesture = UIPanGestureRecognizer(target: self,
                                                action: #selector(handleDrawerDrag))
        drawer.addGestureRecognizer(panGesture)
        drawerDragGR = panGesture
    }
    
    @objc func handleDrawerDrag() {

        guard let panGesture = drawerDragGR, let view = panGesture.view else { return }
        
        let oldFrame = view.frame
        let touchLocationY = panGesture.location(in: self.view).y
        
        if currentDrawerState == .animating {
            print("drawer is mid animation")
            
            // TODO: maybe cancel animation?
        }
        
        // if new y is less 150, do nothing
        if oldFrame.size.height + (touchLocationY - prevY) < 150 {
            print("new y is smaller than initial height")
            prevY = touchLocationY

            return
        }
        
        
        // if new y is greater than the screen height, do nothing
        if oldFrame.size.height + (touchLocationY - prevY) > self.view.frame.height {
            print("new y is greater than screen height")
            prevY = touchLocationY

            return
        }
        
        // if in expanded view and the user swipes down (+y) ignore
//        if currentDrawerState == .open && (touchLocationY - prevY) >= 0 {
//
//            print("**** drawer is open, swiping is in: \(touchLocationY - prevY)")
//
//            prevY = touchLocationY
//            return
//        } else {
//            // print("drawer is \(currentDrawerState), swiping is in: \(touchLocationY - prevY)")
//
//        }
        
        currentDrawerState = .beingDragged
        
        switch panGesture.state {
        case .began:
//            startingDrawerStateForDrag = targetDrawerState
            print("began")
            
            
//            this code is no longer needed because the animation is based on the finger movement now and not the literal position of the finger
//            animateTransition(fromY: 0, toY: touchLocationY, for: view, animateAlongside: {
//                if let embeddedVC = self.embeddedVC {
//                    embeddedVC.setAlpha(alpha: 1 - (150 / oldFrame.size.height))
//                    print(1 - (150 / oldFrame.size.height))
//                }
//            })
            
            prevY = touchLocationY
//            fallthrough

        case .changed:
            print("changed")
//            applyTranslationY(panGesture.translation(in: view).y)
//            panGesture.setTranslation(.zero, in: view)
            
            
            if let embeddedVC = self.embeddedVC {
                
                // 150 = 0%
                // maxY = 100%
                
                //  (newY - initH) / (maxY - initH)
                embeddedVC.setAlpha(alpha: (oldFrame.size.height - 150) / (self.view.frame.height - 150))
            }
            
            view.frame = CGRect(x: oldFrame.origin.x, y: oldFrame.origin.y, width: oldFrame.size.width, height: oldFrame.size.height + (touchLocationY - prevY))
            
            prevY = touchLocationY
            
        case .ended:
            print("ended")

            
            prevY = 0
//            let drawerSpeedY = panGesture.velocity(in: view).y / containerViewHeight
//            let endingState = GeometryEvaluator.nextStateFrom(currentState: currentDrawerState,
//                                                              speedY: drawerSpeedY,
//                                                              drawerPartialHeight: drawerPartialHeight,
//                                                              containerViewHeight: containerViewHeight,
//                                                              configuration: configuration)
//            animateTransition(to: endingState)
            
            currentDrawerState = .animating
            
            if panGesture.velocity(in: self.view).y > 150 {
                animateTransition(fromY: 0, toY: self.view.frame.size.height, for: view, animateAlongside: {
                    if let embeddedVC = self.embeddedVC {
                        embeddedVC.setAlpha(alpha: 1)
                    }
                }, animationCompletion: {
                    self.currentDrawerState = .open
                })
                
                
            } else {
                
                // animate to the initial position
                animateTransition(fromY: 0, toY: 150, for: view, animateAlongside: {
                    if let embeddedVC = self.embeddedVC {
                        embeddedVC.setAlpha(alpha: 0)
                    }
                }, animationCompletion: {
                    self.currentDrawerState = .closed
                })
                
                
            }
            
        case .cancelled:
//            if let startingState = startingDrawerStateForDrag {
//                startingDrawerStateForDrag = nil
//                animateTransition(to: startingState)
//            }
            
            // animate to the initial position
            self.currentDrawerState = .animating
            animateTransition(fromY: 0, toY: 150, for: view, animateAlongside: {
                if let embeddedVC = self.embeddedVC {
                    embeddedVC.setAlpha(alpha: 0)
                }
            }, animationCompletion: {
                self.currentDrawerState = .closed
            })
            

            
            print("cancelled")
            
        default:
            
            print("default")

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
            view.frame = CGRect(x: view.frame.origin.x, y: view.frame.origin.y, width: view.frame.size.width, height: toY)
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
        let fractionToGo = abs(toY - fromY) / view.frame.height
        let duration = 0.4 * TimeInterval(fractionToGo)
        
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
}

