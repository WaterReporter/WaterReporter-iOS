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

class UserActionsTableViewController: UITableViewController, UINavigationControllerDelegate {
    
    //
    // MARK: @IBOutlets
    //
    
    @IBOutlet var loadingIndicatorView: UIView!
    
    //
    // MARK: @IBActions
    //
    
//    @IBAction func openSubmissionOpenGraphURL(sender: UIButton) {
//        
//        let reportId = sender.tag
//        let report = JSON(self.actions[reportId])
//        
//        let reportURL = "\(report["properties"]["social"][0]["properties"]["og_url"])"
//        
//        print("openOpenGraphURL \(reportURL)")
//        
//        UIApplication.sharedApplication().openURL(NSURL(string: "\(reportURL)")!)
//        
//    }
    
    @IBAction func presentExtraPostActions(sender: UIButton) {
        
        //
        // Set up an action sheet and add our extra actions using
        // the UIButton tag and UIButton itself as function params.
        //
        
        let postIndex = sender.tag
        
        let thisActionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        
        let shareAction = UIAlertAction(
            title: "Share post",
            style: .Default,
            handler: { action in
                self.shareButtonClicked(postIndex, button: sender)
            }
        )
        
        thisActionSheet.addAction(shareAction)
        let locationAction = UIAlertAction(
            title: "View location",
            style: .Default,
            handler: { action in
                self.loadPostLocationMap(postIndex)
            }
        )
        
        thisActionSheet.addAction(locationAction)
        
        let directionAction = UIAlertAction(
            title: "Get directions",
            style: .Default,
            handler: { action in
                self.openDirectionsURL(postIndex)
            }
        )
        
        thisActionSheet.addAction(directionAction)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        
        thisActionSheet.addAction(cancelAction)
        
        presentViewController(thisActionSheet, animated: true, completion: nil)
        
    }
    
    //@IBAction func shareButtonClicked(sender: UIButton) {
    func shareButtonClicked(postId: Int, button: UIButton) {
        
        //        print("sender.tag \(sender.tag)")
        print("sender.tag \(postId)")
        
        // let _thisReport = JSON(self.reports[(sender.tag)])
        let _thisReport = JSON(self.actions[(postId)])
        let reportId: String = "\(_thisReport["id"])"
        var objectsToShare: [AnyObject] = [AnyObject]()
        let reportURL = NSURL(string: "https://www.waterreporter.org/community/reports/" + reportId)
        var reportImageURL:NSURL!
        let tmpImageView: UIImageView = UIImageView()
        
        // SHARE > REPORT > TITLE
        //
        objectsToShare.append("\(_thisReport["properties"]["report_description"])")
        
        // SHARE > REPORT > URL
        //
        objectsToShare.append(reportURL!)
        
        // SHARE > REPORT > IMAGE
        //
        let thisReportImageURL = _thisReport["properties"]["images"][0]["properties"]["square"]
        
        if thisReportImageURL != nil {
            reportImageURL = NSURL(string: String(thisReportImageURL))
        }
        
        tmpImageView.kf_setImageWithURL(reportImageURL, placeholderImage: nil, optionsInfo: nil, progressBlock: nil, completionHandler: {
            (image, error, cacheType, imageUrl) in
            
            if (image != nil) {
                objectsToShare.append(Image(CGImage: (image?.CGImage)!, scale: (image?.scale)!, orientation: UIImageOrientation.Up))
                
                let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
                
                activityVC.popoverPresentationController?.sourceView = button
                
                self.presentViewController(activityVC, animated: true, completion: nil)
            }
            else {
                let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
                
                activityVC.popoverPresentationController?.sourceView = button
                
                self.presentViewController(activityVC, animated: true, completion: nil)
            }
        })
        
    }
    
    @IBAction func loadPostComments(sender: UIButton) {
        
        let nextViewController = self.storyBoard.instantiateViewControllerWithIdentifier("ReportCommentsTableViewController") as! ReportCommentsTableViewController
        
        let _thisReport = self.actions[(sender.tag)]
        
        nextViewController.report = _thisReport
        
        self.navigationController?.pushViewController(nextViewController, animated: true)
    }
    
//    @IBAction func loadPostLocationMap(sender: UIButton) {
    func loadPostLocationMap(postId: Int) {
        
        let nextViewController = self.storyBoard.instantiateViewControllerWithIdentifier("ActivityMapViewController") as! ActivityMapViewController
        
        let _thisReport = self.actions[(postId)]
        
        nextViewController.reportObject = _thisReport
        
        self.navigationController?.pushViewController(nextViewController, animated: true)
    }
    
    @IBAction func loadGroupProfile(sender: UIButton) {
        
        let nextViewController = self.storyBoard.instantiateViewControllerWithIdentifier("OrganizationTableViewController") as! OrganizationTableViewController
        
        let _thisReport = self.actions[(sender.tag)].objectForKey("properties")
        
        let _groupName = sender.titleLabel!.text
        
        let reportGroups = _thisReport?.objectForKey("groups") as? NSArray
        
        for _group in reportGroups! as NSArray {
            
            //            let _selectedGroupName = _group["properties"]["name"] as? String
            
            if let _selectedGroupName = _group.objectForKey("properties")!.objectForKey("name") as? String {
                
                if _selectedGroupName == _groupName {
                    
                    let _selectedGroup = JSON(_group)
                    
                    //        nextViewController.userId = "\(_thisReport["properties"]["owner"]["id"])"
                    //        nextViewController.userObject = _thisReport["properties"]["owner"]
                    //
                    //        self.navigationController?.pushViewController(nextViewController, animated: true)
                    
                    nextViewController.groupId = "\(_selectedGroup["id"])"
                    
                    print("Selected group id \(nextViewController.groupId)")
                    
                    nextViewController.groupObject = _selectedGroup
                    
                    self.navigationController?.pushViewController(nextViewController, animated: true)
                    
                }
                
            }
            
        }
        
        //        let _group = _thisReport["properties"]["groups"][0]
        //
        ////        nextViewController.userId = "\(_thisReport["properties"]["owner"]["id"])"
        ////        nextViewController.userObject = _thisReport["properties"]["owner"]
        ////
        ////        self.navigationController?.pushViewController(nextViewController, animated: true)
        //
        //        nextViewController.groupId = "\(_group["id"])"
        //        nextViewController.groupObject = _group
        //
        //        self.navigationController?.pushViewController(nextViewController, animated: true)
    }
    
    @IBAction func loadCommentOwnerProfile(sender: UIButton) {
        
        let nextViewController = self.storyBoard.instantiateViewControllerWithIdentifier("ProfileTableViewController") as! ProfileTableViewController
        
        let _thisReport = JSON(self.actions[(sender.tag)])
        
        nextViewController.userId = "\(_thisReport["properties"]["owner"]["id"])"
        nextViewController.userObject = _thisReport["properties"]["owner"]
        
        self.navigationController?.pushViewController(nextViewController, animated: true)
    }
    
    @IBAction func loadTerritoryProfile(sender: UILabel) {
        
        let nextViewController = self.storyBoard.instantiateViewControllerWithIdentifier("TerritoryViewController") as! TerritoryViewController
        
        let _thisReport = JSON(self.actions[(sender.tag)])
        
        if "\(_thisReport["properties"]["territory_id"])" != "" && "\(_thisReport["properties"]["territory_id"])" != "null" {
            
            nextViewController.territory = "\(_thisReport["properties"]["territory"]["properties"]["huc_8_name"])"
            nextViewController.territoryId = "\(_thisReport["properties"]["territory_id"])"
            nextViewController.territoryHUC8Code = "\(_thisReport["properties"]["territory"]["properties"]["huc_8_code"])"
            
            self.navigationController?.pushViewController(nextViewController, animated: true)
        }
    }
    
    @IBAction func openSubmissionsLikesList(sender: UIButton) {
        
        let nextViewController = self.storyBoard.instantiateViewControllerWithIdentifier("LikesTableViewController") as! LikesTableViewController
        
        let report = self.actions[(sender.tag)]
        nextViewController.report = report
        
        self.navigationController?.pushViewController(nextViewController, animated: true)
        
    }
    
    //
    // MARK: Variables
    //
    let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
    
    var userId: String!
    
    var actionResponse: JSON?
    var actions: NSMutableArray = NSMutableArray()
    var page: Int = 1
    
    var likeDelay: NSTimer = NSTimer()
    var unlikeDelay: NSTimer = NSTimer()
    
    //
    // MARK: UIKit Overrides
    //
    override func viewWillAppear(animated: Bool) {
        
        super.viewWillAppear(true)
        
        self.navigationController?.navigationBarHidden = false
        
        //
        // We need to execute the necessary code here to make
        // sure the Report Single view displays from the map view
        // and other views
        //
        self.tableView.rowHeight = UITableViewAutomaticDimension;
        self.tableView.estimatedRowHeight = 600.0;
//        self.tableView.backgroundColor = UIColor.whiteColor()
        self.tableView.backgroundColor = UIColor(
            red: 245.0/255.0,
            green: 247.0/255.0,
            blue: 249.0/255.0,
            alpha: 1.0
        )
        self.tableView.scrollsToTop = true
        
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
        
        self.loading()
        
        if (self.refreshControl == nil) {
            self.refreshControl = UIRefreshControl()
        }
        
        self.actions = []
        self.page = 1
        self.tableView.reloadData()
        
        //
        // Set the Navigation Bar title
        //
//        self.navigationItem.title = "Activity"
//        self.navigationItem.titleView = titleImageView
        
//        self.navigationItem.setHidesBackButton(true, animated:true);
        
        //
        // Setup pull to refresh functionality for our TableView
        //
        self.refreshControl?.addTarget(self, action: #selector(UserActionsTableViewController.refreshTableView(_:)), forControlEvents: UIControlEvents.ValueChanged)
        
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
    
    func loading() {
        
        //
        // Create a view that covers the entire screen
        //
        self.loadingIndicatorView.frame = CGRectMake(0, 0, self.view.frame.width, self.view.frame.height)
        self.loadingIndicatorView.backgroundColor = UIColor.whiteColor()
        
        self.view.addSubview(self.loadingIndicatorView)
        self.view.bringSubviewToFront(self.loadingIndicatorView)
        
//        self.tableView.separatorStyle = UITableViewCellSeparatorStyle.None
        
    }
    
    func loadingComplete() {
        
        //
        // Remove loading screen
        //
        self.loadingIndicatorView.removeFromSuperview()
        
    }
    
    func refreshTableView(refreshControl: UIRefreshControl) {
        
        //
        // Load 10 newest reports from API on Activity View load
        //
            
        self.page = 1
        self.actions.removeAllObjects()
        
        self.attemptLoadUserActions(true)
        
    }
    
    func userHasCommentedOnReport(_report: JSON, _current_user_id: Int) -> Bool {
        
        if (_report["comments"].count != 0) {
            for _comment in _report["comments"] {
                if (_comment.1["properties"]["owner_id"].intValue == _current_user_id) {
                    return true
                }
            }
        }
        
        return false
        
    }
    
    func openDirectionsURL(postId: Int) {
        
        //        let reportId = sender.tag
        let report = self.actions[postId]
        
        let reportGeometry = report.objectForKey("geometry")
        let reportGeometries = reportGeometry!.objectForKey("geometries")
        let reportCoordinates = reportGeometries![0].objectForKey("coordinates") as! Array<Double>
        
        UIApplication.sharedApplication().openURL(NSURL(string: "https://www.google.com/maps/dir//" + String(reportCoordinates[1]) + "," + String(reportCoordinates[0]))!)
    }
    
    func openOpenGraphURL(sender: AnyObject) {
        
        let reportId = sender.tag
        
        //        print("The value of `sender` is \(sender)")
        //
        //        print("The value of `sender` > `view` is \(sender.view)")
        
        let report = JSON(self.actions[reportId])
        
        let reportURL = "\(report["properties"]["social"][0]["properties"]["og_url"])"
        
        print("openOpenGraphURL \(reportURL)")
        
        UIApplication.sharedApplication().openURL(NSURL(string: "\(reportURL)")!)
    }
    
    func displayUserProfileInformation(withoutReportReload: Bool = false) {
        
        print("displayUserProfileInformation")
        
        print("User profile value is: \(self.userId)")
        
        //
        // Load and display other user information
        //
        
        self.attemptLoadUserActions(true)
        
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
    // Fetch user actions
    //
    
    func attemptLoadUserActions(isRefreshingReportsList: Bool = false) {
        
        // Load the user profile groups
        //
//        let _headers = buildRequestHeaders()

        let _parameters = [
            "q": "{\"filters\":[{\"or\":[{\"and\":[{\"name\":\"owner_id\", \"op\":\"eq\", \"val\":\"\(self.userId!)\"},{\"name\":\"state\", \"op\":\"eq\", \"val\":\"closed\"}]},{\"name\":\"closed_id\", \"op\":\"eq\", \"val\":\"\(self.userId!)\"}]}],\"order_by\": [{\"field\":\"created\",\"direction\":\"desc\"}]}",
            "page": "\(self.page)"
        ]
        
        Alamofire.request(.GET, Endpoints.GET_MANY_REPORTS, parameters: _parameters)
            .responseJSON { response in
                
                switch response.result {
                case .Success(let value):
                    //                            print("Request Success \(Endpoints.GET_MANY_REPORTS) \(value)")
                    
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
                            // Assign response to groups variable
                            self.actionResponse = JSON(value)
//                            self.actions = value["features"] as! [AnyObject]
                            self.actions = (value["features"] as! NSArray).mutableCopy() as! NSMutableArray
//                            self.actionRefreshControl.endRefreshing()
                            self.refreshControl?.endRefreshing()
                        } else {
                            
                            if let features = value["features"] {
                                if features != nil {
//                                    self.actionResponse = JSON(value)
//                                    self.actions += features as! [AnyObject]
                                    self.actions.addObjectsFromArray(features as! NSArray as [AnyObject])
                                }
                            }
                            
                        }
                        
                        //
                        // Dismiss the loading indicator
                        //
                        self.loadingComplete()
                        
                        // Refresh the data in the table so the newest items appear
                        self.tableView.reloadData()
                        
                        self.page += 1
                    }
                    
                    break
                case .Failure(let error):
                    print("Request Failure: \(error)")
                    
                    // Stop showing the loading indicator
                    //self.status("doneLoadingWithError")
                    //
                    // Dismiss the loading indicator
                    //
                    self.loadingComplete()
                    
                    break
                }
                
        }
        
    }
    
    //
    // PROTOCOL REQUIREMENT: UITableViewDelegate
    //
    
//    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
//        return 600.0
//    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        var _count: Int = 0
        
        if (self.actions.count >= 1) {
            _count = self.actions.count
        }
        
        return _count
        
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("basePostTableCell", forIndexPath: indexPath) as! BasePostTableCell
        
        //
        // Make sure we aren't loading old images into the new cells as
        // additional reports are loaded
        //
        if (self.actions.count >= 1) {
            
            //
            // User Id
            //
            
            var _user_id_integer: Int = 0
            
            if let _user_id_number = NSUserDefaults.standardUserDefaults().objectForKey("currentUserAccountUID") as? NSNumber {
                _user_id_integer = _user_id_number.integerValue
            }
            
            //
            // REPORT OBJECT
            //
            let report = self.actions[indexPath.row].objectForKey("properties")
            let reportJson = JSON(report!)
            cell.reportObject = report
            
            let reportDescription = report?.objectForKey("report_description")
            //        let reportClosed = report?.objectForKey("closed_by")
            
            let reportOwner = report?.objectForKey("owner")?.objectForKey("properties")
            
            //
            // Extra actions
            //
            
            cell.extraActionsButton.tag = indexPath.row
            cell.extraActionsButton.addTarget(self, action: #selector(ActivityTableViewController.presentExtraPostActions(_:)), forControlEvents: .TouchUpInside)
            
            //
            // Territory
            //
            let reportTerritory = report?.objectForKey("territory") as? NSDictionary
            
            var reportTerritoryName: String? = "Unknown Watershed"
            if let thisReportTerritory = reportTerritory?.objectForKey("properties")?.objectForKey("huc_8_name") as? String {
                reportTerritoryName = (thisReportTerritory) + " Watershed"
                
                //                cell.reportTerritoryName.tag = indexPath.row
                //                cell.reportTerritoryName.userInteractionEnabled = true
                //                let tapGesture = UITapGestureRecognizer(target: self, action: #selector(ActivityTableViewController.loadTerritoryProfile(_:)))
                //                cell.reportTerritoryName.addGestureRecognizer(tapGesture)
                
            }
            
            let dropletIcon: UIImage = UIImage(named: "icon--droplet")!
            cell.dropletIcon.image = dropletIcon
            
            cell.reportTerritoryName.text = reportTerritoryName
            
            cell.reportTerritoryButton.tag = indexPath.row
            cell.reportTerritoryButton.addTarget(self, action: #selector(ActivityTableViewController.loadTerritoryProfile(_:)), forControlEvents: .TouchUpInside)
            
            //
            // Comment Count
            //
            let reportComments = report?.objectForKey("comments") as! NSArray
            
            var reportCommentsCountText: String = ""
            
            if reportComments.count >= 1 {
                reportCommentsCountText = String(reportComments.count)
                cell.reportCommentButton.alpha = 1
                cell.reportCommentCount.hidden = false
            }
            else {
                cell.reportCommentButton.alpha = 0.4
                cell.reportCommentCount.hidden = true
            }
            
            cell.reportCommentCount.setTitle(reportCommentsCountText, forState: UIControlState.Normal)
            
            cell.reportCommentCount.tag = indexPath.row
            cell.reportCommentButton.tag = indexPath.row
            
            //
            // MARK: Determine comment status
            
            if _user_id_integer != 0 {
                
                print("Setup the comment stuff")
                
                let _hasCommented = self.userHasCommentedOnReport(reportJson, _current_user_id: _user_id_integer)
                
                if (reportJson["closed_by"] != nil) {
                    let badgeImage: UIImage = UIImage(named: "icon--Badge")!
                    cell.reportCommentButton.setImage(badgeImage, forState: .Normal)
                    
                }
                else {
                    cell.reportCommentButton.setImage(UIImage(named: "icon--comment"), forState: .Normal)
                }
                
                //                cell.reportCommentButton.setImage(UIImage(named: "icon--Comment"), forState: .Normal)
                
                if (_hasCommented) {
                    cell.reportCommentButton.setImage(UIImage(named: "icon--comment_blue"), forState: .Normal)
                    cell.reportCommentCount.setTitleColor(UIColor(
                        red: 6.0/255.0,
                        green: 170.0/255.0,
                        blue: 240.0/255.0,
                        alpha: 1.0
                        ), forState: .Normal)
                }
                else {
                    cell.reportCommentCount.setTitleColor(UIColor(
                        red: 0.0/255.0,
                        green: 0.0/255.0,
                        blue: 0.0/255.0,
                        alpha: 0.5
                        ), forState: .Normal)
                }
                
                //                if (reportJson["closed_by"] != nil) {
                //                    let badgeImage: UIImage = UIImage(named: "icon--Badge")!
                //                    cell.reportCommentButton.setImage(badgeImage, forState: .Normal)
                //
                //                }
                
            }
            
            //            if (reportJson["closed_by"] != nil) {
            //                let badgeImage: UIImage = UIImage(named: "icon--Badge")!
            //                cell.reportCommentButton.setImage(badgeImage, forState: .Normal)
            //
            //            }
            
            //            if (reportJson["closed_by"] != nil) {
            //                let badgeImage: UIImage = UIImage(named: "icon--Badge")!
            //                cell.reportCommentButton.setImage(badgeImage, forState: .Normal)
            //
            //            } else {
            //                let badgeImage: UIImage = UIImage(named: "icon--comment")!
            //                cell.reportCommentButton.setImage(badgeImage, forState: .Normal)
            //            }
            
            // Likes Count
            //
            let reportLikes = report?.objectForKey("likes") as! NSArray
            
            var reportLikesCountText: String = ""
            
            if reportLikes.count >= 1 {
                reportLikesCountText = String(reportLikes.count)
                cell.reportLikeButton.alpha = 1
                cell.reportLikeCount.hidden = false
            }
            else {
                cell.reportLikeButton.alpha = 0.4
                cell.reportLikeCount.hidden = true
            }
            
            cell.reportLikeCount.tag = indexPath.row
            cell.reportLikeCount.setTitle(reportLikesCountText, forState: UIControlState.Normal)
            
            // Report Like Button
            //
            cell.reportLikeButton.tag = indexPath.row
            
            print("_user_id_integer \(_user_id_integer)")
            
            if _user_id_integer != 0 {
                
                print("Setup the like stuff")
                
                let _hasLiked = self.userHasLikedReport(reportJson, _current_user_id: _user_id_integer)
                
                cell.reportLikeButton.setImage(UIImage(named: "icon--heart"), forState: .Normal)
                
                if (_hasLiked) {
                    cell.reportLikeButton.removeTarget(nil, action: nil, forControlEvents: .AllEvents)
                    cell.reportLikeButton.addTarget(self, action: #selector(unlikeCurrentReport(_:)), forControlEvents: .TouchUpInside)
                    cell.reportLikeButton.setImage(UIImage(named: "icon--heartred"), forState: .Normal)
                    cell.reportLikeCount.setTitleColor(UIColor(
                        red: 240.0/255.0,
                        green: 6.0/255.0,
                        blue: 53.0/255.0,
                        alpha: 1.0
                        ), forState: .Normal)
                }
                else {
                    cell.reportLikeButton.removeTarget(nil, action: nil, forControlEvents: .AllEvents)
                    cell.reportLikeButton.addTarget(self, action: #selector(likeCurrentReport(_:)), forControlEvents: .TouchUpInside)
                    cell.reportLikeCount.setTitleColor(UIColor(
                        red: 0.0/255.0,
                        green: 0.0/255.0,
                        blue: 0.0/255.0,
                        alpha: 0.5
                        ), forState: .Normal)
                }
                
            }
            
            //
            // Set state of post Open Graph component
            //
            
            if reportJson["social"] != nil && reportJson["social"].count != 0 {
                cell.reportOpenGraphStoryLink.hidden = false
                cell.reportOpenGraphStoryLink.tag = indexPath.row
                cell.reportOpenGraphStoryLink.addTarget(self, action: #selector(openOpenGraphURL(_:)), forControlEvents: .TouchUpInside)
                
            }
            else {
                cell.reportOpenGraphStoryLink.hidden = true
            }
            
            //
            // GROUPS
            //
            let reportGroups = report?.objectForKey("groups") as? NSArray
            
            cell.postGroupOne.subviews.forEach({ $0.removeFromSuperview() })
            cell.postGroupTwo.subviews.forEach({ $0.removeFromSuperview() })
            cell.postGroupThree.subviews.forEach({ $0.removeFromSuperview() })
            cell.postGroupFour.subviews.forEach({ $0.removeFromSuperview() })
            cell.postGroupFive.subviews.forEach({ $0.removeFromSuperview() })
            
            cell.postGroupOne.removeTarget(nil, action: nil, forControlEvents: .AllEvents)
            cell.postGroupTwo.removeTarget(nil, action: nil, forControlEvents: .AllEvents)
            cell.postGroupThree.removeTarget(nil, action: nil, forControlEvents: .AllEvents)
            cell.postGroupFour.removeTarget(nil, action: nil, forControlEvents: .AllEvents)
            cell.postGroupFive.removeTarget(nil, action: nil, forControlEvents: .AllEvents)
            
            cell.postGroupOne.setTitle(nil, forState: .Normal)
            cell.postGroupTwo.setTitle(nil, forState: .Normal)
            cell.postGroupThree.setTitle(nil, forState: .Normal)
            cell.postGroupFour.setTitle(nil, forState: .Normal)
            cell.postGroupFive.setTitle(nil, forState: .Normal)
            
            //            cell.postGroupOne.hidden = true
            //            cell.postGroupTwo.hidden = true
            //            cell.postGroupThree.hidden = true
            //            cell.postGroupFour.hidden = true
            //            cell.postGroupFive.hidden = true
            
            if reportGroups?.count > 0 {
                cell.reportGroupStack.hidden = false
            }
            else {
                cell.reportGroupStack.hidden = true
            }
            
            //
            // Clear subviews from group stack view
            //
            
            //            cell.reportGroupStack.subviews.forEach({ $0.removeFromSuperview() })
            
            //            cell.reportGroupStack.frame.size.width = CGFloat(44 * (reportGroups?.count)!)
            
            //            let groupStackWidth:CGFloat = CGFloat(44 * (reportGroups?.count)!)
            //
            //            print("Group stack width \(groupStackWidth)")
            
            //            cell.reportGroupStack.widthAnchor.constraintEqualToConstant(groupStackWidth).active = true
            
            //            cell.reportGroupStackLimiter.frame = CGRect(x: 0, y: 0, width: groupStackWidth, height: 1)
            //
            //            cell.reportGroupStack.frame = CGRect(x: 0, y: 0, width: groupStackWidth, height: 40)
            //
            //            cell.reportGroupStackLimiter.widthAnchor.constraintEqualToConstant(groupStackWidth).active = true
            
            //            cell.reportGroupStackLimiter.frame.width = groupStackWidth
            
            //            cell.reportGroupStack.addConstraint(NSLayoutConstraint(item: cell.reportGroupStackLimiter, attribute: .Trailing, relatedBy: .Equal, toItem: cell.reportGroupStack, attribute: .Trailing, multiplier: 1, constant: 0))
            
            //            for _group in reportGroups! as NSArray {
            for (index, _group) in reportGroups!.enumerate() {
                
                if let groupLogoUrl = _group.objectForKey("properties")!.objectForKey("picture") as? String,
                    let groupName = _group.objectForKey("properties")!.objectForKey("name") as? String{
                    
                    let imageURL:NSURL = NSURL(string: "\(groupLogoUrl)")!
                    
                    print("Group logo URL \(imageURL)")
                    
                    let imageView = UIImageView()
                    
                    //                    let groupBtn = UIButton()
                    
                    imageView.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
                    
                    //                    imageView.contentMode = .ScaleAspectFit
                    
                    imageView.heightAnchor.constraintEqualToConstant(40.0).active = true
                    imageView.widthAnchor.constraintEqualToConstant(40.0).active = true
                    
                    imageView.setContentHuggingPriority(UILayoutPriorityRequired, forAxis: .Horizontal)
                    imageView.setContentCompressionResistancePriority(UILayoutPriorityRequired, forAxis: .Horizontal)
                    
                    //                    .setContentHuggingPriority(UILayoutPriorityDefaultHigh, for: UILayoutConstraintAxis.horizontal)
                    
                    //                    imageView.layer.cornerRadius = imageView.frame.size.width / 2
                    //                    imageView.clipsToBounds = true
                    //
                    //                    cell.reportOpenGraphImage.kf_indicatorType = .Activity
                    //                    cell.reportOpenGraphImage.kf_showIndicatorWhenLoading = true
                    
                    imageView.kf_setImageWithURL(imageURL, placeholderImage: nil, optionsInfo: nil, progressBlock: nil, completionHandler: {
                        (image, error, cacheType, imageUrl) in
                        
                        //                        imageView.image = image
                        
                        if (image != nil) {
                            imageView.image = UIImage(CGImage: (image?.CGImage)!, scale: (image?.scale)!, orientation: UIImageOrientation.Up)
                            imageView.layer.cornerRadius = imageView.frame.size.width / 2
                            //                            imageView.layer.cornerRadius = 20
                            imageView.clipsToBounds = true
                        }
                        
                    })
                    
                    //                    let groupBtn = UIButton()
                    
                    //                    let _groupName = _group["properties"]!!["name"] as? String
                    
                    //                    groupBtn.tag = indexPath.row
                    //                    groupBtn.setTitle(groupName, forState: .Normal)
                    //                    groupBtn.setTitleColor(UIColor(
                    //                        red: 240.0/255.0,
                    //                        green: 6.0/255.0,
                    //                        blue: 53.0/255.0,
                    //                        alpha: 0.0
                    //                        ), forState: .Normal)
                    //                    groupBtn.addTarget(self, action: #selector(ActivityTableViewController.loadGroupProfile(_:)), forControlEvents: .TouchUpInside)
                    
                    //                    groupBtn.addSubview(imageView)
                    
                    //                    groupBtn.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
                    
                    //                    cell.reportGroupStack.addArrangedSubview(groupBtn)
                    
                    switch (index) {
                        
                    case 0:
                        cell.postGroupOne.tag = indexPath.row
                        cell.postGroupOne.setTitle(groupName, forState: .Normal)
                        cell.postGroupOne.setTitleColor(UIColor(
                            red: 240.0/255.0,
                            green: 6.0/255.0,
                            blue: 53.0/255.0,
                            alpha: 0.0
                            ), forState: .Normal)
                        cell.postGroupOne.addTarget(self, action: #selector(ActivityTableViewController.loadGroupProfile(_:)), forControlEvents: .TouchUpInside)
                        cell.postGroupOne.layer.cornerRadius = cell.postGroupOne.frame.size.width / 2
                        cell.postGroupOne.clipsToBounds = true
                        cell.postGroupOne.addSubview(imageView)
                        
                    case 1:
                        cell.postGroupTwo.tag = indexPath.row
                        cell.postGroupTwo.setTitle(groupName, forState: .Normal)
                        cell.postGroupTwo.setTitleColor(UIColor(
                            red: 240.0/255.0,
                            green: 6.0/255.0,
                            blue: 53.0/255.0,
                            alpha: 0.0
                            ), forState: .Normal)
                        cell.postGroupTwo.addTarget(self, action: #selector(ActivityTableViewController.loadGroupProfile(_:)), forControlEvents: .TouchUpInside)
                        cell.postGroupTwo.layer.cornerRadius = cell.postGroupTwo.frame.size.width / 2
                        cell.postGroupTwo.clipsToBounds = true
                        cell.postGroupTwo.addSubview(imageView)
                        
                    case 2:
                        cell.postGroupThree.tag = indexPath.row
                        cell.postGroupThree.setTitle(groupName, forState: .Normal)
                        cell.postGroupThree.setTitleColor(UIColor(
                            red: 240.0/255.0,
                            green: 6.0/255.0,
                            blue: 53.0/255.0,
                            alpha: 0.0
                            ), forState: .Normal)
                        cell.postGroupThree.addTarget(self, action: #selector(ActivityTableViewController.loadGroupProfile(_:)), forControlEvents: .TouchUpInside)
                        cell.postGroupThree.layer.cornerRadius = cell.postGroupThree.frame.size.width / 2
                        cell.postGroupThree.clipsToBounds = true
                        cell.postGroupThree.addSubview(imageView)
                        
                    case 3:
                        cell.postGroupFour.tag = indexPath.row
                        cell.postGroupFour.setTitle(groupName, forState: .Normal)
                        cell.postGroupFour.setTitleColor(UIColor(
                            red: 240.0/255.0,
                            green: 6.0/255.0,
                            blue: 53.0/255.0,
                            alpha: 0.0
                            ), forState: .Normal)
                        cell.postGroupFour.addTarget(self, action: #selector(ActivityTableViewController.loadGroupProfile(_:)), forControlEvents: .TouchUpInside)
                        cell.postGroupFour.layer.cornerRadius = cell.postGroupFour.frame.size.width / 2
                        cell.postGroupFour.clipsToBounds = true
                        cell.postGroupFour.addSubview(imageView)
                        
                    case 4:
                        cell.postGroupFive.tag = indexPath.row
                        cell.postGroupFive.setTitle(groupName, forState: .Normal)
                        cell.postGroupFive.setTitleColor(UIColor(
                            red: 240.0/255.0,
                            green: 6.0/255.0,
                            blue: 53.0/255.0,
                            alpha: 0.0
                            ), forState: .Normal)
                        cell.postGroupFive.addTarget(self, action: #selector(ActivityTableViewController.loadGroupProfile(_:)), forControlEvents: .TouchUpInside)
                        cell.postGroupFive.layer.cornerRadius = cell.postGroupFive.frame.size.width / 2
                        cell.postGroupFive.clipsToBounds = true
                        cell.postGroupFive.addSubview(imageView)
                        
                    default:
                        print(index)
                        
                    }
                    
                }
                
            }
            
            //
            // USER NAME
            //
            if let firstName = reportOwner?.objectForKey("first_name"),
                let lastName = reportOwner?.objectForKey("last_name") {
                
                cell.reportUserName.text = (firstName as! String) + " " + (lastName as! String)
                
                cell.reportUserName.tag = indexPath.row
                
            } else {
                cell.reportUserName.text = "Unknown Reporter"
            }
            
            if "\(reportDescription!)" != "null" || "\(reportDescription!)" != "" {
                cell.reportDescription.text = "\(reportDescription!)"
                cell.reportDescription.enabledTypes = [.Hashtag, .URL]
                cell.reportDescription.hashtagColor = UIColor.colorBrand()
                cell.reportDescription.hashtagSelectedColor = UIColor.colorDarkGray()
                
                cell.reportDescription.handleHashtagTap { hashtag in
                    print("Success. You just tapped the \(hashtag) hashtag")
                    
                    let nextViewController = self.storyBoard.instantiateViewControllerWithIdentifier("HashtagTableViewController") as! HashtagTableViewController
                    
                    nextViewController.hashtag = hashtag
                    
                    self.navigationController?.pushViewController(nextViewController, animated: true)
                    
                }
                
                cell.reportDescription.handleURLTap { url in
                    print("Success. You just tapped the \(url) url")
                    
                    UIApplication.sharedApplication().openURL(NSURL(string: "\(url)")!)
                }
                
            }
            else {
                cell.reportDescription.text = ""
            }
            
            //
            // REPORT > OWNER > PICTURE
            //
            cell.reportOwnerImageButton.tag = indexPath.row
            cell.reportOwnerImageButton.addTarget(self, action: #selector(ActivityTableViewController.loadCommentOwnerProfile(_:)), forControlEvents: .TouchUpInside)
            
            var reportOwnerImageURL:NSURL! = NSURL(string: "https://www.waterreporter.org/community/images/badget--MissingUser.png")
            
            if let thisReportOwnerImageURL = reportOwner?.objectForKey("picture") {
                reportOwnerImageURL = NSURL(string: String(thisReportOwnerImageURL))
            }
            
            cell.reportOwnerImage.kf_indicatorType = .Activity
            cell.reportOwnerImage.kf_showIndicatorWhenLoading = true
            
            cell.reportOwnerImage.kf_setImageWithURL(reportOwnerImageURL, placeholderImage: nil, optionsInfo: nil, progressBlock: nil, completionHandler: {
                (image, error, cacheType, imageUrl) in
                if (image != nil) {
                    cell.reportOwnerImage.image = UIImage(CGImage: (image?.CGImage)!, scale: (image?.scale)!, orientation: UIImageOrientation.Up)
                }
                cell.reportOwnerImage.layer.cornerRadius = cell.reportOwnerImage.frame.size.width / 2
                cell.reportOwnerImage.clipsToBounds = true
            })
            
            //
            // REPORT > IMAGE
            //
            let reportImages = report?.objectForKey("images")!
            let reportSocial = report?.objectForKey("social")!
            
            if ((reportImages != nil && reportImages!.count != 0) && (reportSocial == nil || reportSocial!.count == 0)) {
                print("Show report image \(reportImages)")
                
                var reportImageURL:NSURL!
                
                if let thisReportImageURL = reportImages![0]?.objectForKey("properties")!.objectForKey("square") {
                    reportImageURL = NSURL(string: String(thisReportImageURL))
                }
                
                cell.reportImage.kf_indicatorType = .Activity
                cell.reportImage.kf_showIndicatorWhenLoading = true
                
                cell.reportImage.kf_setImageWithURL(reportImageURL, placeholderImage: nil, optionsInfo: nil, progressBlock: nil, completionHandler: {
                    (image, error, cacheType, imageUrl) in
                    
                    if (image != nil) {
                        cell.reportImage.image = Image(CGImage: (image?.CGImage)!, scale: (image?.scale)!, orientation: UIImageOrientation.Up)
                    }
                })
                
                cell.reportImage.hidden = false
                
            }
            else {
                print("No image to show")
                cell.reportImage.hidden = true
                cell.reportImage.image = nil
            }
            
            //
            // Report > Open Graph
            //
            
            cell.reportOpenGraphViewGroup.layer.cornerRadius = 6
            
            if (reportSocial != nil && reportSocial!.count != 0) {
                
                cell.reportOpenGraphViewGroup.hidden = false
                
                //                let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(openOpenGraphURL(_:)))
                //
                //                cell.reportOpenGraphViewGroup.userInteractionEnabled = true
                //                cell.reportOpenGraphViewGroup.tag = indexPath.row
                //                cell.reportOpenGraphViewGroup.addGestureRecognizer(tapGestureRecognizer)
                
                //                cell.reportOpenGraphStoryLink.addTarget(self, action: #selector(openOpenGraphURL(_:)), forControlEvents: .TouchUpInside)
                
                //                cell.reportOpenGraphViewGroup.addTarget(self, action: #selector(openOpenGraphURL(_:)), forControlEvents: .TouchUpInside)
                
                // Open Graph Data
                
                if let openGraphTitle = reportSocial![0]?.objectForKey("properties")!.objectForKey("og_title"),
                    let openGraphDescription = reportSocial![0]?.objectForKey("properties")!.objectForKey("og_description") {
                    
                    //
                    // Open Graph > Title
                    //
                    cell.reportOpenGraphTitle.text = (openGraphTitle as! String)
                    
                    //
                    // Open Graph > Title
                    //
                    cell.reportOpenGraphDescription.text = (openGraphDescription as! String)
                    
                }
                
                // Open Graph > Image
                //
                
                if let openGraphImageUrl = reportSocial![0]?.objectForKey("properties")!.objectForKey("og_image_url") {
                    
                    print("Open Graph image available \(openGraphImageUrl)")
                    
                    let ogImageURL:NSURL = NSURL(string: "\(openGraphImageUrl)")!
                    
                    cell.reportOpenGraphImage.kf_indicatorType = .Activity
                    cell.reportOpenGraphImage.kf_showIndicatorWhenLoading = true
                    
                    cell.reportOpenGraphImage.kf_setImageWithURL(ogImageURL, placeholderImage: nil, optionsInfo: nil, progressBlock: nil, completionHandler: {
                        (image, error, cacheType, imageUrl) in
                        
                        cell.reportOpenGraphImage.image = image
                        
                    })
                    
                }
                else {
                    
                    print("No open graph image")
                    
                    cell.reportOpenGraphImage.image = UIImage(named: "og-placeholder_1024x1024_720")
                    
                }
                
            }
            else {
                
                print("No open graph object")
                
                cell.reportOpenGraphViewGroup.hidden = true
                
                cell.reportOpenGraphImage.image = nil
                
            }
            
            //
            // DATE
            //
            let reportDate = reportJson["created"].string
            
            print("The post timestamp is \(reportDate)")
            
            if (reportDate != nil) {
                
                let dateString: String = reportDate!
                
                print("The value of dateString is \(dateString)")
                
                let dateFormatter = NSDateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSS"
                
                let stringToFormat = dateFormatter.dateFromString(dateString)
                
                print("The post date object is \(stringToFormat)")
                
                dateFormatter.dateFormat = "MMM d, yyyy 'at' h:mm a"
                
                let displayDate = dateFormatter.stringFromDate(stringToFormat!)
                
                if let thisDisplayDate: String? = displayDate {
                    cell.reportDate.text = thisDisplayDate
                }
            }
            else {
                cell.reportDate.text = ""
            }
            //
            // PASS ON DATA TO TABLE CELL
            //
            cell.reportGetDirectionsButton.tag = indexPath.row
            
            cell.reportDirectionsButton.tag = indexPath.row
            cell.reportDirectionsButton.addTarget(self, action: #selector(openDirectionsURL(_:)), forControlEvents: .TouchUpInside)
            
            cell.reportShareButton.tag = indexPath.row
            
            //
            // CONTINUOUS SCROLL
            //
            if (indexPath.row == self.actions.count - 5) {
                self.attemptLoadUserActions()
            }
            
        }
        
        return cell
        
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        print("row tapped \(indexPath)")
    }
    
    //
    // MARK: Like Functionality
    //
    func userHasLikedReport(_report: JSON, _current_user_id: Int) -> Bool {
        
        if (_report["likes"].count != 0) {
            for _like in _report["likes"] {
                if (_like.1["properties"]["owner_id"].intValue == _current_user_id) {
                    return true
                }
            }
        }
        
        return false
    }
    
    func updateReportLikeCount(indexPathRow: Int, addLike: Bool = true) {
        
        print("LikeController::updateReportLikeCount")
        
        let _indexPath = NSIndexPath(forRow: indexPathRow, inSection: 0)
        
        var _report: JSON!
        
        let _cell = self.tableView.cellForRowAtIndexPath(_indexPath) as! UserProfileActionsTableViewCell
        _report = JSON(self.actions[(indexPathRow)].objectForKey("properties")!)
        
        // Change the Heart icon to red
        //
        if (addLike) {
            _cell.buttonReportLike.setImage(UIImage(named: "icon--heartred"), forState: .Normal)
            _cell.buttonReportLike.removeTarget(nil, action: nil, forControlEvents: .AllEvents)
            _cell.buttonReportLike.addTarget(self, action: #selector(unlikeCurrentReport(_:)), forControlEvents: .TouchUpInside)
        } else {
            _cell.buttonReportLike.setImage(UIImage(named: "icon--heart"), forState: .Normal)
            _cell.buttonReportLike.removeTarget(nil, action: nil, forControlEvents: .AllEvents)
            _cell.buttonReportLike.addTarget(self, action: #selector(likeCurrentReport(_:)), forControlEvents: .TouchUpInside)
        }
        
        // Update the total likes count
        //
        let _report_likes_count: Int = _report["likes"].count
        
        // Check if we have previously liked this photo. If so, we need to take
        // that into account when adding a new like.
        //
        let _previously_liked: Bool = self.hasPreviouslyLike(_report["likes"])
        
        var _report_likes_updated_total: Int! = _report_likes_count
        
        if (addLike) {
            if (_previously_liked) {
                _report_likes_updated_total = _report_likes_count
            }
            else {
                _report_likes_updated_total = _report_likes_count+1
            }
        }
        else {
            if (_previously_liked) {
                _report_likes_updated_total = _report_likes_count-1
            }
            else {
                _report_likes_updated_total = _report_likes_count
            }
        }
        
        var reportLikesCountText: String = ""
        
        if _report_likes_updated_total == 1 {
            reportLikesCountText = "1 like"
            _cell.buttonReportLikeCount.hidden = false
        }
        else if _report_likes_updated_total >= 1 {
            reportLikesCountText = "\(_report_likes_updated_total) likes"
            _cell.buttonReportLikeCount.hidden = false
        }
        else {
            reportLikesCountText = "0 likes"
            _cell.buttonReportLikeCount.hidden = false
        }
        
        _cell.buttonReportLikeCount.setTitle(reportLikesCountText, forState: .Normal)
        
    }
    
    func hasPreviouslyLike(likes: JSON) -> Bool {
        
        print("hasPreviouslyLike::likes \(likes)")
        
        // LOOP OVER PREVIOUS LIKES AND SEE IF CURRENT USER ID IS ONE OF THE OWNER IDS
        
        let _user_id_number = NSUserDefaults.standardUserDefaults().objectForKey("currentUserAccountUID") as! NSNumber
        
        for _like in likes {
            if (_like.1["properties"]["owner_id"].intValue == _user_id_number.integerValue) {
                print("_like.1 \(_like.1)")
                return true
            }
        }
        
        return false
    }
    
    func likeCurrentReport(sender: UIButton) {
        
        print("LikeController::likeCurrentReport Incrementing Report Likes by 1")
        
        // Update the visible "# like" count of likes
        //
        self.updateReportLikeCount(sender.tag)
        
        // Restart delay
        //
        self.likeDelay.invalidate()
        
        let infoDict : [String : AnyObject] = ["sender": sender.tag]
        
        self.likeDelay = NSTimer.scheduledTimerWithTimeInterval(NSTimeInterval(1), target: self, selector: #selector(self.attemptLikeCurrentReport(_:)), userInfo: infoDict, repeats: false)
        
    }
    
    func attemptLikeCurrentReport(timer: NSTimer) {
        print("userInfo \(timer.userInfo!)")
        
        let _arguments = timer.userInfo as! [String : AnyObject]
        
        if let _sender_tag = _arguments["sender"] {
            
            let senderTag = _sender_tag.integerValue
            
            print("_sender_tag \(senderTag)")
            
            // Create necessary Authorization header for our request
            //
            let accessToken = NSUserDefaults.standardUserDefaults().objectForKey("currentUserAccountAccessToken")
            let _headers = [
                "Authorization": "Bearer " + (accessToken! as! String)
            ]
            
            //
            // PARAMETERS
            //
            var _report: JSON!
            
            _report = JSON(self.actions[(senderTag)])
            
            let _report_id: String = "\(_report["id"])"
            
            let _parameters: [String:AnyObject] = [
                "report_id": _report_id
            ]
            
            Alamofire.request(.POST, Endpoints.POST_LIKE, parameters: _parameters, headers: _headers, encoding: .JSON)
                .responseJSON { response in
                    
                    switch response.result {
                    case .Success(let value):
                        //                        print("Response Success \(value)")
                        self.updateReportLikes(_report_id, reportSenderTag: senderTag)
                        
                        break
                    case .Failure(let error):
                        print("Response Failure \(error)")
                        break
                    }
                    
            }
        }
    }
    
    func unlikeCurrentReport(sender: UIButton) {
        
        print("LikeController::unlikeCurrentReport  Decrementing Report Likes by 1")
        // Update the visible "# like" count of likes
        //
        self.updateReportLikeCount(sender.tag, addLike: false)
        
        // Restart delay
        //
        self.unlikeDelay.invalidate()
        
        let infoDict : [String : AnyObject] = ["sender": sender.tag]
        
        self.unlikeDelay = NSTimer.scheduledTimerWithTimeInterval(NSTimeInterval(1), target: self, selector: #selector(self.attemptUnikeCurrentReport(_:)), userInfo: infoDict, repeats: false)
        
    }
    
    func attemptUnikeCurrentReport(timer: NSTimer) {
        print("userInfo \(timer.userInfo!)")
        
        let _arguments = timer.userInfo as! [String : AnyObject]
        
        if let _sender_tag = _arguments["sender"] {
            
            let senderTag = _sender_tag.integerValue
            
            print("_sender_tag \(senderTag)")
            
            // Create necessary Authorization header for our request
            //
            let accessToken = NSUserDefaults.standardUserDefaults().objectForKey("currentUserAccountAccessToken")
            let _headers = [
                "Authorization": "Bearer " + (accessToken! as! String)
            ]
            
            //
            // PARAMETERS
            //
            var _report: JSON!
            
            _report = JSON(self.actions[(senderTag)])
            
            let _report_id: String = "\(_report["id"])"
            
            let _parameters: [String:AnyObject] = [
                "report_id": _report_id
            ]
            
            //
            // ENDPOINT
            //
            var _like_id: String = ""
            let _user_id_number = NSUserDefaults.standardUserDefaults().objectForKey("currentUserAccountUID") as! NSNumber
            
            if (_report["properties"]["likes"].count != 0) {
                
                for _like in _report["properties"]["likes"] {
                    if (_like.1["properties"]["owner_id"].intValue == _user_id_number.integerValue) {
                        print("_like.1 \(_like.1)")
                        _like_id = "\(_like.1["id"])"
                    }
                }
            }
            
            let _endpoint: String = Endpoints.DELETE_LIKE + "/\(_like_id)"
            
            
            //
            // REQUEST
            //
            Alamofire.request(.DELETE, _endpoint, parameters: _parameters, headers: _headers, encoding: .JSON)
                .responseJSON { response in
                    
                    switch response.result {
                    case .Success(let value):
                        //                        print("Response Success \(value)")
                        
                        self.updateReportLikes(_report_id, reportSenderTag: senderTag)
                        
                        break
                    case .Failure(let error):
                        print("Response Failure \(error)")
                        break
                    }
                    
            }
        }
        
    }
    
    func updateReportLikes(_report_id: String, reportSenderTag: Int) {
        
        // Create necessary Authorization header for our request
        //
        let accessToken = NSUserDefaults.standardUserDefaults().objectForKey("currentUserAccountAccessToken")
        let _headers = [
            "Authorization": "Bearer " + (accessToken! as! String)
        ]
        
        Alamofire.request(.GET, Endpoints.GET_MANY_REPORTS + "/\(_report_id)", headers: _headers, encoding: .JSON)
            .responseJSON { response in
                
                switch response.result {
                case .Success(let value):
                    print("Response value \(value)")
                    
                    self.actions[(reportSenderTag)] = value
                    
                    break
                case .Failure(let error):
                    print("Response Failure \(error)")
                    break
                    
                }
                
        }
        
    }
    
}

