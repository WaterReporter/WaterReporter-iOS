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
        
        let _groups = self.groups
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
//    var userObject: JSON?
//    var userProfile: JSON?
    
//    var groups: JSON?
    
    var groupResponse: JSON?
    var groups: JSON = []
//    var userGroupsObjects = [AnyObject]()
    var page: Int = 1
    
//    var report:AnyObject!
//    var reportId:String!
//    var likes: JSON = []
//    var page: Int = 1
    
    //
    // MARK: UIKit Overrides
    //
    override func viewWillAppear(animated: Bool) {

        super.viewWillAppear(true)
        
        // Check for profile updates
        //
//        if self.userObject == nil {
//            
//            print("Check for updated user information")
//            
//            if let userIdNumber = NSUserDefaults.standardUserDefaults().objectForKey("currentUserAccountUID") as? NSNumber {
//                self.userId = "\(userIdNumber)"
//                self.attemptLoadUserProfile(self.userId, withoutReportReload: false)
//            } else {
//                self.attemptRetrieveUserID()
//            }
//            
//        }
        
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
        
        print("View did load")

        self.navigationController?.setNavigationBarHidden(false, animated: false)
        
        // Check to see if a user id was passed to this view from
        // another view. If no user id was passed, then we know that
        // we should be displaying the acting user's profile
        if (self.userId == nil) {
            return
        }
            
        self.navigationItem.title = ""
        
        self.navigationItem.rightBarButtonItem?.enabled = false
        
        self.tableView.tableFooterView = UIView()
        
        // Show the data on screen
        self.displayUserProfileInformation()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    //
    // MARK: Custom Functionality
    //
    
    func displayUserProfileInformation(withoutReportReload: Bool = false) {
        
        print("displayUserProfileInformation")
        
        print("User profile value is: \(self.userId)")
        
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
    
    //
    // Fetch user groups
    //
    
    func attemptLoadUserGroups(isRefreshingReportsList: Bool = false) {
        
        // Set headers
        let _headers = self.buildRequestHeaders()
        
        let GET_GROUPS_ENDPOINT = Endpoints.GET_USER_PROFILE + "\(userId)/groups"
        
        let _parameters = [
            "page": "\(self.page)"
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
                    
                    print("Success: \(value)")
                    
                    //
                    // Choose whether or not the reports should refresh or
                    // whether loaded reports should be appended to the existing
                    // list of reports
                    //
                    if (isRefreshingReportsList) {
                        self.groupResponse = JSON(value)
                        self.groups = (self.groupResponse?["features"])!
                        self.refreshControl?.endRefreshing()
                    }
                    else {
                        self.groupResponse = JSON(value)
                        self.groups = (self.groupResponse?["features"])!
                    }
                    
                    print("self.groups \(self.groups)")
                    
                    self.tableView.reloadData()
                    
                    self.page += 1
                    
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
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 56.0
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        var _count: Int = 0
        
        if (self.groups.count >= 1) {
            _count = self.groups.count
        }
        
        return _count
        
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        //
        // Groups
        //
        let cell = tableView.dequeueReusableCellWithIdentifier("userProfileGroupCell", forIndexPath: indexPath) as! UserProfileGroupsTableViewCell
        
        print("Groups cell")
        
        // Display Group Name
        let _groups = self.groups
        
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
        
        if (indexPath.row == self.groups.count - 2 && self.groups.count < self.groupResponse!["properties"]["num_results"].int) {
            self.attemptLoadUserGroups()
        }
        
        return cell
        
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        print("row tapped \(indexPath)")
    }
    
}
