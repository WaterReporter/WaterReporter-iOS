//
//  ProfileTableViewController.swift
//  Profle Test 001
//
//  Created by Viable Industries on 11/6/16.
//  Copyright © 2016 Viable Industries, L.L.C. All rights reserved.
//

import Alamofire
import Foundation
import SwiftyJSON
import UIKit

class ProfileTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UINavigationControllerDelegate {
    
    
    //
    // @IBOUTLETS
    //
    @IBOutlet weak var imageViewUserProfileImage: UIImageView!
    @IBOutlet weak var labelUserProfileName: UILabel!
    @IBOutlet weak var labelUserProfileTitle: UILabel!
    @IBOutlet weak var labelUserProfileOrganizationName: UILabel!
    @IBOutlet weak var labelUserProfileDescription: UILabel!
    
    @IBOutlet weak var buttonUserProfileSubmissionCount: UIButton!
    @IBOutlet weak var buttonUserProfileActionCount: UIButton!
    @IBOutlet weak var buttonUserProfileGroupCount: UIButton!

    @IBOutlet weak var submissionTableView: UITableView!
    @IBOutlet weak var actionsTableView: UITableView!
    @IBOutlet weak var groupsTableView: UITableView!

    
    //
    // MARK: @IBActions
    //
    @IBAction func changeUserProfileTab(sender: UIButton) {
        
        if (sender.restorationIdentifier == "buttonTabActionNumber" || sender.restorationIdentifier == "buttonTabActionLabel") {
            
            print("Show the Actions tab")
            self.actionsTableView.hidden = false
            self.submissionTableView.hidden = true
            self.groupsTableView.hidden = true
            
        } else if (sender.restorationIdentifier == "buttonTabGroupNumber" || sender.restorationIdentifier == "buttonTabGroupLabel") {
            
            print("Show the Groups tab")
            self.actionsTableView.hidden = true
            self.submissionTableView.hidden = true
            self.groupsTableView.hidden = false
            
        } else if (sender.restorationIdentifier == "buttonTabSubmissionNumber" || sender.restorationIdentifier == "buttonTabSubmissionLabel") {
            
            print("Show the Subsmissions tab")
            self.actionsTableView.hidden = true
            self.submissionTableView.hidden = false
            self.groupsTableView.hidden = true
            
        }
        
    }
    
    @IBAction func toggleUILableNumberOfLines(sender: UITapGestureRecognizer) {
        
        let field: UILabel = sender.view as! UILabel
        
        switch field.numberOfLines {
        case 0:
            if sender.view?.restorationIdentifier == "labelUserProfileDescription" {
                field.numberOfLines = 3
            }
            else {
                field.numberOfLines = 1
            }
            break
        default:
            field.numberOfLines = 0
            break
        }
        
    }
    
    
    //
    // MARK: Variables
    //
    var userProfile: JSON?
    
    //
    // MARK: UIKit Overrides
    //
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.labelUserProfileTitle.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(ProfileTableViewController.toggleUILableNumberOfLines(_:))))
        
        self.labelUserProfileOrganizationName.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(ProfileTableViewController.toggleUILableNumberOfLines(_:))))
        
        self.labelUserProfileDescription.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(ProfileTableViewController.toggleUILableNumberOfLines(_:))))
        
        
        //
        // SETUP SUBMISSION TABLE
        //
        self.submissionTableView.delegate = self
        self.submissionTableView.dataSource = self
        
        let submissionRefreshControl = UIRefreshControl()
        submissionRefreshControl.restorationIdentifier = "submissionRefreshControl"
        
        submissionRefreshControl.addTarget(self, action: #selector(ProfileTableViewController.refreshTableView(_:)), forControlEvents: .ValueChanged)
        
        submissionTableView.addSubview(submissionRefreshControl)
        
        
        //
        // SETUP SUBMISSION TABLE
        //
        
        self.actionsTableView.delegate = self
        self.actionsTableView.dataSource = self
        
        let actionRefreshControl = UIRefreshControl()
        actionRefreshControl.restorationIdentifier = "actionRefreshControl"
        
        actionRefreshControl.addTarget(self, action: #selector(ProfileTableViewController.refreshTableView(_:)), forControlEvents: .ValueChanged)
        
        actionsTableView.addSubview(actionRefreshControl)
        
        
        //
        // SETUP SUBMISSION TABLE
        //
        
        self.groupsTableView.delegate = self
        self.groupsTableView.dataSource = self
        
        let groupRefreshControl = UIRefreshControl()
        groupRefreshControl.restorationIdentifier = "groupRefreshControl"
        
        groupRefreshControl.addTarget(self, action: #selector(ProfileTableViewController.refreshTableView(_:)), forControlEvents: .ValueChanged)
        
        groupsTableView.addSubview(groupRefreshControl)
        
        
        //
        // Show User Profile Information in Header View
        //
        self.attemptLoadUserProfile()
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    //
    // MARK: Custom Functionality
    //
    func refreshTableView(sender: UIRefreshControl) {
        print("sender \(sender.restorationIdentifier)")
        sender.endRefreshing()
    }
    
    func displayUserProfileInformation() {
        
        // Ensure we have loaded the user profile
        guard (self.userProfile != nil) else { return }
        
        // Display user's first and last name
        if let _first_name = self.userProfile!["properties"]["first_name"].string,
            let _last_name = self.userProfile!["properties"]["last_name"].string {
            self.labelUserProfileName.text = _first_name + " " + _last_name
        }
        
        // Display user's title
        if let _title = self.userProfile!["properties"]["title"].string {
            self.labelUserProfileTitle.text = _title
        }

        // Display user's organization name
        if let _organization_name = self.userProfile!["properties"]["organization_name"].string {
            self.labelUserProfileOrganizationName.text = _organization_name
        }

        // Display user's description/bio
        if let _description = self.userProfile!["properties"]["description"].string {
            self.labelUserProfileDescription.text = _description
        }

        // Display user's organization name
        let _group_count = self.userProfile!["properties"]["groups"].count
        
        if (_group_count >= 1) {
            self.buttonUserProfileGroupCount.setTitle("\(_group_count)", forState: .Normal)
        }
        
        // Display user's profile picture
        var userProfileImageURL: NSURL!
        
        if let thisUserProfileImageURLString = self.userProfile!["properties"]["picture"].string {
            userProfileImageURL = NSURL(string: String(thisUserProfileImageURLString))
        }
        
        self.imageViewUserProfileImage.kf_indicatorType = .Activity
        self.imageViewUserProfileImage.kf_showIndicatorWhenLoading = true
        
        self.imageViewUserProfileImage.kf_setImageWithURL(userProfileImageURL, placeholderImage: nil, optionsInfo: nil, progressBlock: nil, completionHandler: {
            (image, error, cacheType, imageUrl) in
            self.imageViewUserProfileImage.image = image
            self.imageViewUserProfileImage.clipsToBounds = true
        })


    }
    
    
    //
    // MARK: HTTP Request/Response functionality
    //
    func attemptLoadUserProfile() {
        
        let accessToken = NSUserDefaults.standardUserDefaults().objectForKey("currentUserAccountAccessToken")
        let headers = [
            "Authorization": "Bearer " + (accessToken! as! String)
        ]
        
        if let userId = NSUserDefaults.standardUserDefaults().objectForKey("currentUserAccountUID") as? NSNumber {
            
            let revisedEndpoint = Endpoints.GET_USER_PROFILE + "\(userId)"
            
            Alamofire.request(.GET, revisedEndpoint, headers: headers, encoding: .JSON).responseJSON { response in
                
                print("response.result \(response.result)")
                
                switch response.result {
                case .Success(let value):
                    let json = JSON(value)
                    
                    print("Response Success \(value)")
                    
                    if (json != nil) {
                        
                        // Retain the returned data
                        self.userProfile = json
                        
                        // Show the data on screen
                        self.displayUserProfileInformation()
                    }
                    
                case .Failure(let error):
                    print("Response Failure \(error)")
                }
            }
            
        } else {
            self.attemptRetrieveUserID()
        }
        
    }
    
    func attemptRetrieveUserID() {
        
        let accessToken = NSUserDefaults.standardUserDefaults().objectForKey("currentUserAccountAccessToken")
        let headers = [
            "Authorization": "Bearer " + (accessToken! as! String)
        ]
        
        Alamofire.request(.GET, Endpoints.GET_USER_ME, headers: headers, encoding: .JSON)
            .responseJSON { response in
                
                switch response.result {
                case .Success(let value):
                    let json = JSON(value)
                    
                    if let data: AnyObject = json.rawValue {
                        NSUserDefaults.standardUserDefaults().setValue(data["id"], forKeyPath: "currentUserAccountUID")
                        
                        self.attemptLoadUserProfile()
                    }
                    
                case .Failure(let error):
                    print(error)
                }
        }
    }

    
    //
    // PROTOCOL REQUIREMENT: UITableViewDelegate
    //
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if (tableView.restorationIdentifier == "submissionsTableView") {
            return 45
        } else if (tableView.restorationIdentifier == "actionsTableView") {
            return 12
        } else if (tableView.restorationIdentifier == "groupsTableView") {
            return 5
        } else {
            return 0
        }
        
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if (tableView.restorationIdentifier == "submissionsTableView") {
            let cell = tableView.dequeueReusableCellWithIdentifier("userProfileSubmissionCell", forIndexPath: indexPath) as! UserProfileSubmissionTableViewCell
            
            cell.labelUserProfileSubmissionRowName.text = "Submission" + String(indexPath.row)
            
            return cell
        } else if (tableView.restorationIdentifier == "actionsTableView") {
            let cell = tableView.dequeueReusableCellWithIdentifier("userProfileActionCell", forIndexPath: indexPath) as! UserProfileActionsTableViewCell
            
            cell.labelUserProfileSubmissionRowName.text = "Action" + String(indexPath.row)
            
            return cell
        } else if (tableView.restorationIdentifier == "groupsTableView") {
            let cell = tableView.dequeueReusableCellWithIdentifier("userProfileGroupCell", forIndexPath: indexPath) as! UserProfileGroupsTableViewCell
            
            cell.labelUserProfileSubmissionRowName.text = "Group" + String(indexPath.row)
            
            return cell
        } else {
            return UITableViewCell()
        }
        
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        print("row tapped \(indexPath)")
    }
    

}
