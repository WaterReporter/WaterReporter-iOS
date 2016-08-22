//
//  UserProfileTableViewController.swift
//  Water-Reporter
//
//  Created by Viable Industries on 8/22/16.
//  Copyright © 2016 Viable Industries, L.L.C. All rights reserved.
//

import Alamofire
import Foundation
import UIKit

class UserProfileViewController: UIViewController {
    
    var reportOwner:AnyObject!

    @IBOutlet weak var userProfileImage: UIImageView!
    @IBOutlet weak var userProfileName: UILabel!
    @IBOutlet weak var userProfileOrganizationTitle: UILabel!
    @IBOutlet weak var userProfileBiography: UILabel!
    @IBOutlet weak var userProfileSubmissionsButton: UIButton!
    @IBOutlet weak var userProfileActionsButton: UIButton!
    @IBOutlet weak var userProfileGroupsButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("UserProfile loaded and using report object")
        print(reportOwner)
        
        //
        // Load Basic User Profile Information
        //
        //
        // User Profile Name
        //
        var reportOwnerFullName: String? = ""
        
        let reportOwnerFirstName = reportOwner?.objectForKey("first_name") as! String
        let reportOwnerLastName = reportOwner?.objectForKey("last_name") as! String
        
        reportOwnerFullName = reportOwnerFirstName + " " + reportOwnerLastName
        
        self.userProfileName.text = reportOwnerFullName
    }
    
    func setupUserProfile() {
        


    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}