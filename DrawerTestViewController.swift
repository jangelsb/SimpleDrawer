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
        
        if touchLocationY < 150 {
            
            // initial position
            animateTransition(fromY: 0, toY: 150, for: view, animateAlongside: {
                if let embeddedVC = self.embeddedVC {
                    embeddedVC.setAlpha(alpha: 0)
                }
            })
            
            return
        }

        
        switch panGesture.state {
        case .began:
//            startingDrawerStateForDrag = targetDrawerState
            print("began")
            
            
            animateTransition(fromY: 0, toY: touchLocationY, for: view)
            fallthrough
            
        case .changed:
            print("changed")
//            applyTranslationY(panGesture.translation(in: view).y)
//            panGesture.setTranslation(.zero, in: view)
            
            
            if let embeddedVC = self.embeddedVC {
                embeddedVC.setAlpha(alpha: 1 - (150 / oldFrame.size.height))
                
                print(1 - (150 / oldFrame.size.height))
            }
            
            view.frame = CGRect(x: oldFrame.origin.x, y: oldFrame.origin.y, width: oldFrame.size.width, height: touchLocationY)
            
            
            
//            let drawerSpeedY = panGesture.velocity(in: view).y / self.view.frame.height
//            print(drawerSpeedY)
            
        case .ended:
            print("ended")

            
            
//            let drawerSpeedY = panGesture.velocity(in: view).y / containerViewHeight
//            let endingState = GeometryEvaluator.nextStateFrom(currentState: currentDrawerState,
//                                                              speedY: drawerSpeedY,
//                                                              drawerPartialHeight: drawerPartialHeight,
//                                                              containerViewHeight: containerViewHeight,
//                                                              configuration: configuration)
//            animateTransition(to: endingState)
            
            if panGesture.velocity(in: self.view).y > 200 {
                animateTransition(fromY: 0, toY: self.view.frame.size.height, for: view, animateAlongside: {
                    if let embeddedVC = self.embeddedVC {
                        embeddedVC.setAlpha(alpha: 1)
                    }
                })
                
            } else {
                
                // initial position

                animateTransition(fromY: 0, toY: 150, for: view, animateAlongside: {
                    if let embeddedVC = self.embeddedVC {
                        embeddedVC.setAlpha(alpha: 0)
                    }
                })
                
                
               
            }
            
        case .cancelled:
//            if let startingState = startingDrawerStateForDrag {
//                startingDrawerStateForDrag = nil
//                animateTransition(to: startingState)
//            }
            
            // initial position
            animateTransition(fromY: 0, toY: 150, for: view, animateAlongside: {
                if let embeddedVC = self.embeddedVC {
                    embeddedVC.setAlpha(alpha: 0)
                }
            })


            
            print("cancelled")
            
        default:
            
            print("default")

            break
        }
    }
    
    
    func animateTransition(fromY: CGFloat, toY: CGFloat, for view: UIView, animateAlongside: (() -> Void)? = nil) {

//        let (startingPositionY, endingPositionY) = positionsY(startingState: startingState,
//                                                              endingState: endingState)
        
        let animator = makeAnimator()
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
        }
        
        animator.startAnimation()
    }
    
    private func makeAnimator() -> UIViewPropertyAnimator {
        let duration = 0.4
        
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

