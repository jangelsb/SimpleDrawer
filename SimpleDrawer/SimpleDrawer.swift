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
        
        
    var drawerCloseConstraint: NSLayoutConstraint!
    var drawerOpenConstraint: NSLayoutConstraint!
    
    var animator: UIViewPropertyAnimator!


    private(set) public var currentDrawerState: DrawerState = .closed {
        didSet{
            print("Drawer is now \(currentDrawerState)")
            
            if currentDrawerState == oldValue {
                return
            }
            
            if oldValue == .open || oldValue == .closed {
                previousEndState = oldValue
            }
            
            if let scrollView = self.drawerInfo.embeddedScrollView {
                
                switch currentDrawerState {
                case .closed:
                    scrollView.isScrollEnabled = false
                    scrollView.bounces = false
                    
                    delegate?.drawerClosed()
                    break
                case .open:
                    scrollView.isScrollEnabled = true
                    scrollView.bounces = true
                    
                    delegate?.drawerOpened()
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
    
    private(set) public var previousEndState: DrawerState = .closed
    
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
                
        let velocity = sender.velocity(in: self.drawerInfo.drawerInVC.view)
        let translation = sender.translation(in: self.drawerInfo.drawerInVC.view)
        
        let translation_drawerView = sender.translation(in: self.drawerView)
        let translation_scrollView = sender.translation(in: scrollView)

        let velocityY = sender.velocity(in: self.drawerInfo.drawerInVC.view).y
        let velocityX = sender.velocity(in: self.drawerInfo.drawerInVC.view).x
        
        // TODO: this is a good idea, but if we are begining a gesture, we are gonna call pause...
        if (self.animator.isRunning && sender.state != .began)
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
        
        
        // TODO: investigate jumping... maybe store last translation or something
        if currentDrawerState == .open && scrollView.isBouncing {
            
            print("scrollview is bouncing... ignoring...")

            return
        }
        
//        if currentDrawerState == .closed && velocityY < 0 {
//            print("drawer is closed, and the user is trying to scroll up, do nothing")
//
//            return
//        }
        
        //        print("touchLocation: \(touchLocation)")
        //        print("velocity: \(velocity)")
        print("translation: \(translation)")
        print("translation_drawerView: \(translation_drawerView)")
        print("translation_scrollView: \(translation_scrollView)")

        switch sender.state {
        case .began:
            print("!!!!! began")
            animator.pauseAnimation()

            fallthrough
        case .changed:
            currentDrawerState = .beingDragged
            
            if self.previousEndState == .open {
                print("is reverse")
                animator.isReversed = true
            } else {
                animator.isReversed = false
            }
            
            
            // not frame height... I think it's the distance needed to travel between end and start positions. Not sure how to calculate that
            let fraction = translation.y / self.drawerInfo.drawerInVC.view.frame.height
            let adjustedFraction = self.previousEndState == .open ? fraction * -1 : fraction
            
            print("!!!!! changed: \(adjustedFraction)")
            animator.fractionComplete = adjustedFraction
            
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
            
            fallthrough
        case .cancelled:
            print("cancelled")
            fallthrough
        default:
            print("default")
            
            // TODO: need to determine which way to go based on drawer state...
//            animator.isReversed = true
            animator.startAnimation()
        }
    }
    
    
    // MARK: - UIGestureRecognizer
//    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
//
//        // only shouldRecognizeSimultaneously if it is this pan gesture and the scrollView
//        if gestureRecognizer == drawerDragGR && otherGestureRecognizer == innerScrollPanGR {
//            return true
//        }
//
//
//
//        // if this is yes, you can do swipe to delete
//        return true
//    }
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if let scrollView = otherGestureRecognizer.view as? UIScrollView {
            let atBottom = scrollView.atBottomStrict
            print("atbottom: \(atBottom)")

            // TODO: could do something fancy given that the otherGesture is the inner scrollview.
            // E.g., scrollView must be at the bottom, or is not bouncing or something. But so far always returning true and ignoring in the handlePan func seems better...
            return true
        }
        return true
    }
    
    // MARK: - Animations
    
    
    func openDrawerConstraints() {
        NSLayoutConstraint.deactivate([
            self.drawerCloseConstraint
        ])
        
        NSLayoutConstraint.activate([
            self.drawerOpenConstraint
        ])

        self.drawerInfo.drawerContentVC.setNeedsStatusBarAppearanceUpdate()
        self.drawerInfo.drawerContentVC.view.setNeedsLayout()
        self.drawerView.superview?.layoutIfNeeded()
    }
    
    public func closeDrawerConstraints() {
        NSLayoutConstraint.deactivate([
            self.drawerOpenConstraint
        ])
        
        NSLayoutConstraint.activate([
            self.drawerCloseConstraint
        ])

        self.drawerInfo.drawerContentVC.view.setNeedsLayout()
        self.drawerView.superview?.layoutIfNeeded()
    }
    
    public func openDrawer() {
        animator.isReversed = false
        self.currentDrawerState = .open
        animator.startAnimation()
        
        // does doing this after the animation make a difference?
        if let scrollView = self.drawerInfo.embeddedScrollView {
            switch self.drawerInfo.closedAutoScrollType {
            case .top:
                scrollView.scrollToTop(animated: false)
            case .bottom:
                scrollView.scrollToBottom(animated: false)
            default:
                break
            }
        }
    }
    
    public func closeDrawer() {
        animator.isReversed = true
        self.currentDrawerState = .closed
        animator.startAnimation()
        
        
        if let scrollView = self.drawerInfo.embeddedScrollView {
            
            switch self.drawerInfo.closedAutoScrollType {
            case .top:
                scrollView.scrollToTop(animated: false)
            case .bottom:
                scrollView.scrollToBottom(animated: false)
            default:
                break
            }
        }
        
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

    func makePropertyAnimator() {
        animator = UIViewPropertyAnimator(duration: 0.3, curve: .easeInOut) {
                print("MADE ANIMATOR: to open")
                self.openDrawerConstraints()
        }
        
        animator.pausesOnCompletion = true
                
        // So terrible!! 😤 https://stackoverflow.com/a/49997475/9605061
        // Should switch to block based and do Swift ugh
        animator.addObserver(self, forKeyPath: "running", options: [.new, .old], context: nil)
    }
    
    public override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
    
        if let newValue = change?[.newKey] as? Bool, newValue {
            print(" !!! observeValue - reloading")
//            self.drawerInfo.drawerContentVC.view.setNeedsLayout()
        }
        
        print(" !!! observeValue(running is now): \(change![.newKey] as? Bool ?? false)")

    }
    
    deinit {
        animator.removeObserver(self, forKeyPath: "running", context: nil)
     }
}
