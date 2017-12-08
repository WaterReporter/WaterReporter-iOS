//
//  TerritoryTableViewController.swift
//  Water-Reporter
//
//  Created by Joshua Powell on 4/12/17.
//  Copyright © 2017 Viable Industries, L.L.C. All rights reserved.
//

import ActiveLabel
import Alamofire
import Kingfisher
import SwiftyJSON
import UIKit

class TerritoryTableViewController: UITableViewController {
    
    //
    // MARK: View-Global Variable
    //
    let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
    
    var territory: String = ""
    var territoryId: String = ""
    var territoryHUC8Code: String = ""
    var territoryPage: Int = 1
    
    var territorySelectedTab: String! = "Submissions"

    var territoryGroups: JSON?
    var territoryGroupsObjects = [AnyObject]()
    var territoryGroupsPage: Int = 1
    var territoryGroupsRefreshControl: UIRefreshControl = UIRefreshControl()
    
    var territorySubmissions: JSON?
    var territorySubmissionsObjects = [AnyObject]()
    var territorySubmissionsPage: Int = 1
    var territorySubmissionsRefreshControl: UIRefreshControl = UIRefreshControl()
    
    var territoryActions: JSON?
    var territoryActionsObjects = [AnyObject]()
    var territoryActionsPage: Int = 1
    var territoryActionsRefreshControl: UIRefreshControl = UIRefreshControl()
    
    var territorySubmissionsUnderline = CALayer()
    var territoryActionsUnderline = CALayer()
    var territoryGroupsUnderline = CALayer()
    

    //
    // MARK: @IBOutlet
    //
    @IBOutlet weak var labelTerritoryName: UILabel!

    @IBOutlet weak var territorySubmissionsCount: UIButton!
    @IBOutlet weak var territorySubmissionsLabel: UIButton!
    @IBOutlet weak var territoryActionsCount: UIButton!
    @IBOutlet weak var territoryActionLabel: UIButton!
    @IBOutlet weak var territoryGroupsCount: UIButton!
    @IBOutlet weak var territoryGroupsLabel: UIButton!
    
    
    
    //
    // MARK: @IBAction
    //
    @IBAction func openUserSubmissionDirectionsURL(sender: UIButton) {
        
        let _submissions = JSON(self.territorySubmissionsObjects)
        let reportCoordinates = _submissions[sender.tag]["geometry"]["geometries"][0]["coordinates"]
        
        UIApplication.sharedApplication().openURL(NSURL(string: "https://www.google.com/maps/dir//\(reportCoordinates[1]),\(reportCoordinates[0])")!)
    }

    @IBAction func openUserActionDirectionsURL(sender: UIButton) {
        
        let _submissions = JSON(self.territoryActionsObjects)
        let reportCoordinates = _submissions[sender.tag]["geometry"]["geometries"][0]["coordinates"]
        
        UIApplication.sharedApplication().openURL(NSURL(string: "https://www.google.com/maps/dir//\(reportCoordinates[1]),\(reportCoordinates[0])")!)
    }

    @IBAction func shareSubmissionsButtonClicked(sender: UIButton) {
        
        let _submissions = JSON(self.territorySubmissionsObjects)
        let reportId: String = "\(_submissions[sender.tag]["id"])"
        let textToShare = "Check out this report on WaterReporter"
        
        if let myWebsite = NSURL(string: "https://www.waterreporter.org/reports/" + reportId) {
            let objectsToShare = [textToShare, myWebsite]
            let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
            
            activityVC.popoverPresentationController?.sourceView = sender
            self.presentViewController(activityVC, animated: true, completion: nil)
        }
    }
    
    @IBAction func shareActionsButtonClicked(sender: UIButton) {
        
        let _actions = JSON(self.territoryActionsObjects)
        let reportId: String = "\(_actions[sender.tag]["id"])"
        let textToShare = "Check out this report on WaterReporter"
        
        if let myWebsite = NSURL(string: "https://www.waterreporter.org/reports/" + reportId) {
            let objectsToShare = [textToShare, myWebsite]
            let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
            
            activityVC.popoverPresentationController?.sourceView = sender
            self.presentViewController(activityVC, animated: true, completion: nil)
        }
    }
    
    @IBAction func openUserSubmissionMapView(sender: UIButton) {
        let nextViewController = self.storyBoard.instantiateViewControllerWithIdentifier("ActivityMapViewController") as! ActivityMapViewController
        
        nextViewController.reportObject = self.territorySubmissionsObjects[sender.tag]
        
        self.navigationController?.pushViewController(nextViewController, animated: true)
        
    }
    
    @IBAction func openUserSubmissionCommentsView(sender: UIButton) {
        let nextViewController = self.storyBoard.instantiateViewControllerWithIdentifier("CommentsTableViewController") as! CommentsTableViewController
        
        nextViewController.report = self.territorySubmissionsObjects[sender.tag]
        
        self.navigationController?.pushViewController(nextViewController, animated: true)
        
    }
    
    @IBAction func openUserActionMapView(sender: UIButton) {
        let nextViewController = self.storyBoard.instantiateViewControllerWithIdentifier("ActivityMapViewController") as! ActivityMapViewController
        
        nextViewController.reportObject = self.territoryActionsObjects[sender.tag]
        
        self.navigationController?.pushViewController(nextViewController, animated: true)
        
    }
    
    @IBAction func openUserActionCommentsView(sender: UIButton) {
        let nextViewController = self.storyBoard.instantiateViewControllerWithIdentifier("CommentsTableViewController") as! CommentsTableViewController
        
        nextViewController.report = self.territoryActionsObjects[sender.tag]
        
        self.navigationController?.pushViewController(nextViewController, animated: true)
        
    }
    
    @IBAction func openTerritoryGroupView(sender: UIButton) {
        let nextViewController = self.storyBoard.instantiateViewControllerWithIdentifier("OrganizationTableViewController") as! OrganizationTableViewController
        
        let _groups = JSON(self.territoryGroupsObjects)
        let _group_id = _groups[sender.tag]["id"]
        
        nextViewController.groupId = "\(_group_id)"
        nextViewController.groupObject = _groups[sender.tag]
        
        self.navigationController?.pushViewController(nextViewController, animated: true)
    }

    @IBAction func loadCommentOwnerProfile(sender: UIButton) {
        
        let nextViewController = self.storyBoard.instantiateViewControllerWithIdentifier("ProfileTableViewController") as! ProfileTableViewController
        
        var _thisReport: JSON!
        
        if self.territorySelectedTab == "Submissions" {
            _thisReport = JSON(self.territorySubmissionsObjects[(sender.tag)])
        }
        else if self.territorySelectedTab == "Actions" {
            _thisReport = JSON(self.territoryActionsObjects[(sender.tag)])
        }
        else if self.territorySelectedTab == "Groups" {
            _thisReport = JSON(self.territoryGroupsObjects[(sender.tag)])
        }
        
        nextViewController.userId = "\(_thisReport["properties"]["owner"]["id"])"
        nextViewController.userObject = _thisReport["properties"]["owner"]
        
        self.navigationController?.pushViewController(nextViewController, animated: true)
    }
    
    @IBAction func loadTerritoryProfile(sender: UIButton) {
        
        let nextViewController = self.storyBoard.instantiateViewControllerWithIdentifier("TerritoryTableViewController") as! TerritoryTableViewController
        
        var _thisReport: JSON!
        
        if self.territorySelectedTab == "Submissions" {
            _thisReport = JSON(self.territorySubmissionsObjects[(sender.tag)])
        }
        else if self.territorySelectedTab == "Actions" {
            _thisReport = JSON(self.territoryActionsObjects[(sender.tag)])
        }
        else if self.territorySelectedTab == "Groups" {
            _thisReport = JSON(self.territoryGroupsObjects[(sender.tag)])
        }
        
        print("\(_thisReport["properties"]["territory"])")
        
        nextViewController.territory = "\(_thisReport["properties"]["territory"]["properties"]["huc_8_name"])"
        nextViewController.territoryId = "\(_thisReport["properties"]["territory_id"])"
        nextViewController.territoryHUC8Code = "\(_thisReport["properties"]["territory"]["properties"]["huc_8_code"])"
        
        self.navigationController?.pushViewController(nextViewController, animated: true)
    }
    
    @IBAction func changeGroupProfileTab(sender: UIButton) {
        
        if (sender.restorationIdentifier == "buttonTabActionNumber" || sender.restorationIdentifier == "buttonTabActionLabel") {
            
            self.territorySelectedTab = "Actions"

            print("Show the Actions tab")

            //
            // Restyle the form Log In Navigation button to appear with an underline
            //
            let buttonWidth = self.territoryActionLabel.frame.width*0.6
            let borderWidth = buttonWidth
            
            self.territoryActionsUnderline.borderColor = CGColor.colorBrand()
            self.territoryActionsUnderline.borderWidth = 3.0
            self.territoryActionsUnderline.frame = CGRectMake(self.territoryActionLabel.frame.width*0.2, self.territoryActionLabel.frame.size.height - 3.0, borderWidth, self.territoryActionLabel.frame.size.height)
            
            self.territoryActionLabel.layer.addSublayer(self.territoryActionsUnderline)
            self.territoryActionLabel.layer.masksToBounds = true
            
            self.territorySubmissionsUnderline.removeFromSuperlayer()
            self.territoryGroupsUnderline.removeFromSuperlayer()
            
            self.tableView.reloadData()

        } else if (sender.restorationIdentifier == "buttonTabGroupNumber" || sender.restorationIdentifier == "buttonTabGroupLabel") {
            
            self.territorySelectedTab = "Groups"

            //
            // Restyle the form Log In Navigation button to appear with an underline
            //
            let buttonWidth = self.territoryGroupsLabel.frame.width*0.6
            let borderWidth = buttonWidth
            
            self.territoryGroupsUnderline.borderColor = CGColor.colorBrand()
            self.territoryGroupsUnderline.borderWidth = 3.0
            self.territoryGroupsUnderline.frame = CGRectMake(self.territoryGroupsLabel.frame.width*0.2, self.territoryGroupsLabel.frame.size.height - 3.0, borderWidth, self.territoryGroupsLabel.frame.size.height)
            
            self.territoryGroupsLabel.layer.addSublayer(self.territoryGroupsUnderline)
            self.territoryGroupsLabel.layer.masksToBounds = true
            
            self.territorySubmissionsUnderline.removeFromSuperlayer()
            self.territoryActionsUnderline.removeFromSuperlayer()
            
            self.tableView.reloadData()

        } else if (sender.restorationIdentifier == "buttonTabSubmissionNumber" || sender.restorationIdentifier == "buttonTabSubmissionLabel") {
            
            self.territorySelectedTab = "Submissions"
            
            //
            // Restyle the form Log In Navigation button to appear with an underline
            //
            let buttonWidth = self.territorySubmissionsLabel.frame.width*0.8
            let borderWidth = buttonWidth
            
            self.territorySubmissionsUnderline.borderColor = CGColor.colorBrand()
            self.territorySubmissionsUnderline.borderWidth = 3.0
            self.territorySubmissionsUnderline.frame = CGRectMake(self.territorySubmissionsLabel.frame.width*0.1, self.territorySubmissionsLabel.frame.size.height - 3.0, borderWidth, self.territorySubmissionsLabel.frame.size.height)
            
            self.territorySubmissionsLabel.layer.addSublayer(self.territorySubmissionsUnderline)
            self.territorySubmissionsLabel.layer.masksToBounds = true
            
            self.territoryActionsUnderline.removeFromSuperlayer()
            self.territoryGroupsUnderline.removeFromSuperlayer()

            self.tableView.reloadData()
        }
        
    }
    
    
    //
    //
    //
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if self.territory != "" {
            self.labelTerritoryName.text = "\(self.territory) Watershed"
        }
        
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        
        // LOAD DATA INTO THE SUBMISSIONS, ACTIONS, & GROUPS TABS
        //
        self.attemptLoadTerritorySubmissions(true)
        self.attemptLoadTerritoryActions(true)
        self.attemptLoadTerritoryGroups(true)
        
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 600.0
        
        //
        // Restyle the form Log In Navigation button to appear with an underline
        //
        let buttonWidth = self.territorySubmissionsLabel.frame.width*0.8
        let borderWidth = buttonWidth-10
        
        self.territorySubmissionsUnderline.borderColor = CGColor.colorBrand()
        self.territorySubmissionsUnderline.borderWidth = 3.0
        self.territorySubmissionsUnderline.frame = CGRectMake(self.territorySubmissionsLabel.frame.width*0.1, self.territorySubmissionsLabel.frame.size.height - 3.0, borderWidth, self.territorySubmissionsLabel.frame.size.height)
        
        self.territorySubmissionsLabel.layer.addSublayer(self.territorySubmissionsUnderline)
        self.territorySubmissionsLabel.layer.masksToBounds = true
        
        self.territoryActionsUnderline.removeFromSuperlayer()
        self.territoryGroupsUnderline.removeFromSuperlayer()

        
    }

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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
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

    func attemptLoadTerritorySubmissions(isRefreshingReportsList: Bool = false) {
        
        let _parameters = [
            "q": "{\"filters\":[{\"name\":\"territory\",\"op\":\"has\",\"val\": {\"name\":\"huc_8_code\",\"op\":\"eq\",\"val\":\"\(self.territoryHUC8Code)\"}}],\"order_by\": [{\"field\":\"created\",\"direction\":\"desc\"}]}",
            "page": "\(self.territorySubmissionsPage)"
        ]
        
        print("_parameters \(_parameters)")
        
        Alamofire.request(.GET, Endpoints.GET_MANY_REPORTS, parameters: _parameters)
            .responseJSON { response in
                
                switch response.result {
                case .Success(let value):
                    print("attemptLoadTerritorySubmissions::Request Success \(Endpoints.GET_MANY_REPORTS) \(value)")
                    
                    // Assign response to groups variable
                    if (isRefreshingReportsList) {
                        self.territorySubmissions = JSON(value)
                        self.territorySubmissionsObjects = value["features"] as! [AnyObject]
                        self.territorySubmissionsRefreshControl.endRefreshing()
                    }
                    else {
                        self.territorySubmissions = JSON(value)
                        self.territorySubmissionsObjects += value["features"] as! [AnyObject]
                    }
                    
                    // Set visible button count
                    let _submission_count = self.territorySubmissions!["properties"]["num_results"]
                    
                    if (_submission_count != "") {
                        self.territorySubmissionsCount.setTitle("\(_submission_count)", forState: .Normal)
                    }
                    
                    // Refresh the data in the table so the newest items appear
                    self.tableView.reloadData()
                    
                    self.territorySubmissionsPage += 1
                    
                    break
                case .Failure(let error):
                    print("Request Failure: \(error)")
                    
                    // Stop showing the loading indicator
                    //self.status("doneLoadingWithError")
                    
                    break
                }
                
        }
        
    }
    
    
    func attemptLoadTerritoryActions(isRefreshingReportsList: Bool = false) {
        
        let _parameters = [
            "q": "{\"filters\":[{\"name\":\"territory\",\"op\":\"has\",\"val\": {\"name\":\"huc_8_code\",\"op\":\"eq\",\"val\":\"\(self.territoryHUC8Code)\"}},{\"name\":\"state\", \"op\":\"eq\", \"val\":\"closed\"}],\"order_by\": [{\"field\":\"created\",\"direction\":\"desc\"}]}",
            "page": "\(self.territoryActionsPage)"
        ]
        
        Alamofire.request(.GET, Endpoints.GET_MANY_REPORTS, parameters: _parameters)
            .responseJSON { response in
                
                switch response.result {
                case .Success(let value):
                    print("attemptLoadTerritoryActions::Request Success \(Endpoints.GET_MANY_REPORTS) \(value)")
                    
                    // Assign response to groups variable
                    if (isRefreshingReportsList) {
                        self.territoryActions = JSON(value)
                        self.territoryActionsObjects = value["features"] as! [AnyObject]
                        self.territoryActionsRefreshControl.endRefreshing()
                    }
                    else {
                        self.territoryActions = JSON(value)
                        self.territoryActionsObjects += value["features"] as! [AnyObject]
                    }
                    
                    // Set visible button count
                    let _action_count = self.territoryActions!["properties"]["num_results"]
                    
                    if (_action_count >= 1) {
                        self.territoryActionsCount.setTitle("\(_action_count)", forState: .Normal)
                    }
                    
                    // Refresh the data in the table so the newest items appear
                    self.tableView.reloadData()
                    
                    self.territoryActionsPage += 1
                    
                    break
                case .Failure(let error):
                    print("Request Failure: \(error)")
                    
                    // Stop showing the loading indicator
                    //self.status("doneLoadingWithError")
                    
                    break
                }
                
        }
        
    }

    func attemptLoadTerritoryGroups(isRefreshingReportsList: Bool = false) {
        
        let _parameters = [
            "q": "{\"filters\":[{\"name\":\"reports\",\"op\":\"any\",\"val\":{\"name\":\"territory\",\"op\":\"has\",\"val\":{\"name\":\"huc_8_code\",\"op\":\"eq\",\"val\":\"\(self.territoryHUC8Code)\"}}}]}",
            "page": "\(self.territoryGroupsPage)"
        ]
        
        Alamofire.request(.GET, Endpoints.GET_MANY_ORGANIZATIONS, parameters: _parameters)
            .responseJSON { response in
                
                switch response.result {
                case .Success(let value):
                    print("attemptLoadTerritoryGroups::Request Success \(Endpoints.GET_MANY_ORGANIZATIONS) \(value)")
                    
                    // Assign response to groups variable
                    if (isRefreshingReportsList) {
                        self.territoryGroups = JSON(value)
                        self.territoryGroupsObjects = value["features"] as! [AnyObject]
                        self.territoryGroupsRefreshControl.endRefreshing()
                    }
                    else {
                        self.territoryGroups = JSON(value)
                        self.territoryGroupsObjects += value["features"] as! [AnyObject]
                    }
                    
                    // Set visible button count
                    let _action_count = self.territoryGroups!["properties"]["num_results"]
                    
                    if (_action_count >= 1) {
                        self.territoryGroupsCount.setTitle("\(_action_count)", forState: .Normal)
                    }
                    
                    // Refresh the data in the table so the newest items appear
                    self.tableView.reloadData()
                    
                    self.territoryGroupsPage += 1
                    
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
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if self.territorySelectedTab == "Submissions" {
            
            guard (JSON(self.territorySubmissionsObjects) != nil) else { return 0 }
            
            return (self.territorySubmissionsObjects.count)
            
        } else if self.territorySelectedTab == "Actions" {
            
            guard (JSON(self.territoryActionsObjects) != nil) else { return 0 }
            
            return (self.territoryActionsObjects.count)
            
        } else if self.territorySelectedTab == "Groups" {
            
            guard (JSON(self.territoryGroupsObjects) != nil) else { return 0 }
            
            return (self.territoryGroupsObjects.count)
            
        }
        
        return 0
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if self.territorySelectedTab == "Submissions" {

            let cell = tableView.dequeueReusableCellWithIdentifier("watershedSubmissionCell", forIndexPath: indexPath) as! UserProfileSubmissionTableViewCell
            
            guard (JSON(self.territorySubmissionsObjects) != nil) else { return cell }
            
            let _submission = JSON(self.territorySubmissionsObjects)
            let _thisSubmission = _submission[indexPath.row]["properties"]
            
            // Report > Owner > Image
            //
            var reportOwnerProfileImageURL:NSURL! = NSURL(string: "https://www.waterreporter.org/community/images/badget--MissingUser.png")
            
            if let thisReportOwnerImageURL = _thisSubmission["owner"]["properties"]["picture"].string {
                reportOwnerProfileImageURL = NSURL(string: String(thisReportOwnerImageURL))
            }
            
            cell.imageViewReportOwnerImage.kf_indicatorType = .Activity
            cell.imageViewReportOwnerImage.kf_showIndicatorWhenLoading = true
            
            cell.imageViewReportOwnerImage.kf_setImageWithURL(reportOwnerProfileImageURL, placeholderImage: nil, optionsInfo: nil, progressBlock: nil, completionHandler: {
                (image, error, cacheType, imageUrl) in
                if (image != nil) {
                    cell.imageViewReportOwnerImage.image = UIImage(CGImage: (image?.CGImage)!, scale: (image?.scale)!, orientation: UIImageOrientation.Up)
                }
            })
            
            cell.imageViewReportOwnerImage.tag = indexPath.row
            cell.reportOwnerImageButton.tag = indexPath.row

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
                cell.labelReportDescription.enabledTypes = [.Hashtag]
                cell.labelReportDescription.hashtagColor = UIColor.colorBrand()
                cell.labelReportDescription.hashtagSelectedColor = UIColor.colorDarkGray()
                
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
            
            // Report > Groups
            //
            cell.labelReportGroups.text = "Report Group Names"
            
            // Report > Image
            //
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
            cell.buttonReportShare.tag = indexPath.row
            
            // Buttons > Map
            //
            cell.buttonReportMap.tag = indexPath.row
            
            // Buttons > Directions
            //
            cell.buttonReportDirections.tag = indexPath.row
            
            // Buttons > Comments
            //
            cell.buttonReportComments.tag = indexPath.row
            
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
            
            cell.buttonReportTerritory.tag = indexPath.row
            
            if (indexPath.row == self.territorySubmissionsObjects.count - 2 && self.territorySubmissionsObjects.count < self.territorySubmissions!["properties"]["num_results"].int) {
                self.attemptLoadTerritorySubmissions()
            }
            
            return cell

        }
        else if self.territorySelectedTab == "Actions" {

            let cell = tableView.dequeueReusableCellWithIdentifier("watershedActionCell", forIndexPath: indexPath) as! UserProfileActionsTableViewCell
            
            guard (JSON(self.territoryActionsObjects) != nil) else { return cell }
            
            let _actions = JSON(self.territoryActionsObjects)
            let _thisSubmission = _actions[indexPath.row]["properties"]
            print("Show _thisSubmission \(_thisSubmission)")
            
            // Report > Owner > Image
            //
            var reportOwnerProfileImageURL:NSURL! = NSURL(string: "https://www.waterreporter.org/community/images/badget--MissingUser.png")
            
            if let thisReportOwnerImageURL = _thisSubmission["owner"]["properties"]["picture"].string {
                reportOwnerProfileImageURL = NSURL(string: String(thisReportOwnerImageURL))
            }
            
            cell.imageViewReportOwnerImage.kf_indicatorType = .Activity
            cell.imageViewReportOwnerImage.kf_showIndicatorWhenLoading = true
            
            cell.imageViewReportOwnerImage.kf_setImageWithURL(reportOwnerProfileImageURL, placeholderImage: nil, optionsInfo: nil, progressBlock: nil, completionHandler: {
                (image, error, cacheType, imageUrl) in
                if (image != nil) {
                    cell.imageViewReportOwnerImage.image = UIImage(CGImage: (image?.CGImage)!, scale: (image?.scale)!, orientation: UIImageOrientation.Up)
                }
            })

            cell.imageViewReportOwnerImage.tag = indexPath.row
            cell.reportOwnerImageButton.tag = indexPath.row

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
                cell.labelReportDescription.enabledTypes = [.Hashtag]
                cell.labelReportDescription.hashtagColor = UIColor.colorBrand()
                cell.labelReportDescription.hashtagSelectedColor = UIColor.colorDarkGray()
                
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
            
            // Report > Image
            //
            //
            // REPORT > IMAGE
            //
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
            
            // Buttons > Share
            //
            cell.buttonReportShare.tag = indexPath.row
            
            // Buttons > Map
            //
            cell.buttonReportMap.tag = indexPath.row
            
            // Buttons > Directions
            //
            cell.buttonReportDirections.tag = indexPath.row
            
            // Buttons > Comments
            //
            cell.buttonReportComments.tag = indexPath.row
            
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
            
            if (indexPath.row == self.territoryActionsObjects.count - 2 && self.territoryActionsObjects.count < self.territoryActions!["properties"]["num_results"].int) {
                self.attemptLoadTerritoryActions()
            }

            return cell
        }
        else if self.territorySelectedTab == "Groups" {
            
            let cell = tableView.dequeueReusableCellWithIdentifier("watershedGroupCell", forIndexPath: indexPath) as! UserProfileGroupsTableViewCell

            guard (JSON(self.territoryGroupsObjects) != nil) else { return cell }
            
            let _groups = JSON(self.territoryGroupsObjects)
            
            cell.labelUserProfileGroupName.text = "\(_groups[indexPath.row]["properties"]["name"])"

            
            cell.buttonGroupSelection.tag = indexPath.row

            // Display Group Image
            var groupProfileImageURL:NSURL! = NSURL(string: "https://www.waterreporter.org/community/images/badget--MissingUser.png")
            
            if let groupProfileImageString = _groups[indexPath.row]["properties"]["picture"].string {
                groupProfileImageURL = NSURL(string: String(groupProfileImageString))
            }

            cell.imageViewUserProfileGroup.kf_indicatorType = .Activity
            cell.imageViewUserProfileGroup.kf_showIndicatorWhenLoading = true
            
            cell.imageViewUserProfileGroup.kf_setImageWithURL(groupProfileImageURL, placeholderImage: nil, optionsInfo: nil, progressBlock: nil, completionHandler: {
                (image, error, cacheType, imageUrl) in
                if (image != nil) {
                    cell.imageViewUserProfileGroup.image = UIImage(CGImage: (image?.CGImage)!, scale: (image?.scale)!, orientation: UIImageOrientation.Up)
                }
            })
            
            if (indexPath.row == self.territoryGroupsObjects.count - 2 && self.territoryGroupsObjects.count < self.territoryGroups!["properties"]["num_results"].int) {
                self.attemptLoadTerritoryGroups()
            }
            
            return cell
        }
        else {
            return UITableViewCell()
        }
        
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        print("row tapped \(indexPath)")
    }


}
