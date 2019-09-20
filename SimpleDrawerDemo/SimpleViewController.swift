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
    
    @IBOutlet var drawerHandleView: UIView!
    
    var drawer: SimpleDrawer!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let drawerContentVC = storyboard.instantiateViewController(withIdentifier: "EmbeddedNavigationViewControllerId") as! UINavigationController
        
        // TODO: investigate ViewController Containment more thoroughly
        // Need to actually do this for the "Drawer" VC
//        self.addChild(drawerContentVC)
//        drawerContentVC.view.frame = self.view.frame.offsetBy(dx: 0, dy: 0)
//        view.addSubview(drawerContentVC.view)
//        drawerContentVC.didMove(toParent: self)

        
        let drawerInfo = SimpleDrawerInfo(drawerInVC: self,
                                          drawerContentVC: drawerContentVC,
                                          drawerHandleView: drawerHandleView,
                                          embeddedScrollView: (drawerContentVC.children.first as! EmbeddedTableViewController).tableView,
                                          closedAutoScrollType: .bottom,
                                          openedAutoScrollType: .none)

        drawer = SimpleDrawer(with: drawerInfo)
    }
    
}
