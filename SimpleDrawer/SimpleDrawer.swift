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
    var drawerHandleStartPoint: CGFloat = 0.0
    var drawerHandleEndPoint: CGFloat = 0.0

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

    public init(with drawerInfo: SimpleDrawerInfo, delegate: SimpleDrawerDelegate? = nil) {
        
        self.drawerInfo = drawerInfo
        self.delegate = delegate
        
        super.init()

        self.setUp()
    }
    
    func setUp() {
        
        
        _ = self.drawerInfo.drawerHandleView.frame

        let h = self.drawerInfo.drawerHandleView.frame.height + self.drawerInfo.drawerContentVC.view.frame.height
        let y = self.drawerInfo.drawerHandleView.frame.maxY - h
        
        // make new view that contains the handle and the content
        
        // TODO: needed as of right now for the calc
        self.drawerInfo.drawerHandleView.removeConstraintsForAllSubViews()

        
        // maybe?
        // https://stackoverflow.com/a/30491911
//        self.drawerInfo.drawerHandleView.remove all contraints
        
        // TODO: investigate how to keep the bottom inset of the scroll view... h
//        if let scrollView = self.drawerInfo.embeddedScrollView {
//
//             drawerScrollViewBottomDefaultOffset = scrollView.contentOffset.y - (scrollView.contentSize.height - scrollView.frame.size.height)
//        }
        
//        if let navVC = self.drawerInfo.drawerContentViewController as? UINavigationController {
//            navVC.setNavigationBarHidden(true, animated: false)
//            navVC.setNavigationBarHidden(false, animated: false)
//        }
       
        
//        let drawerView = UIView(frame: CGRect(x: 0, y: y, width: self.drawerInfo.drawerHandleView.frame.width, height: h))
        
        drawerView = UIView(frame: CGRect(x: 0, y: y, width: self.drawerInfo.drawerInVC.view.frame.width, height: h))
        
        let blurEffect = UIBlurEffect(style: .dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = CGRect(x: 0, y: 0, width: drawerView.frame.width, height: drawerView.frame.height)
        
        // TODO: investigate if this is needed...
        self.drawerInfo.drawerHandleView.removeFromSuperview()
        
//        self.drawerInfo.drawerHandleView.frame = oldHandleFrame
        
        drawerView.backgroundColor = .clear
        drawerView.addSubview(blurEffectView)
        drawerView.addSubview(self.drawerInfo.drawerContentVC.view)
        drawerView.addSubview(self.drawerInfo.drawerHandleView)
        
        self.drawerInfo.drawerInVC.view.addSubview(drawerView)
        
        // TODO: possilby... https://stackoverflow.com/a/27278985/9605061
        // need to call drawerInViewController.addChild(embeddedVC)
        // embeddedVC.didMove(to: drawerInViewController.addChild)
        
//        let controller = storyboard!.instantiateViewController(withIdentifier: "scene storyboard id")
//        addChild(controller)
//        controller.view.frame = ...  // or, better, turn off `translatesAutoresizingMaskIntoConstraints` and then define constraints for this subview
//            view.addSubview(controller.view)
//        controller.didMove(toParent: self)
        
        
        self.drawerHandleStartPoint = self.drawerView.frame.minY
        self.drawerHandleEndPoint = 0 // TODO: customize in DrawerInfo: negative number here needs to be subtracted from the emedded vc hieght
        
        self.drawerInfo.drawerContentVC.view.frame.origin.y = 0
        self.drawerInfo.drawerHandleView.frame.origin.y = self.drawerInfo.drawerContentVC.view.frame.maxY

        // uncomment to add pulling down drawer
        let panGesture = UIPanGestureRecognizer(target: self,
                                                action: #selector(handleDrawerDrag))
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
    
    @objc func handleDrawerDrag() {

        guard let panGesture = drawerDragGR, let view = panGesture.view, let scrollView = self.drawerInfo.embeddedScrollView else { return }
        
        let touchLocationY = panGesture.location(in: self.drawerInfo.drawerInVC.view).y
        let velocityY = panGesture.velocity(in: self.drawerInfo.drawerInVC.view).y
        
        // TODO: also need to allow for pull up the drawer, if the user is pulling up from the handle while the drawer is open, regardless of is the scrollview is at the bottom or not

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
       if currentDrawerState == .open && scrollView.isBouncingBottom && velocityY <= 0 {
        
            let animator = UIViewPropertyAnimator(duration: TimeInterval(abs(velocityY) * 0.0002),
                                                  timingParameters: UISpringTimingParameters())
        
            animator.addAnimations {
                scrollView.scrollToBottom(animated: false)
            }
            animator.startAnimation()
        }
        
        if currentDrawerState == .animating {
            print("drawer is mid animation")
            // ???: maybe cancel animation?
            
//            return
        }
        
        let nextY = drawerView.frame.minY + (touchLocationY - prevY)
        
        // if new y is less drawerClosedHeight and the user is scrolling up (trying to close the drawer), do nothing
        if nextY < self.drawerHandleStartPoint && velocityY <= 0 {
//            if drawerHeightYPos + (touchLocationY - prevY) < drawerClosedMaxY && velocityY <= 0{
            print("new y is smaller than initial height")

            prevY = touchLocationY
//            closeDrawer()
            currentDrawerState = .closed
            return
        }
        
        // if new y is greater than the drawerOpenHeight and the user is scrolling down (trying to open the drawer), do nothing
        if nextY > self.drawerHandleEndPoint && velocityY > 0 {
//        if drawerHeightYPos + (touchLocationY - prevY) > drawerOpenHeight && velocityY > 0 {
            print("new y is greater than screen height")
            
            prevY = touchLocationY
            
            // TODO: investigate why this function gets called so quickly. Maybe I should compare offset or velocity or something
//            openDrawer()
            currentDrawerState = .open
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
            if panGesture.velocity(in: self.drawerInfo.drawerInVC.view).y > 150 {
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
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        
        // only shouldRecognizeSimultaneously if it is this pan gesture and the scrollView
        if gestureRecognizer == drawerDragGR && otherGestureRecognizer == innerScrollPanGR {
            return true
        }
        
        // if this is yes, you can do swipe to delete
        return true
    }
    
    
    // MARK: - Animations
    public func closeDrawer() {
        // animate to the initial position
        animateTransitionOriginAndHeight(fromY: 0, toYOrigin: self.drawerHandleStartPoint, toYHeight: 0.0, for: drawerView , animateAlongside: { [weak self] in
            guard let self = self else { return }
            
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
        })
        self.currentDrawerState = .closed
        self.delegate?.drawerClosed()
    }
    
    public func openDrawer() {
        self.drawerInfo.drawerContentVC.view.setNeedsLayout()

        animateTransitionOriginAndHeight(fromY: 0, toYOrigin: self.drawerHandleEndPoint, toYHeight: 0.0, for: drawerView, animateAlongside: { [weak self] in
            guard let self = self else { return }
            
            self.drawerInfo.drawerContentVC.view.layoutIfNeeded()
            if let scrollView = self.drawerInfo.embeddedScrollView {
                switch self.drawerInfo.openedAutoScrollType {
                    case .top:
                        scrollView.scrollToTop(animated: false)
                    case .bottom:
                        scrollView.scrollToBottom(animated: false)
                    default:
                        break
                    }
                }
        })
        
        self.currentDrawerState = .open
        self.delegate?.drawerOpened()
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

