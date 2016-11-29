//
//  UserProfileCreateGroupsTableViewController.swift
//  Water-Reporter
//
//  Created by Viable Industries on 11/11/16.
//  Copyright © 2016 Viable Industries, L.L.C. All rights reserved.
//

import Alamofire
import Foundation
import SwiftyJSON
import UIKit

class UserProfileCreateGroupsTableViewController: UITableViewController, UINavigationControllerDelegate {
    
    
    //
    // MARK: @IBOutlets
    //
    @IBOutlet var viewActivityIndicator: UIView!
    
    
    //
    // MARK: @IBActions
    //
    @IBAction func dismissUserProfileCreateGroupsTableViewController(sender: UIBarButtonItem) {
        
        // Show saving message
        self.status("saving")
        
        let _user_id_number = NSUserDefaults.standardUserDefaults().objectForKey("currentUserAccountUID") as! NSNumber
        
        var _temporary_groups: [AnyObject] = [AnyObject]()
        var _temporary_organizations: [AnyObject] = [AnyObject]()

        // Set headers
        let _headers = self.buildRequestHeaders()
        let _endpoint = Endpoints.GET_USER_PROFILE + "\(_user_id_number)"
        var _parameters: [String: AnyObject] = [
            "groups": [AnyObject](),
            "organization": [AnyObject]()
        ]

        //
        // Create Joined date
        //
        let dateFormatter = NSDateFormatter()
        let date = NSDate()
        dateFormatter.dateStyle = NSDateFormatterStyle.MediumStyle
        dateFormatter.timeStyle = NSDateFormatterStyle.NoStyle

        let _joined_on: String! = dateFormatter.stringFromDate(date)

        //
        // Add Group to the groups array
        //
        if tempGroups.count >= 1 {
            
            for _organization_id in tempGroups {
                print("group id \(_organization_id)")
                
                let _group = [
                    "organization_id": "\(_organization_id)",
                    "joined_on": _joined_on
                ]
                
                let _organization = [
                    "id": "\(_organization_id)"
                ]
                
                _temporary_groups.append(_group)
                _temporary_organizations.append(_organization)
                
            }
            
            _parameters["groups"] = _temporary_groups
            _parameters["organization"] = _temporary_organizations
            
        }

        Alamofire.request(.PATCH, _endpoint, parameters: _parameters, headers: _headers, encoding: .JSON)
            .responseJSON { response in
                
                switch response.result {
                case .Success(let value):
                    print("Request Success \(value)")
                    
                    let nextViewController = self.storyBoard.instantiateViewControllerWithIdentifier("UserProfileCompleteViewController") as! UserProfileCompleteViewController
                    
                    let navigationViewController = UINavigationController(rootViewController: nextViewController)
                    
                    self.presentViewController(navigationViewController, animated:true, completion: nil)

                    break
                case .Failure(let error):
                    print("Request Failure \(error)")
                    break
                }
                
        }
        
    }
    
    @IBAction func refreshTableView(refreshControl: UIRefreshControl) {
        
        // If the view is not already refreshing, send a
        // request to load all gorups
        if (self.refreshControl?.refreshing == false) {
            
            // Clear all groups currently listed
            self.groups = []
            
            // Attempt to load all groups again
            self.attemptLoadAllGroups()
        }
        
    }
    
    @IBAction func joinGroup(sender: UIButton) {
        
        let _organization_id_number: String! = "\(self.groups!["features"][sender.tag]["id"])"
        
        self.tempGroups.append(_organization_id_number)
        
        print("joinGroup::finished::tempGroups \(self.tempGroups)")
        
        self.tableView.reloadData()
        
    }
    
    @IBAction func leaveGroup(sender: UIButton) {
        
        let _organization_id_number: String! = "\(self.groups!["features"][sender.tag]["id"])"
        
        self.tempGroups = self.tempGroups.filter() {$0 != _organization_id_number}
        
        print("leaveGroup::finished::tempGroups \(self.tempGroups)")
    
        self.tableView.reloadData()

    }

    
    //
    // MARK: Variables
    //
    var loadingView: UIView!
    var groups: JSON?
    let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
    
    var tempGroups: [String] = [String]()

    
    //
    // MARK: Overrides
    //
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Load all of the groups on WaterReporter.org
        self.attemptLoadAllGroups()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    //
    // MARK: Statuses
    //
    func status(statusType: String) {
        
        switch (statusType) {
            case "loading":
                // Create a view that covers the entire screen
                self.loadingView = self.viewActivityIndicator
                self.loadingView.frame = CGRectMake(0, 0, self.view.frame.width, self.view.frame.height)
                
                self.view.addSubview(self.loadingView)
                self.view.bringSubviewToFront(self.loadingView)
                
                // Make sure that the Done button is disabled
                self.navigationItem.rightBarButtonItem?.enabled = false
                
                // Hide table view separators
                self.tableView.separatorStyle = UITableViewCellSeparatorStyle.None
                
                break
            case "complete":
                // Hide the loading view
                self.loadingView.removeFromSuperview()

                // Hide table view separators
                self.tableView.separatorStyle = UITableViewCellSeparatorStyle.SingleLine

                // Make sure that the Done button is disabled
                self.navigationItem.rightBarButtonItem?.enabled = true
                
                break
            case "saving":
                print("Saving groups page and dismiss modal")
                break
            case "doneLoadingWithError":
                // Hide the loading view
                self.loadingView.removeFromSuperview()
            default:
                break
        }
    }
    
    
    //
    // MARK: Request/Response Functionality
    //
    func buildRequestHeaders() -> [String: String] {
        
        let accessToken = NSUserDefaults.standardUserDefaults().objectForKey("currentUserAccountAccessToken")
        
        return [
            "Authorization": "Bearer " + (accessToken! as! String)
        ]
    }

    func attemptLoadAllGroups(isRefreshingReportsList: Bool = false) {
        
        // Show loading symbol while Groups load
        self.status("loading")
        
        // Set headers
        let _headers = self.buildRequestHeaders()
        let _endpoint = Endpoints.GET_MANY_ORGANIZATIONS
        let _parameters = [
            "results_per_page": 100
        ]

        // Execute request
        Alamofire.request(.GET, _endpoint, parameters: _parameters, headers: _headers)
            .responseJSON { response in
                
                switch response.result {
                    case .Success(let value):
                        //print("Request Success: \(value)")

                        // Assign response to groups variable
                        self.groups = JSON(value)
                        
                        // Tell the refresh control to stop spinning
                        self.refreshControl?.endRefreshing()
                        
                        // Set status to complete
                        self.status("complete")

                        // Refresh the data in the table so the newest items appear
                        self.tableView.reloadData()

                        break
                    case .Failure(let error):
                        print("Request Failure: \(error)")
                        
                        // Stop showing the loading indicator
                        self.status("doneLoadingWithError")
                        
                        break
                }
            }
        
    }
    
    
    //
    // MARK: Table Overrides
    //
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("groupTableViewCell", forIndexPath: indexPath) as! GroupTableViewCell
        
        if let _this_group = self.groups?["features"][indexPath.row]["properties"] {
        
            //
            // Assign the organization logo to the UIImageView
            //
            cell.imageViewGroupLogo.tag = indexPath.row
            
            var organizationImageUrl:NSURL!
            
            if let thisOrganizationImageUrl: String = _this_group["picture"].string {
                organizationImageUrl = NSURL(string: thisOrganizationImageUrl)
            }
            
            cell.imageViewGroupLogo.kf_indicatorType = .Activity
            cell.imageViewGroupLogo.kf_showIndicatorWhenLoading = true
            
            cell.imageViewGroupLogo.kf_setImageWithURL(organizationImageUrl, placeholderImage: nil, optionsInfo: nil, progressBlock: nil, completionHandler: {
                (image, error, cacheType, imageUrl) in
                cell.imageViewGroupLogo.image = image
                cell.imageViewGroupLogo.layer.cornerRadius = cell.imageViewGroupLogo.frame.size.width / 2
                cell.imageViewGroupLogo.clipsToBounds = true
            })
            
            //
            // Assign the organization name to the UILabel
            //
            if let thisOrganizationName: String = _this_group["name"].string {
                cell.labelGroupName.text = thisOrganizationName
            }

            cell.buttonJoinGroup.tag = indexPath.row
            cell.buttonJoinGroup.addTarget(self, action: #selector(joinGroup(_:)), forControlEvents: .TouchUpInside)

            cell.buttonLeaveGroup.tag = indexPath.row
            cell.buttonLeaveGroup.addTarget(self, action: #selector(leaveGroup(_:)), forControlEvents: .TouchUpInside)

            // Hide "Leave Group" UIButton by default. Since this is
            // a newly registered user, there is no need to initially
            // set Join/Leave UIButtons dynamically.
            let _organization_id_number: String! = "\(_this_group["id"])"

            if self.tempGroups.contains(_organization_id_number) {
                cell.buttonLeaveGroup.hidden = false
                cell.buttonJoinGroup.hidden = true
            }
            else {
                cell.buttonLeaveGroup.hidden = true
                cell.buttonJoinGroup.hidden = false
            }
        }
        
        return cell
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if self.groups == nil {
            return 1
        }
        
        return (self.groups?["features"].count)!
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 72.0
    }
    
    
}
