//
//  EmbeddedViewController.swift
//  PanGestureTest
//
//  Created by Josh Angelsberg on 7/18/18.
//  Copyright © 2018 Josh Angelsberg. All rights reserved.
//

import UIKit

class EmbeddedViewController: UIViewController {
    
    var topVC: UIViewController?
    var bottomVC: UIViewController?

    override func viewDidLoad() {
        super.viewDidLoad()

        topVC = self.childViewControllers.last
        bottomVC = self.childViewControllers.first
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setAlpha(alpha: CGFloat) {
        topVC?.view.alpha = 1 - alpha
        bottomVC?.view.alpha = alpha
        
        
        // check if this is a way to do this for generic VCs
        if let histVC = bottomVC?.childViewControllers.first as? HistoryTableViewController {
            histVC.scrollToLastRow(animated: false)
        }
        
        if topVC?.view.alpha == 1.0 && bottomVC?.view.alpha == 0.0 {
            topVC?.view.isHidden = false
            bottomVC?.view.isHidden = true
        }
        else if bottomVC?.view.alpha == 1.0 && topVC?.view.alpha == 0.0 {
            bottomVC?.view.isHidden = false
            topVC?.view.isHidden = true
        } else {
            bottomVC?.view.isHidden = false
            topVC?.view.isHidden = false
        }
    }
    
    func nothing() {
        print(bottomVC)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
