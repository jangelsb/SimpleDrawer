//
//  SimpleViewController.swift
//  PanGestureTest
//
//  Created by Josh Angelsberg on 4/28/19.
//  Copyright © 2019 Josh Angelsberg. All rights reserved.
//

import UIKit
import SimpleDrawer

class SimpleViewController: UIViewController {
    
    @IBOutlet var drawerHandle: UIView!
    
    var drawer: SimpleDrawer!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let drawerContent = storyboard.instantiateViewController(withIdentifier: "EmbeddedNavigationViewControllerId") as! UINavigationController
        
        let drawerInfo = SimpleDrawerInfo(drawerInView: self.view,
                                          drawerContentViewController: drawerContent,
                                          drawerHandleView: drawerHandle,
                                          embeddedScrollView: (drawerContent.children.first as! EmbeddedTableViewController).tableView,
                                          closedAutoScrollType: .bottom,
                                          openedAutoScrollType: .none)
        
        drawer = SimpleDrawer(with: drawerInfo)
    }
    
}
