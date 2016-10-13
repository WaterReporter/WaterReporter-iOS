//
//  LaunchViewController.swift
//  Water-Reporter
//
//  Created by Viable Industries on 10/13/16.
//  Copyright © 2016 Viable Industries, L.L.C. All rights reserved.
//

import Foundation
import UIKit

class LaunchViewController: UIViewController {
    
    @IBAction func unwindToLaunchViewController(segue: UIStoryboardSegue) {}

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        
        print("LaunchViewController::viewWillAppear")
        
        //
        // Before doing anything else make sure that the user is logged
        // in to the WaterReporter.org platform.
        //
        if let _account = NSUserDefaults.standardUserDefaults().objectForKey("currentUserAccountAccessToken") {
            _ = _account
            print("LaunchViewController::viewWillAppear::AccountFound")
//            dismissViewControllerAnimated(true, completion: nil)
            performSegueWithIdentifier("showActivityTableViewControllerFromInitialViewController", sender: self)
        }
        else {
            print("LaunchViewController::viewWillAppear::NotFound")
            performSegueWithIdentifier("showLoginTableViewControllerFromInitialViewController", sender: self)
        }
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        print("LaunchViewController::viewDidLoad")

        //
        // Before doing anything else make sure that the user is logged
        // in to the WaterReporter.org platform.
        //
        if let _account = NSUserDefaults.standardUserDefaults().objectForKey("currentUserAccountAccessToken") {
            _ = _account
            print("LaunchViewController::viewDidLoad::AccountFound")

            let storyBoard: UIStoryboard = UIStoryboard(name:"Main", bundle: NSBundle.mainBundle())
            let tabBarController: UITabBarController = storyBoard.instantiateViewControllerWithIdentifier("PrimaryTabBarController") as! UITabBarController
            
        
//            window?.makeKeyAndVisible()
//            window?.rootViewController = tabBarController

        
//            let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
            
//            let nextViewController = storyBoard.instantiateViewControllerWithIdentifier("LoginTableViewController") as! LoginTableViewController
            
//            self.presentViewController(nextViewController, animated: false, completion: nil)

        
        
        
        }
        else {
            print("LaunchViewController::viewDidLoad::NotFound")
            performSegueWithIdentifier("showLoginTableViewControllerFromInitialViewController", sender: self)
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}