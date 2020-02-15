//
//  ViewController.swift
//  PanGestureTest
//
//  Created by Josh Angelsberg on 7/8/18.
//  Copyright © 2018 Josh Angelsberg. All rights reserved.
//

import UIKit

public protocol SimpleDrawerDelegate {
    func drawerClosed()
    func drawerOpened()
}

public enum AutoScrollType: Int {
    case top
    case bottom
    case none
}

public struct SimpleDrawerInfo {
//    - [ ] DrawerContentVC
//    - [ ] DrawerHandleView
//    - Use it’s height
    
    
    var drawerInVC: UIViewController
    var drawerContentVC: UIViewController
    var drawerHandleView: UIView
    
    var embeddedScrollView: UIScrollView?
    var closedAutoScrollType: AutoScrollType
    var openedAutoScrollType: AutoScrollType

    public init(drawerInVC: UIViewController, drawerContentVC: UIViewController, drawerHandleView: UIView, embeddedScrollView: UIScrollView?, closedAutoScrollType: AutoScrollType = .none, openedAutoScrollType: AutoScrollType = .none) {
        self.drawerInVC = drawerInVC
        self.drawerContentVC = drawerContentVC
        self.drawerHandleView = drawerHandleView
        self.embeddedScrollView = embeddedScrollView
        self.closedAutoScrollType = closedAutoScrollType
        self.openedAutoScrollType = openedAutoScrollType
    }
}

public class SimpleDrawer: NSObject, UIGestureRecognizerDelegate {
    
    public var drawerInfo: SimpleDrawerInfo
    public var delegate: SimpleDrawerDelegate?
    
    public var drawerView: UIView!
//    var combindedDrawer: UIView!

    var drawerDragGR: UIPanGestureRecognizer?

    var innerScrollPanGR: UIPanGestureRecognizer?
    
    var isFirstOpen = true
    
    var prevY: CGFloat = 0
    
    var drawerScrollViewBottomDefaultOffset: CGFloat = 0.0

//    var drawerHandleStartPoint: CGFloat = 0.0
//    var drawerHandleEndPoint: CGFloat = 0.0
    
    var drawerCloseConstraint: NSLayoutConstraint!
    var drawerOpenConstraint: NSLayoutConstraint!
    
    var animator: UIViewPropertyAnimator!


    var shouldIgnore = false

    private(set) public var currentDrawerState: DrawerState = .closed {
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
//
//                    self.drawerInfo.drawerContentViewController.view.setNeedsLayout()
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
        
    
    public enum DrawerState {
        case closed
        case beingDragged
        case animating
        case open
    }

    public init(with drawerInfo: SimpleDrawerInfo, delegate: SimpleDrawerDelegate? = nil) {
        
        self.drawerInfo = drawerInfo
        self.delegate = delegate
        
        super.init()

        self.setUp()
    }
    
    func setUp() {
        
        let handleOriginY = self.drawerInfo.drawerHandleView.frame.minY
        
        // TODO: investigate if this is needed... YES
        // This removes it so we can do something else with it
        self.drawerInfo.drawerHandleView.removeFromSuperview()
        
        
        drawerView = UIView()
        
        // TODO: this is needed for the calc

//        let blurEffect = UIBlurEffect(style: .dark)
//        let blurEffectView = UIVisualEffectView(effect: blurEffect)
//        blurEffectView.frame = CGRect(x: 0, y: 0, width: drawerView.frame.width, height: drawerView.frame.height)
//        drawerView.backgroundColor = .clear
//        drawerView.addSubview(blurEffectView)
        
        drawerView.addSubview(self.drawerInfo.drawerContentVC.view)
        drawerView.addSubview(self.drawerInfo.drawerHandleView)
        
        self.drawerInfo.drawerInVC.view.addSubview(drawerView)

        
        self.drawerInfo.drawerContentVC.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            // width
            NSLayoutConstraint(item: self.drawerInfo.drawerContentVC.view!, attribute: .width, relatedBy: .equal, toItem: self.drawerInfo.drawerInVC.view, attribute: .width, multiplier: 1.0, constant: 0.0),
            
            // height
            NSLayoutConstraint(item: self.drawerInfo.drawerContentVC.view!, attribute: .height, relatedBy: .equal, toItem: self.drawerInfo.drawerInVC.view, attribute: .height, multiplier: 1.0, constant: 0.0),
            
            // leading

            NSLayoutConstraint(item: self.drawerInfo.drawerContentVC.view!, attribute: .leading, relatedBy: .equal, toItem: self.drawerView, attribute: .leading, multiplier: 1.0, constant: 0.0),
        ])
        
        self.drawerInfo.drawerHandleView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            
            // width
            NSLayoutConstraint(item: self.drawerInfo.drawerHandleView, attribute: .width, relatedBy: .equal, toItem: self.drawerInfo.drawerInVC.view, attribute: .width, multiplier: 1.0, constant: 0.0),
            
            // height
            NSLayoutConstraint(item: self.drawerInfo.drawerHandleView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: self.drawerInfo.drawerHandleView.frame.height),
            
            // leading
            NSLayoutConstraint(item: self.drawerInfo.drawerHandleView, attribute: .leading, relatedBy: .equal, toItem: self.drawerView, attribute: .leading, multiplier: 1.0, constant: 0.0),
            
            // top
            NSLayoutConstraint(item: self.drawerInfo.drawerHandleView, attribute: .top, relatedBy: .equal, toItem: self.drawerInfo.drawerContentVC.view, attribute: .bottom, multiplier: 1.0, constant: 0.0)

        ])
        
        self.drawerView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            
            // width
            NSLayoutConstraint(item: self.drawerView!, attribute: .width, relatedBy: .equal, toItem: self.drawerInfo.drawerInVC.view, attribute: .width, multiplier: 1.0, constant: 0.0),
            
            // height
            NSLayoutConstraint(item: self.drawerView!, attribute: .top, relatedBy: .equal, toItem: self.drawerInfo.drawerContentVC.view, attribute: .top, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: self.drawerView!, attribute: .bottom, relatedBy: .equal, toItem: self.drawerInfo.drawerHandleView, attribute: .bottom, multiplier: 1.0, constant: 0.0),
        ])
        
        
        drawerCloseConstraint = NSLayoutConstraint(item: self.drawerInfo.drawerHandleView, attribute: .top, relatedBy: .equal, toItem: self.drawerInfo.drawerInVC.view, attribute: .top, multiplier: 1.0, constant: handleOriginY)
        
        drawerOpenConstraint = NSLayoutConstraint(item: self.drawerInfo.drawerContentVC.view!, attribute: .top, relatedBy: .equal, toItem: self.drawerInfo.drawerInVC.view, attribute: .top, multiplier: 1.0, constant: 0.0)

        
        NSLayoutConstraint.activate([drawerCloseConstraint])
        
//        DispatchQueue.main.async {
//            self.closeDrawer()
//
//        }
        
        makePropertyAnimator()


        // uncomment to add pulling down drawer
        let panGesture = UIPanGestureRecognizer(target: self,
                                                action: #selector(handleDrawerDrag(sender:)))
        panGesture.delegate = self
        panGesture.maximumNumberOfTouches = 1
        drawerView.addGestureRecognizer(panGesture)
        drawerDragGR = panGesture
        
        // TODO:
//        // so it scrolls after the content of the drawer has loaded, probably should change to a delegate of some sort
//        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
//            self?.closeDrawer()
//        }
//        currentDrawerState = .closed
        
        innerScrollPanGR = self.drawerInfo.embeddedScrollView?.panGestureRecognizer
        innerScrollPanGR?.maximumNumberOfTouches = 1
    }
    
    @objc func handleDrawerDrag(sender: UIPanGestureRecognizer) {

//        guard let panGesture = drawerDragGR, let view = panGesture.view, let scrollView = self.drawerInfo.embeddedScrollView else { return }
//
//        let touchLocationY = panGesture.location(in: self.drawerInfo.drawerInVC.view).y
//        let velocityY = panGesture.velocity(in: self.drawerInfo.drawerInVC.view).y
//        let velocityX = panGesture.velocity(in: self.drawerInfo.drawerInVC.view).x
//
//
//        print("velocityX: \(velocityX)")
//        print("velocityY: \(velocityY)")
//
//        if currentDrawerState == .closed && abs(velocityX) > abs(velocityY) {
//
//            print("velocityX: \(velocityX)")
////            prevY = touchLocationY
//            shouldIgnore = true
//            return
//
//        }
//
//
//        if shouldIgnore {
//
//            if (panGesture.state == .cancelled || panGesture.state == .ended) {
//
//            } else {
//                return
//            }
//        }
//
//        // TODO: also need to allow for pull up the drawer, if the user is pulling up from the handle while the drawer is open, regardless of is the scrollview is at the bottom or not
//
//        // drawer is open, we are NOT at the bottom, do nothing
//        if currentDrawerState == .open && scrollView.atBottomStrict == false && scrollView.isBouncingBottom == false {
//            prevY = touchLocationY
//            return
//        }
//
//        // drawer is open, we are at the bottom and the user is trying to scroll up, do nothing
//        if currentDrawerState == .open && scrollView.atBottomStrict == true && velocityY > 0 {
//            prevY = touchLocationY
//            return
//        }
//
//
//        // REDO THIS
//
//        // only do this if passed the bottom
//        // drawer is open, we are at the bottom, the user is trying to scroll up and the scroll view is currently bouncing
//        //      animate the drawer up and restore the the height
//       if currentDrawerState == .open && scrollView.isBouncingBottom && velocityY <= 0 {
//
//            let animator = UIViewPropertyAnimator(duration: TimeInterval(abs(velocityY) * 0.0002),
//                                                  timingParameters: UISpringTimingParameters())
//
//            animator.addAnimations {
//                scrollView.scrollToBottom(animated: false)
//            }
//            animator.startAnimation()
//        }
//
//        if currentDrawerState == .animating {
//            print("drawer is mid animation")
//            // ???: maybe cancel animation?
//
////            return
//        }
//
//        let nextY = drawerView.frame.minY + (touchLocationY - prevY)
//
//        // if new y is less drawerClosedHeight and the user is scrolling up (trying to close the drawer), do nothing
//        if nextY < self.drawerHandleStartPoint && velocityY <= 0 {
////            if drawerHeightYPos + (touchLocationY - prevY) < drawerClosedMaxY && velocityY <= 0{
//            print("new y is smaller than initial height")
//
//            prevY = touchLocationY
////            closeDrawer()
//            currentDrawerState = .closed
//            return
//        }
//
//        // if new y is greater than the drawerOpenHeight and the user is scrolling down (trying to open the drawer), do nothing
//        if nextY > self.drawerHandleEndPoint && velocityY > 0 {
////        if drawerHeightYPos + (touchLocationY - prevY) > drawerOpenHeight && velocityY > 0 {
//            print("new y is greater than screen height")
//
//            prevY = touchLocationY
//
//            // TODO: investigate why this function gets called so quickly. Maybe I should compare offset or velocity or something
////            openDrawer()
//            currentDrawerState = .open
////            view.frame = CGRect(x: view.frame.origin.x, y: 0, width: view.frame.size.width, height: drawerOpenHeight)
////            view.frame.origin.y = self.drawerHandleEndPoint
//            return
//        }
//
//        currentDrawerState = .beingDragged
//
//        switch panGesture.state {
//        case .began:
//            print("began")
//
//            prevY = touchLocationY
//
//            // TOOD: investigate if this is needed or not. I currently have it commented out because we need a prevY
////            fallthrough
//
//        case .changed:
//            print("changed")
//
////            view.frame = CGRect(x: oldFrame.origin.x, y: oldFrame.origin.y + (touchLocationY - prevY), width: oldFrame.size.width, height: oldFrame.size.height)
//            view.frame.origin.y += (touchLocationY - prevY)
//
//            prevY = touchLocationY
//
//        case .ended:
//            print("ended")
//
//            shouldIgnore = false
//
//            prevY = 0
//
////            currentDrawerState = .animating
//            if panGesture.velocity(in: self.drawerInfo.drawerInVC.view).y > 150 {
//                openDrawer()
//            } else {
//               closeDrawer()
//            }
//
//        case .cancelled:
//            print("cancelled")
//
//            // animate to the initial position
//            closeDrawer()
//            shouldIgnore = false
//
//
//        default:
//
//            print("default")
//            closeDrawer()
//
//            break
//        }
        
        
        guard let scrollView = self.drawerInfo.embeddedScrollView else { return }
        
        
        let touchLocation = sender.location(in: self.drawerInfo.drawerInVC.view)
        let velocity = sender.velocity(in: self.drawerInfo.drawerInVC.view)
        let translation = sender.translation(in: self.drawerInfo.drawerInVC.view)
        
        let velocityY = sender.velocity(in: self.drawerInfo.drawerInVC.view).y
        let velocityX = sender.velocity(in: self.drawerInfo.drawerInVC.view).x
        
        // is this needed?
        if (self.animator.isRunning)
        {
            print("animatino is running.... return ")
            return
        }

        
        
        print("velocityX: \(velocityX)")
        print("velocityY: \(velocityY)")
        
        // TODO: fix this is for moving cursor kinda
//        if currentDrawerState == .closed && abs(velocityX) > abs(velocityY) {
//
//            print("this is for moving cursor kinda")
//            //            prevY = touchLocationY
//            shouldIgnore = true
//            return
//
//        }
        
        // TODO: also need to allow for pull up the drawer, if the user is pulling up from the handle while the drawer is open, regardless of is the scrollview is at the bottom or not
        
        // drawer is open, we are NOT at the bottom, do nothing
        if currentDrawerState == .open && scrollView.atBottomStrict == false && scrollView.isBouncingBottom == false {
            print("drawer is open, we are NOT at the bottom, do nothing")
            return
        }

        // drawer is open, we are at the bottom and the user is trying to scroll up, do nothing
        if currentDrawerState == .open && scrollView.atBottomStrict == true && velocityY > 0 {
            print("drawer is open, we are at the bottom and the user is trying to scroll up, do nothing")

            return
        }
        
        //        print("touchLocation: \(touchLocation)")
        //        print("velocity: \(velocity)")
        print("translation: \(translation)")
        
        //        if velocityY < 0 {
        //
        //            print("not swiping down")
        //
        //            return
        //        }
        //
        
//        scrollView.bounces = false
//        scrollView.isScrollEnabled = false

        
        switch sender.state {
        case .began:
            print("!!!!! began")

            fallthrough
        case .changed:
            
            if self.currentDrawerState == .open {
                print("is reverse")
                animator.isReversed = true
            } else {
                animator.isReversed = false
            }
            
            
            // use abs to allow pull up...????
            let fraction = abs(translation.y / self.drawerInfo.drawerInVC.view.frame.height)
            print("!!!!! changed: \(fraction)")
            animator.fractionComplete = fraction
            
        case .ended:
            print("ended")

            if velocity.y < 0 {
                print("is reverse")
                animator.isReversed = true

                self.currentDrawerState = .closed


            } else {
                animator.isReversed = false

                self.currentDrawerState = .open

            }
            
            animator.startAnimation()
            
        case .cancelled:
            print("cancelled")
            
            // TODO: need to determine which way to go based on drawer state...
//            animator.isReversed = true
            animator.startAnimation()
        default:
            print("default")
            
            // TODO: need to determine which way to go based on drawer state...
//            animator.isReversed = true
            animator.startAnimation()
        }
    }
    
    
    // MARK: - UIGestureRecognizer
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        
        // only shouldRecognizeSimultaneously if it is this pan gesture and the scrollView
        if gestureRecognizer == drawerDragGR && otherGestureRecognizer == innerScrollPanGR {
            return true
        }
        
        // if this is yes, you can do swipe to delete
        return true
    }
    
    
    // MARK: - Animations
    
    
    func openDrawer() {
        
        
        NSLayoutConstraint.deactivate([
            self.drawerCloseConstraint
        ])
        
        NSLayoutConstraint.activate([
            self.drawerOpenConstraint
        ])

        
        self.drawerView.superview?.layoutIfNeeded()
    }
    
    func closeDrawer() {
        NSLayoutConstraint.deactivate([
            self.drawerOpenConstraint
        ])
        
        NSLayoutConstraint.activate([
            self.drawerCloseConstraint
        ])


        self.drawerView.superview?.layoutIfNeeded()
    }
    
//    public func closeDrawer() {
//        // animate to the initial position
//        animateTransitionOriginAndHeight(fromY: 0, toYOrigin: self.drawerHandleStartPoint, toYHeight: 0.0, for: drawerView , animateAlongside: { [weak self] in
//            guard let self = self else { return }
//
//            if let scrollView = self.drawerInfo.embeddedScrollView {
//
//                switch self.drawerInfo.closedAutoScrollType {
//                case .top:
//                    scrollView.scrollToTop(animated: false)
//                case .bottom:
//                    scrollView.scrollToBottom(animated: false)
//                default:
//                    break
//                }
//            }
//        })
//        self.currentDrawerState = .closed
//        self.delegate?.drawerClosed()
//    }
    
//    public func openDrawer() {
//        self.drawerInfo.drawerContentVC.view.setNeedsLayout()
//
//        animateTransitionOriginAndHeight(fromY: 0, toYOrigin: self.drawerHandleEndPoint, toYHeight: 0.0, for: drawerView, animateAlongside: { [weak self] in
//            guard let self = self else { return }
//
//            self.drawerInfo.drawerContentVC.view.layoutIfNeeded()
//            if let scrollView = self.drawerInfo.embeddedScrollView {
//                switch self.drawerInfo.openedAutoScrollType {
//                    case .top:
//                        scrollView.scrollToTop(animated: false)
//                    case .bottom:
//                        scrollView.scrollToBottom(animated: false)
//                    default:
//                        break
//                    }
//                }
//            }, animationCompletion: {
////                self.drawerInfo.drawerContentVC.view.layoutIfNeeded()
//        })
//
//        self.currentDrawerState = .open
//        self.delegate?.drawerOpened()
//    }

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

    func makePropertyAnimator() {
        animator = UIViewPropertyAnimator(duration: 0.3, curve: .easeInOut) {
            
//            if self.currentDrawerState == .open {
//                print("MADE ANIMATOR: to close")
//                self.closeDrawer()
//            } else if self.currentDrawerState == .closed {
                print("MADE ANIMATOR: to open")
                
                self.openDrawer()
//            }
            
        }
        
        animator.pausesOnCompletion = true
        
//        animator.addCompletion { (position) in
//
//            if position == .end /* and something else */ {
//                print("action: Secondary")
//                print("😎 DO THE THING 👍")
//
//
//
//
//                if self.currentDrawerState == .open && self.animator.isReversed == false {
//                    if let scrollView = self.drawerInfo.embeddedScrollView {
//
//                        switch self.drawerInfo.closedAutoScrollType {
//                        case .top:
//                            scrollView.scrollToTop(animated: false)
//                        case .bottom:
//                            scrollView.scrollToBottom(animated: false)
//                        default:
//                            break
//                        }
//                    }
//
//                    self.currentDrawerState = .closed
//                    self.delegate?.drawerClosed()
//            } else if self.currentDrawerState == .closed && self.animator.isReversed == false {
//
//                    self.drawerInfo.drawerContentVC.view.layoutIfNeeded()
//                    if let scrollView = self.drawerInfo.embeddedScrollView {
//                        switch self.drawerInfo.openedAutoScrollType {
//                        case .top:
//                            scrollView.scrollToTop(animated: false)
//                        case .bottom:
//                            scrollView.scrollToBottom(animated: false)
//                        default:
//                            break
//                        }
//                    }
//
//
//                    self.currentDrawerState = .open
//                    self.delegate?.drawerOpened()
//            }
//
//                //                    self.delegate?.secondaryActionTriggered(for: self.secondaryText)
//            } else {
//                print("🛑Shit was cancled")
//
//            }
            
            
            
//            self.drawerView.superview?.layoutIfNeeded()
//        }
    }
}
