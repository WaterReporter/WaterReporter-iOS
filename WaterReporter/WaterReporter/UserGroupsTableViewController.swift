//
//  ProfileTableViewController.swift
//  Profle Test 001
//
//  Created by Viable Industries on 11/6/16.
//  Copyright © 2016 Viable Industries, L.L.C. All rights reserved.
//

import ActiveLabel
import Alamofire
import Foundation
import Kingfisher
import SwiftyJSON
import UIKit

class UserGroupsTableViewController: UITableViewController, UINavigationControllerDelegate {
    
    //
    // MARK: @IBActions
    //
    
    @IBAction func openUserGroupView(sender: UIButton) {
        let nextViewController = self.storyBoard.instantiateViewControllerWithIdentifier("OrganizationTableViewController") as! OrganizationTableViewController
        
        let _groups = JSON(self.userGroupsObjects)
        let _group_id = _groups[sender.tag]["properties"]["organization"]["id"]
        
        nextViewController.groupId = "\(_group_id)"
        nextViewController.groupObject = _groups[sender.tag]
        
        self.navigationController?.pushViewController(nextViewController, animated: true)
    }
    
    //
    // MARK: Variables
    //
    let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
    
    var userId: String!
    var userObject: JSON?
    var userProfile: JSON?
    var userSnapshot: JSON?
    var isActingUsersProfile: Bool = false
    
    var userGroups: JSON?
    var userGroupsObjects = [AnyObject]()
    var userGroupsPage: Int = 1
    var groupsRefreshControl: UIRefreshControl = UIRefreshControl()
    
    //
    // MARK: UIKit Overrides
    //
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        
        // Check for profile updates
        //
        if self.userObject == nil {
            
            print("Check for updated user information")
            
            if let userIdNumber = NSUserDefaults.standardUserDefaults().objectForKey("currentUserAccountUID") as? NSNumber {
                self.userId = "\(userIdNumber)"
                self.attemptLoadUserProfile(self.userId, withoutReportReload: false)
            } else {
                self.attemptRetrieveUserID()
            }
            
        }
        
        self.navigationController?.navigationBarHidden = false
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(true)
        
        if (self.isMovingFromParentViewController()) {
            if (self.navigationController?.viewControllers.last?.restorationIdentifier! == "SearchTableViewController") {
                self.navigationController?.navigationBarHidden = true
            } else {
                self.navigationController?.navigationBarHidden = false
            }
        }
        else {
            self.navigationController?.navigationBarHidden = false
        }
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        // Check to see if a user id was passed to this view from
        // another view. If no user id was passed, then we know that
        // we should be displaying the acting user's profile
        if (self.userId == nil) {
            
            
        }
        
        // Show User Profile Information in Header View
        if self.userObject != nil && self.userId != nil {
            
            // We should never load from NSUserDefaults for this area
            //
            
            // Retain the returned data
            self.userProfile = self.userObject
            
            print("Loading another user's profile \(self.userProfile)")
            
            self.isActingUsersProfile = false
            
            self.navigationItem.title = ""
            
//            if let _first_name = self.userProfile!["properties"]["first_name"].string,
//                let _last_name = self.userProfile!["properties"]["last_name"].string {
//                self.navigationItem.title = _first_name + " " + _last_name
//            }
            
            self.navigationItem.rightBarButtonItem?.enabled = false
            
            // Show the data on screen
            self.displayUserProfileInformation()
            
        }
        else if self.userId == nil {
            
            print("Loading current user's profile")
            
            self.isActingUsersProfile = true
            
            if let userIdNumber = NSUserDefaults.standardUserDefaults().objectForKey("currentUserAccountUID") as? NSNumber {
                self.userId = "\(userIdNumber)"
                self.attemptLoadUserProfile(self.userId)
            } else {
                self.attemptRetrieveUserID()
            }
            
        }
        
        //
        // Set dynamic row height
        //
        
//        self.groupsTableView.rowHeight = UITableViewAutomaticDimension;
//        self.groupsTableView.estimatedRowHeight = 56.0;
//        
//        //
//        // Set up groups table
//        //
//        
//        self.groupsTableView.delegate = self
//        self.groupsTableView.dataSource = self
        
//        groupsRefreshControl = UIRefreshControl()
//        groupsRefreshControl.restorationIdentifier = "groupRefreshControl"
//        
//        groupsRefreshControl.addTarget(self, action: #selector(UserGroupsTableViewController.refreshGroupsTableView(_:)), forControlEvents: .ValueChanged)
        
//        groupsTableView.addSubview(groupsRefreshControl)
        
        // Make sure we are getting 'auto layout' specific sizes
        // otherwise any math we do will be messed up
        self.view.setNeedsLayout()
        self.view.layoutIfNeeded()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    //
    // MARK: Custom Functionality
    //
    
    func refreshGroupsTableView(sender: UIRefreshControl) {
        
        self.userGroupsPage = 1
        self.userGroups = nil
        self.userGroupsObjects = []
        
        self.attemptLoadUserGroups(true)
        
    }
    
    func displayUserProfileInformation(withoutReportReload: Bool = false) {
        
        print("displayUserProfileInformation")
        
        print("User profile value is: \(self.userProfile)")
        
        // Ensure we have loaded the user profile
        guard (self.userProfile != nil) else {
            print("RETURNING NIL")
            return
        }
        
        //
        // Load and display other user information
        //
        if !withoutReportReload {
            
            self.attemptLoadUserGroups()
        }
        
    }
    
    
    //
    // MARK: HTTP Request/Response functionality
    //
    func buildRequestHeaders() -> [String: String] {
        
        let accessToken = NSUserDefaults.standardUserDefaults().objectForKey("currentUserAccountAccessToken")
        
        return [
            "Authorization": "Bearer " + (accessToken! as! String)
        ]
    }
    
    func attemptLoadUserProfile(_user_id: String, withoutReportReload: Bool = false) {
        
        if userId == "" {
            return
        }
        
        let _headers = buildRequestHeaders()
        
        let revisedEndpoint = Endpoints.GET_USER_PROFILE + "\(_user_id)"
        
        print("revisedEndpoint \(revisedEndpoint)")
        
        Alamofire.request(.GET, revisedEndpoint, headers: _headers, encoding: .JSON).responseJSON { response in
            
            print("response.result \(response.result)")
            
            switch response.result {
            case .Success(let value):
                let json = JSON(value)
                
                //                print("Response Success \(value)")
                
                if (json != nil) {
                    
                    // Retain the returned data
                    self.userProfile = json
                    
                    // Show the data on screen
                    self.displayUserProfileInformation(withoutReportReload)
                    
                }
                
            case .Failure(let error):
                print("Response Failure \(error)")
            }
        }
        
    }
    
    func attemptRetrieveUserID() {
        
        let _headers = buildRequestHeaders()
        
        Alamofire.request(.GET, Endpoints.GET_USER_ME, headers: _headers, encoding: .JSON)
            .responseJSON { response in
                
                switch response.result {
                case .Success(let value):
                    let json = JSON(value)
                    
                    if let data: AnyObject = json.rawValue {
                        
                        // Set the user id as a number and save it to the application cache
                        //
                        let _user_id = data["id"] as! NSNumber
                        NSUserDefaults.standardUserDefaults().setValue(_user_id, forKeyPath: "currentUserAccountUID")
                        
                        // Set user id to view variable
                        //
                        self.userId = "\(_user_id)"
                        
                        // Continue loading the user profile
                        //
                        self.attemptLoadUserProfile(self.userId)
                        
                    }
                    
                case .Failure(let error):
                    print(error)
                }
        }
    }
    
    //
    // Fetch user groups
    //
    
    func attemptLoadUserGroups(isRefreshingReportsList: Bool = false) {
        
        // Set headers
        let _headers = self.buildRequestHeaders()
        
        let GET_GROUPS_ENDPOINT = Endpoints.GET_USER_PROFILE + "\(userId)/groups"
        
        let _parameters = [
            "page": "\(self.userGroupsPage)"
        ]
        
        Alamofire.request(.GET, GET_GROUPS_ENDPOINT, headers: _headers, parameters: _parameters).responseJSON { response in
            
            switch response.result {
            case .Success(let value):
                print("Request Success: \(value)")
                
                // Before anything else, check to make sure we are
                // processing a valid request. Sometimes we get error
                // codes and we need to handle them appropriately.
                //
                let responseCode = value["code"]
                
                if responseCode == nil {
                    print("Unable to continue processing error encountered \(responseCode)")
                } else {
                    // No response code found, so go ahead and
                    // continue processing the response.
                    //
                    if (isRefreshingReportsList) {
                        self.userGroups = JSON(value)
                        self.userGroupsObjects = value["features"] as! [AnyObject]
                        self.groupsRefreshControl.endRefreshing()
                    } else {
                        if let features = value["features"] {
                            if features != nil {
                                self.userGroups = JSON(value)
                                self.userGroupsObjects += features as! [AnyObject]
                            }
                        }
                        
                    }
                    
                    // Set the number on the profile page
//                    let _group_count = self.userGroups!["properties"]["num_results"]
                    
//                    if (_group_count != "") {
//                        self.buttonUserProfileGroupCount.setTitle("\(_group_count)", forState: .Normal)
//                    }
                    
                    // Refresh the data in the table so the newest items appear
//                    self.groupsTableView.reloadData()
                    
                    self.userGroupsPage += 1
                    
                }
                
                break
                
            case .Failure(let error):
                print("Request Failure: \(error)")
                
                // Stop showing the loading indicator
                //self.status("doneLoadingWithError")
                
                break
                
            }
            
        }
        
    }
    
    //
    // PROTOCOL REQUIREMENT: UITableViewDelegate
    //
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 56.0
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            
        guard (JSON(self.userGroupsObjects) != nil) else { return 0 }
        
        if self.userGroupsObjects.count == 0 {
            print("Groups showing 0, make sure at least 1 row is visible.")
            return 1
        }
        
        print("Groups showing count \(self.userGroupsObjects.count)")
        
        return (self.userGroupsObjects.count)
        
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let emptyCell = tableView.dequeueReusableCellWithIdentifier("emptyTableViewCell", forIndexPath: indexPath) as! EmptyTableViewCell
        
        //
        // Groups
        //
        let cell = tableView.dequeueReusableCellWithIdentifier("userProfileGroupCell", forIndexPath: indexPath) as! UserProfileGroupsTableViewCell
        
        print("Groups cell")
        
        guard (self.userGroups != nil) else { return emptyCell }
        
        // Display Group Name
        let _groups = JSON(self.userGroupsObjects)
        
        let _thisSubmission = _groups[indexPath.row]["properties"]
        print("Show (group) _thisSubmission \(_thisSubmission)")
        
//        if _thisSubmission == nil {
//            
//            if self.isActingUsersProfile == false {
//                emptyCell.emptyMessageDescription.text = "Looks like this user hasn't joined any groups."
//                emptyCell.emptyMessageAction.hidden = true
//            }
//            else {
//                emptyCell.emptyMessageDescription.text = "There’s power in numbers, join a group"
//                emptyCell.emptyMessageAction.hidden = false
//                emptyCell.emptyMessageAction.setTitle("Join a group", forState: .Normal)
//                emptyCell.emptyMessageAction.addTarget(self, action: #selector(self.emptyMessageJoinGroup(_:)), forControlEvents: UIControlEvents.TouchUpInside)
//            }
//            
//            return emptyCell
//        }
        
        if let _group_name = _groups[indexPath.row]["properties"]["organization"]["properties"]["name"].string {
            cell.labelUserProfileGroupName.text = _group_name
        }
        
        cell.buttonGroupSelection.tag = indexPath.row
        
        // Display Group Image
        if let _group_image_url = _groups[indexPath.row]["properties"]["organization"]["properties"]["picture"].string {
            
            let groupProfileImageURL: NSURL! = NSURL(string: _group_image_url)
            
            cell.imageViewUserProfileGroup.kf_indicatorType = .Activity
            cell.imageViewUserProfileGroup.kf_showIndicatorWhenLoading = true
            
            cell.imageViewUserProfileGroup.kf_setImageWithURL(groupProfileImageURL, placeholderImage: nil, optionsInfo: nil, progressBlock: nil, completionHandler: {
                (image, error, cacheType, imageUrl) in
                if (image != nil) {
                    cell.imageViewUserProfileGroup.image = UIImage(CGImage: (image?.CGImage)!, scale: (image?.scale)!, orientation: UIImageOrientation.Up)
                    cell.imageViewUserProfileGroup.layer.cornerRadius = cell.imageViewUserProfileGroup.frame.size.width / 2
                    cell.imageViewUserProfileGroup.clipsToBounds = true
                }
            })
        }
        else {
            cell.imageViewUserProfileGroup.image = nil
        }
        
        if (indexPath.row == self.userGroupsObjects.count - 2 && self.userGroupsObjects.count < self.userGroups!["properties"]["num_results"].int) {
            self.attemptLoadUserGroups()
        }
        
        return cell
        
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        print("row tapped \(indexPath)")
    }
    
}
