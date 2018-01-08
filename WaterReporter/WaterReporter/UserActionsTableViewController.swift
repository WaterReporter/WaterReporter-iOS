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
    // MARK: @IBActions
    //
    
    @IBAction func openSubmissionOpenGraphURL(sender: UIButton) {
        
        let reportId = sender.tag
        let report = JSON(self.actions[reportId])
        
        let reportURL = "\(report["properties"]["social"][0]["properties"]["og_url"])"
        
        print("openOpenGraphURL \(reportURL)")
        
        UIApplication.sharedApplication().openURL(NSURL(string: "\(reportURL)")!)
        
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
                        } else {
                            
                            if let features = value["features"] {
                                if features != nil {
//                                    self.actionResponse = JSON(value)
//                                    self.actions += features as! [AnyObject]
                                    self.actions.addObjectsFromArray(features as! NSArray as [AnyObject])
                                }
                            }
                            
                        }
                        
                        // Refresh the data in the table so the newest items appear
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
        
        if (self.actions.count >= 1) {
            _count = self.actions.count
        }
        
        return _count
        
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("userProfileSubmissionCell", forIndexPath: indexPath) as! UserProfileSubmissionTableViewCell
        
//        guard (self.userSubmissions != nil) else { return emptyCell }
        
        let _submissions = self.actions
        
        let _thisSubmission = JSON(_submissions[indexPath.row]["properties"])
        
        print("Show (submissions) _thisSubmission \(_thisSubmission)")
        
//        if _thisSubmission == nil {
//            
//            //
//            // If the User Profile being viewed is no the Acting User's Profile
//            // we need to change the empty message sentence to make sense in
//            // this context.
//            //
//            if self.isActingUsersProfile == false {
//                emptyCell.emptyMessageDescription.text = "Looks like this user hasn't submitted any reports."
//                emptyCell.emptyMessageAction.hidden = true
//            }
//            else {
//                emptyCell.emptyMessageDescription.text = "No reports yet, post your first one now!"
//                emptyCell.emptyMessageAction.hidden = false
//                emptyCell.emptyMessageAction.addTarget(self, action: #selector(self.emptyMessageAddReport(_:)), forControlEvents: UIControlEvents.TouchUpInside)
//            }
//            
//            return emptyCell
//        }
        
        // Report > Owner > Image
        //
        if let _report_owner_url = _thisSubmission["owner"]["properties"]["picture"].string {
            
            let reportOwnerProfileImageURL: NSURL! = NSURL(string: _report_owner_url)
            
            cell.imageViewReportOwnerImage.kf_indicatorType = .Activity
            cell.imageViewReportOwnerImage.kf_showIndicatorWhenLoading = true
            
            cell.imageViewReportOwnerImage.kf_setImageWithURL(reportOwnerProfileImageURL, placeholderImage: nil, optionsInfo: nil, progressBlock: nil, completionHandler: {
                (image, error, cacheType, imageUrl) in
                if (image != nil) {
                    cell.imageViewReportOwnerImage.image = UIImage(CGImage: (image?.CGImage)!, scale: (image?.scale)!, orientation: UIImageOrientation.Up)
                }
            })
        }
        else {
            cell.imageViewReportOwnerImage.image = nil
        }
        
        // Report > Owner > Name
        //
        if let _first_name = _thisSubmission["owner"]["properties"]["first_name"].string,
            let _last_name = _thisSubmission["owner"]["properties"]["last_name"].string {
            cell.reportOwnerName.text = "\(_first_name) \(_last_name)"
        } else {
            cell.reportOwnerName.text = "Unknown Reporter"
        }
        
        
        // Report > Territory > Name
        //
        if let _territory_name = _thisSubmission["territory"]["properties"]["huc_8_name"].string {
            cell.reportTerritoryName.text = "\(_territory_name) Watershed"
        }
        else {
            cell.reportTerritoryName.text = "Unknown Watershed"
        }
        
        // Report > Date
        //
        let reportDate = _thisSubmission["report_date"].string
        
        if (reportDate != nil) {
            let dateString: String = reportDate!
            
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
            
            let stringToFormat = dateFormatter.dateFromString(dateString)
            dateFormatter.dateFormat = "MMM d, yyyy"
            
            let displayDate = dateFormatter.stringFromDate(stringToFormat!)
            
            if let thisDisplayDate: String? = displayDate {
                cell.reportDate.text = thisDisplayDate
            }
        }
        else {
            cell.reportDate.text = ""
        }
        
        // Report > Description
        //
        let reportDescription = "\(_thisSubmission["report_description"])"
        
        if "\(reportDescription)" != "null" || "\(reportDescription)" != "" {
            cell.labelReportDescription.text = "\(reportDescription)"
            cell.labelReportDescription.enabledTypes = [.Hashtag, .URL]
            
            
            cell.labelReportDescription.handleHashtagTap { hashtag in
                print("Success. You just tapped the \(hashtag) hashtag")
                
                let nextViewController = self.storyBoard.instantiateViewControllerWithIdentifier("HashtagTableViewController") as! HashtagTableViewController
                
                nextViewController.hashtag = hashtag
                
                self.navigationController?.pushViewController(nextViewController, animated: true)
                
            }
            cell.labelReportDescription.handleURLTap { url in
                print("Success. You just tapped the \(url) url")
                
                UIApplication.sharedApplication().openURL(NSURL(string: "\(url)")!)
            }
        }
        else {
            cell.labelReportDescription.text = ""
        }
        
        
        if _thisSubmission["social"] != nil && _thisSubmission["social"].count != 0 {
            cell.buttonOpenGraphLink.hidden = false
            cell.buttonOpenGraphLink.tag = indexPath.row
            cell.buttonOpenGraphLink.addTarget(self, action: #selector(self.openSubmissionOpenGraphURL(_:)), forControlEvents: .TouchUpInside)
            cell.buttonOpenGraphLink.layer.cornerRadius = 10.0
            cell.buttonOpenGraphLink.clipsToBounds = true
            
            cell.reportDate.hidden = true
            
        }
        else {
            cell.buttonOpenGraphLink.hidden = true
            cell.reportDate.hidden = false
        }
        
        // Report > Groups
        //
        cell.labelReportGroups.text = "Report Group Names"
        
        // Report > Image
        //
        let reportImages = _thisSubmission["images"]
        if (reportImages != nil && reportImages.count != 0) {
            print("Show report image \(reportImages)")
            
            var reportImageURL:NSURL!
            
            if let thisReportImageURL = _thisSubmission["images"][0]["properties"]["square"].string {
                reportImageURL = NSURL(string: String(thisReportImageURL))
            }
            
            cell.reportImageView.kf_indicatorType = .Activity
            cell.reportImageView.kf_showIndicatorWhenLoading = true
            
            cell.reportImageView.kf_setImageWithURL(reportImageURL, placeholderImage: nil, optionsInfo: nil, progressBlock: nil, completionHandler: {
                (image, error, cacheType, imageUrl) in
                
                if (image != nil) {
                    cell.reportImageView.image = UIImage(CGImage: (image?.CGImage)!, scale: (image?.scale)!, orientation: UIImageOrientation.Up)
                }
            })
            
        }
        else if (_thisSubmission["social"] != nil && _thisSubmission["social"].count != 0) {
            print("Show open graph image \(_thisSubmission["social"])")
            
            if let reportImageURL = NSURL(string: String(_thisSubmission["social"][0]["properties"]["og_image_url"])) {
                
                cell.reportImageView.kf_indicatorType = .Activity
                cell.reportImageView.kf_showIndicatorWhenLoading = true
                
                cell.reportImageView.kf_setImageWithURL(reportImageURL, placeholderImage: nil, optionsInfo: nil, progressBlock: nil, completionHandler: {
                    (image, error, cacheType, imageUrl) in
                    
                    if (image != nil) {
                        cell.reportImageView.image = UIImage(CGImage: (image?.CGImage)!, scale: (image?.scale)!, orientation: UIImageOrientation.Up)
                    }
                })
                
            }
        }
        else {
            print("No image to show")
            cell.reportImageView.image = nil
        }
        
        // Report > Group > Name
        //
        let reportGroups = _thisSubmission["groups"]
        var reportGroupsNames: String? = ""
        
        let reportGroupsTotal = reportGroups.count
        var reportGroupsIncrementer = 1
        
        for _group in reportGroups {
            let thisGroupName = _group.1["properties"]["name"]
            
            if reportGroupsTotal == 1 || reportGroupsIncrementer == 1 {
                reportGroupsNames = "\(thisGroupName)"
            }
            else if (reportGroupsTotal > 1 && reportGroupsIncrementer > 1)  {
                reportGroupsNames = reportGroupsNames! + ", " + "\(thisGroupName)"
            }
            
            reportGroupsIncrementer += 1
        }
        
        cell.labelReportGroups.text = reportGroupsNames
        
        
        // Buttons > Share
        //
        
        // Buttons > Map
        //
        cell.buttonReportMap.tag = indexPath.row
        
        // Buttons > Directions
        //
        cell.buttonReportDirections.addTarget(self, action: #selector(ProfileTableViewController.openUserSubmissionDirectionsURL(_:)), forControlEvents: .TouchUpInside)
        
        // Buttons > Comments
        //
        let reportComments = _thisSubmission["comments"]
        
        var reportCommentsCountText: String = "0 comments"
        
        if reportComments.count == 1 {
            reportCommentsCountText = "1 comment"
        }
        else if reportComments.count >= 1 {
            reportCommentsCountText = String(reportComments.count) + " comments"
        }
        else {
            reportCommentsCountText = "0 comments"
        }
        
        cell.buttonReportComments.tag = indexPath.row
        
        cell.buttonReportComments.setTitle(reportCommentsCountText, forState: UIControlState.Normal)
        
        if (_thisSubmission["closed_by"] != nil) {
            let badgeImage: UIImage = UIImage(named: "icon--Badge")!
            cell.buttonReportComments.setImage(badgeImage, forState: .Normal)
            cell.buttonReportComments.imageView?.contentMode = .ScaleAspectFit
        } else {
            let badgeImage: UIImage = UIImage(named: "icon--comment")!
            cell.buttonReportComments.setImage(badgeImage, forState: .Normal)
            cell.buttonReportComments.imageView?.contentMode = .ScaleAspectFit
        }
        
        //
        //
        //
        cell.buttonModifyReport.enabled = false
        cell.buttonModifyReport.hidden = true
        
        if let _user_id_number = NSUserDefaults.standardUserDefaults().objectForKey("currentUserAccountUID") as? NSNumber {
            if ("\(_thisSubmission["owner"]["id"])" == "\(_user_id_number)") {
                cell.buttonModifyReport.tag = indexPath.row
                cell.buttonModifyReport.enabled = true
                cell.buttonModifyReport.hidden = false
            }
        }
        
        cell.buttonReportTerritory.tag = indexPath.row
        
        
        // Report Like Button
        //
        cell.buttonReportLike.tag = indexPath.row
        
        var _user_id_integer: Int = 0
        
        if let _user_id_number = NSUserDefaults.standardUserDefaults().objectForKey("currentUserAccountUID") as? NSNumber {
            _user_id_integer = _user_id_number.integerValue
        }
        
        print("_user_id_integer \(_user_id_integer)")
        
        if _user_id_integer != 0 {
            
            print("Setup the like stuff")
            
            let _hasLiked = self.userHasLikedReport(_thisSubmission, _current_user_id: _user_id_integer)
            
            cell.buttonReportLike.setImage(UIImage(named: "icon--heart"), forState: .Normal)
            
            if (_hasLiked) {
                cell.buttonReportLike.removeTarget(nil, action: nil, forControlEvents: .AllEvents)
                cell.buttonReportLike.addTarget(self, action: #selector(unlikeCurrentReport(_:)), forControlEvents: .TouchUpInside)
                cell.buttonReportLike.setImage(UIImage(named: "icon--heartred"), forState: .Normal)
            }
            else {
                cell.buttonReportLike.removeTarget(nil, action: nil, forControlEvents: .AllEvents)
                cell.buttonReportLike.addTarget(self, action: #selector(likeCurrentReport(_:)), forControlEvents: .TouchUpInside)
            }
            
            cell.buttonReportLikeCount.tag = indexPath.row
            cell.buttonReportLikeCount.addTarget(self, action: #selector(self.openSubmissionsLikesList(_:)), forControlEvents: .TouchUpInside)
            
            // Update the total likes count
            //
            let _report_likes_count: Int = _thisSubmission["likes"].count
            
            // Check if we have previously liked this photo. If so, we need to take
            // that into account when adding a new like.
            //
            let _report_likes_updated_total: Int! = _report_likes_count
            
            var reportLikesCountText: String = ""
            
            if _report_likes_updated_total == 1 {
                reportLikesCountText = "1 like"
                cell.buttonReportLikeCount.hidden = false
            }
            else if _report_likes_updated_total >= 1 {
                reportLikesCountText = "\(_report_likes_updated_total) likes"
                cell.buttonReportLikeCount.hidden = false
            }
            else {
                reportLikesCountText = "0 likes"
                cell.buttonReportLikeCount.hidden = false
            }
            
            cell.buttonReportLikeCount.setTitle(reportLikesCountText, forState: .Normal)
        }
        
        
        //
        // CONTIUOUS SCROLL
        //
        if (indexPath.row == self.actions.count - 5 && self.actions.count < self.actionResponse!["properties"]["num_results"].int) {
            self.attemptLoadUserActions()
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
        
        if (self.actionsTableView.hidden == false) {
            var _cell = self.actionsTableView.cellForRowAtIndexPath(_indexPath) as! UserProfileActionsTableViewCell
            _report = JSON(self.userActionsObjects[(indexPathRow)].objectForKey("properties")!)
            
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
        else if (self.submissionTableView.hidden == false) {
            var _cell = self.submissionTableView.cellForRowAtIndexPath(_indexPath) as! UserProfileSubmissionTableViewCell
            _report = JSON(self.userSubmissionsObjects[(indexPathRow)].objectForKey("properties")!)
            
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
            
            print("existing likes \(_report["likes"])")
            
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
        else {
            return;
        }
        
        
        
        
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
            
            if (self.actionsTableView.hidden == false) {
                _report = JSON(self.userActionsObjects[(senderTag)])
            }
            else if (self.submissionTableView.hidden == false) {
                _report = JSON(self.userSubmissionsObjects[(senderTag)])
            }
            else {
                return;
            }
            
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
            
            if (self.actionsTableView.hidden == false) {
                _report = JSON(self.userActionsObjects[(senderTag)])
            }
            else if (self.submissionTableView.hidden == false) {
                _report = JSON(self.userSubmissionsObjects[(senderTag)])
            }
            else {
                return;
            }
            
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

