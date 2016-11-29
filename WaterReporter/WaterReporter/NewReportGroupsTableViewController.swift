//
//  NewReportGroupsTableViewController.swift
//  Water-Reporter
//
//  Created by Viable Industries on 11/15/16.
//  Copyright © 2016 Viable Industries, L.L.C. All rights reserved.
//

import Alamofire
import Foundation
import Kingfisher
import SwiftyJSON
import UIKit

protocol NewReportGroupSelectorDelegate {
    func sendGroups(groups: [String])
}


class NewReportGroupsTableViewController: UITableViewController, UINavigationControllerDelegate {
    
    
    //
    // MARK: @IBOutlets
    //
    @IBOutlet var viewActivityIndicator: UIView!
    
    @IBAction func refreshTableView(refreshControl: UIRefreshControl) {
        
        // If the view is not already refreshing, send a
        // request to load all gorups
        if (self.refreshControl?.refreshing == false) {
            
            // Clear all groups currently listed
            self.groups = []
            
            // Attempt to load all groups again
            self.attemptLoadUserGroups()
        }
        
    }
    
    @IBAction func selectGroup(sender: UISwitch) {

        if sender.on {
            let _organization_id_number: String! = "\(self.groups!["features"][sender.tag]["properties"]["organization_id"])"
            self.tempGroups.append(_organization_id_number)
            print("addGroup::finished::tempGroups \(self.tempGroups)")
        } else {
            let _organization_id_number: String! = "\(self.groups!["features"][sender.tag]["properties"]["organization_id"])"
            self.tempGroups = self.tempGroups.filter() {$0 != _organization_id_number}
            print("removeGroup::finished::tempGroups \(self.tempGroups)")
        }

    }
    
    @IBAction func dismissGroupSelector(sender: UIBarButtonItem) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func saveGroupSelections(sender: UIBarButtonItem) {
        if let del = delegate {
            del.sendGroups(self.tempGroups)
            self.dismissViewControllerAnimated(true, completion: nil)
        }
    }

    
    //
    // MARK: Variables
    //
    var loadingView: UIView!
    var groups: JSON?
    let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
    var delegate: NewReportGroupSelectorDelegate?
    var tempGroups: [String] = [String]()

    
    //
    // MARK: Overrides
    //
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Show loading symbol while Groups load
        self.status("loading")
        
        // Load all of the groups on WaterReporter.org
        self.attemptLoadUserGroups()
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
            self.navigationItem.leftBarButtonItem?.enabled = false
            
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
            self.navigationItem.leftBarButtonItem?.enabled = true
            
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
    // MARK: Table Overrides
    //
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("reportGroupTableViewCell", forIndexPath: indexPath) as! ReportGroupTableViewCell
        
        //
        // Assign the organization logo to the UIImageView
        //
        cell.imageViewGroupLogo.tag = indexPath.row
        
        var organizationImageUrl:NSURL!
        
        if let thisOrganizationImageUrl: String = self.groups?["features"][indexPath.row]["properties"]["organization"]["properties"]["picture"].string {
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
        if let thisOrganizationName: String = self.groups?["features"][indexPath.row]["properties"]["organization"]["properties"]["name"].string {
            cell.labelGroupName.text = thisOrganizationName
        }
        
        //
        cell.switchSelectGroup.tag = indexPath.row
        //cell.buttonJoinGroup.tag = indexPath.row
        //cell.buttonJoinGroup.addTarget(self, action: #selector(joinGroup(_:)), forControlEvents: .TouchUpInside)
        
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

    
    //
    // MARK: HTTP Request/Response Functionality
    //
    
    func buildRequestHeaders() -> [String: String] {
        
        let accessToken = NSUserDefaults.standardUserDefaults().objectForKey("currentUserAccountAccessToken")
        
        return [
            "Authorization": "Bearer " + (accessToken! as! String)
        ]
    }
    
    func attemptLoadUserGroups() {
        
        // Set headers
        let _headers = self.buildRequestHeaders()

        if let userId = NSUserDefaults.standardUserDefaults().objectForKey("currentUserAccountUID") as? NSNumber {
            
            let GET_GROUPS_ENDPOINT = Endpoints.GET_USER_PROFILE + "\(userId)" + "/groups"
            
            Alamofire.request(.GET, GET_GROUPS_ENDPOINT, headers: _headers, encoding: .JSON).responseJSON { response in
                
                print("response.result \(response.result)")
                
                switch response.result {
                    case .Success(let value):
                        print("Request Success: \(value)")
                        
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
            
        } else {
            self.attemptRetrieveUserID()
        }
        
    }
    
    func attemptRetrieveUserID() {
        
        // Set headers
        let _headers = self.buildRequestHeaders()
        
        Alamofire.request(.GET, Endpoints.GET_USER_ME, headers: _headers, encoding: .JSON)
            .responseJSON { response in
                
                switch response.result {
                case .Success(let value):
                    let json = JSON(value)
                    
                    if let data: AnyObject = json.rawValue {
                        NSUserDefaults.standardUserDefaults().setValue(data["id"], forKeyPath: "currentUserAccountUID")
                        
                        self.attemptLoadUserGroups()
                    }
                    
                case .Failure(let error):
                    print(error)
                }
        }
    }

    
}
