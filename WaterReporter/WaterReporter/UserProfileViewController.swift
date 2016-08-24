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

class UserProfileViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var reportOwner:AnyObject!
    var reports = [AnyObject]()
    var page: Int = 1

    
    @IBOutlet weak var tableView: UITableView!

    @IBOutlet weak var userProfileImage: UIImageView!
    @IBOutlet weak var userProfileName: UILabel!
    @IBOutlet weak var userProfileOrganizationTitle: UILabel!
    @IBOutlet weak var userProfileBiography: UILabel!
    @IBOutlet weak var userProfileSubmissionsButton: UIButton!
    @IBOutlet weak var userProfileActionsButton: UIButton!
    @IBOutlet weak var userProfileGroupsButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //
        // Load Basic User Profile Information
        //
        self.setupUserProfile()
        
        //
        // Setup Table View for User's Reports
        //
        self.tableView.registerClass(UserProfileTableViewCell.self, forCellReuseIdentifier: "SingleReport")
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        //
        // Load Basic Submissions Data
        //
        self.loadSubmissions()
        
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
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("number of reports or table cells to show")
        print(self.reports.count)
        return self.reports.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("SingleReport", forIndexPath: indexPath) as! UserProfileTableViewCell
        
//        cell.userReportsTerritoryName.text = "Grr"
        
        return cell
    }

    func loadSubmissions() {
        
        print("loadSubmissions")
        
        //
        // Send a request to the defined endpoint with the given parameters
        //
        let parameters = [
            "q": "{\"filters\": [{\"name\":\"owner_id\", \"op\":\"eq\", \"val\":274}], \"order_by\": [{\"field\":\"report_date\",\"direction\":\"desc\"},{\"field\":\"id\",\"direction\":\"desc\"}]}",
            "page": self.page
        ]
        
        Alamofire.request(.GET, Endpoints.GET_MANY_REPORTS, parameters: parameters as? [String : AnyObject])
            .responseJSON { response in
                
                switch response.result {
                case .Success(let value):
                    self.reports += value["features"] as! [AnyObject]
                    self.tableView.reloadData()
                    
                    print(value["features"])
                    self.page += 1
                    
                case .Failure(let error):
                    print(error)
                    break
                }
                
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}