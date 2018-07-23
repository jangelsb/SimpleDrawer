//
//  StackedViewController.swift
//  PanGestureTest
//
//  Created by Josh Angelsberg on 7/21/18.
//  Copyright © 2018 Josh Angelsberg. All rights reserved.
//

import UIKit

protocol DrawerListener {
    func drawerStateChanged(to drawerState: DrawerTestViewController.DrawerState)
}

class StackedViewController: UIViewController, DrawerListener {
    

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
    
    func drawerStateChanged(to drawerState: DrawerTestViewController.DrawerState) {
        switch drawerState {
        case .open:
//            self.scrollView.isScrollEnabled = true
            
            if let topVC = topVC as? HistoryTableViewController {
//                topVC.tableView.isScrollEnabled = true
            }
            
        default:
//            self.scrollView.isScrollEnabled = false
            
            if let topVC = topVC as? HistoryTableViewController {
//                topVC.tableView.isScrollEnabled = false
                
                // TODO: remove and use contentOffset?
//                topVC.scrollToLastRow(animated: false)

            }
        }
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

