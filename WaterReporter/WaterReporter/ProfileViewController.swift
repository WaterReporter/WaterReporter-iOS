//
//  ProfileViewController.swift
//  WaterReporter
//
//  Created by Viable Industries on 7/24/16.
//  Copyright © 2016 Viable Industries, L.L.C. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NSLog("ProfileViewController::viewDidLoad")

        //
        // Set the Navigation Bar title
        //
        self.navigationItem.title = "Profile"

        let logoutButton = UIBarButtonItem(title: "Logout", style: UIBarButtonItemStyle.Plain, target: self, action:#selector(attemptLogout))
        navigationItem.rightBarButtonItem = logoutButton
        
    }
    
    func attemptLogout() {
        //
        // Remove the access token from storage
        
        //
        NSUserDefaults.standardUserDefaults().removeObjectForKey("currentUserAccountAccessToken")
        
        //
        // Load the activity controller from the storyboard
        //
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let nextViewController = storyBoard.instantiateViewControllerWithIdentifier("LoginTableViewController") as! LoginTableViewController
        self.presentViewController(nextViewController, animated: false, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}

