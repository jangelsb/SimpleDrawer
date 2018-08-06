//
//  StackedViewController.swift
//  PanGestureTest
//
//  Created by Josh Angelsberg on 7/21/18.
//  Copyright © 2018 Josh Angelsberg. All rights reserved.
//

import UIKit

class StackedViewController: UIViewController {
    

    var topVC: UIViewController?
    var bottomVC: UIViewController?
    @IBOutlet var scrollView: UIScrollView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        topVC = self.childViewControllers.last
        bottomVC = self.childViewControllers.first
        
        if let hVC = topVC as? HistoryTableViewController {
            hVC.scrollToLastRow(animated: false)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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

