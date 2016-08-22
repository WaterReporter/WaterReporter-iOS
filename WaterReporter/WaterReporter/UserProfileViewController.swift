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
        self.setupUserProfile()
        
    }
    
    func setupUserProfile() {
        
        //
        // User Profile Name
        //
        var reportOwnerFullName: String? = ""
        
        let reportOwnerFirstName = reportOwner?.objectForKey("first_name") as! String
        let reportOwnerLastName = reportOwner?.objectForKey("last_name") as! String
        
        reportOwnerFullName = reportOwnerFirstName + " " + reportOwnerLastName
        
        self.userProfileName.text = reportOwnerFullName

        //
        // User Profile Title/Organization
        //
        var reportOwnerOrganizationTitle: String? = ""
        
        let _title = reportOwner?.objectForKey("title") as? String
        let _organization = reportOwner?.objectForKey("organization_name") as? String
        
        if _title != nil && _organization != nil {
            reportOwnerOrganizationTitle = _title! + " at " + _organization!
        }
        else if _title != nil && _organization == nil {
            reportOwnerOrganizationTitle = _title!
        }
        else if _title == nil && _organization != nil {
            reportOwnerOrganizationTitle = _organization!
        }
        else {
            self.userProfileOrganizationTitle.hidden = true
        }
        
        self.userProfileOrganizationTitle.text = reportOwnerOrganizationTitle
        
        //
        // User Profile Description/Bio
        //
        let reportOwnerDescription = reportOwner?.objectForKey("description") as? String
        
        if reportOwnerDescription == nil {
            self.userProfileBiography.hidden = true
        }
        
        self.userProfileBiography.text = reportOwnerDescription
        
        //
        // User Profile Description/Bio
        //
        if let thisReportOwnerImageUrl = reportOwner?.objectForKey("picture") as? String  {
            ImageLoader.sharedLoader.imageForUrl(thisReportOwnerImageUrl, completionHandler:{(image: UIImage?, url: String) in
                self.userProfileImage.image = image!
                self.userProfileImage.layer.cornerRadius = self.userProfileImage.frame.size.width / 2;
                self.userProfileImage.clipsToBounds = true;
            })
        } else {
            ImageLoader.sharedLoader.imageForUrl("https://www.waterreporter.org/images/badget--MissingUser.png", completionHandler:{(image: UIImage?, url: String) in
                self.userProfileImage.image = image!
                self.userProfileImage.layer.cornerRadius = self.userProfileImage.frame.size.width / 2;
                self.userProfileImage.clipsToBounds = true;
            })
        }

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}