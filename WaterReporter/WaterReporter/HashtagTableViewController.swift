//
//  HashtagTableViewController.swift
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

class HashtagTableViewController: UITableViewController {
    
    //
    // MARK: View-Global Variable
    //
    let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
    
    var hashtag: String = ""
    var hashtagPage: Int = 1
    
    var hashtagSelectedTab: String! = "Submissions"
    
    var hashtagGroups: JSON?
    var hashtagGroupsObjects = [AnyObject]()
    var hashtagGroupsPage: Int = 1
    var hashtagGroupsRefreshControl: UIRefreshControl = UIRefreshControl()
    
    var hashtagSubmissions: JSON?
    var hashtagSubmissionsObjects = [AnyObject]()
    var hashtagSubmissionsPage: Int = 1
    var hashtagSubmissionsRefreshControl: UIRefreshControl = UIRefreshControl()
    
    var hashtagActions: JSON?
    var hashtagActionsObjects = [AnyObject]()
    var hashtagActionsPage: Int = 1
    var hashtagActionsRefreshControl: UIRefreshControl = UIRefreshControl()
    
    var hashtagSubmissionsUnderline = CALayer()
    var hashtagActionsUnderline = CALayer()
    var hashtagGroupsUnderline = CALayer()
    
    var likeDelay: NSTimer = NSTimer()
    var unlikeDelay: NSTimer = NSTimer()

    
    //
    // MARK: @IBOutlet
    //
    @IBOutlet weak var labelHashtagName: UILabel!
    
    @IBOutlet weak var hashtagSubmissionsCount: UIButton!
    @IBOutlet weak var hashtagSubmissionsLabel: UIButton!
    @IBOutlet weak var hashtagActionsCount: UIButton!
    @IBOutlet weak var hashtagActionLabel: UIButton!
    @IBOutlet weak var hashtagGroupsCount: UIButton!
    @IBOutlet weak var hashtagGroupsLabel: UIButton!
    

    //
    // MARK: @IBAction
    //
    @IBAction func openSubmissionOpenGraphURL(sender: UIButton) {
        
        let reportId = sender.tag
        let report = JSON(self.hashtagSubmissionsObjects[reportId])
        
        let reportURL = "\(report["properties"]["social"][0]["properties"]["og_url"])"
        
        print("openOpenGraphURL \(reportURL)")
        
        UIApplication.sharedApplication().openURL(NSURL(string: "\(reportURL)")!)
    }
    
    @IBAction func openActionsOpenGraphURL(sender: UIButton) {
        
        let reportId = sender.tag
        let report = JSON(self.hashtagActionsObjects[reportId])
        
        let reportURL = "\(report["properties"]["social"][0]["properties"]["og_url"])"
        
        print("openOpenGraphURL \(reportURL)")
        
        UIApplication.sharedApplication().openURL(NSURL(string: "\(reportURL)")!)
    }

    
    @IBAction func openUserSubmissionDirectionsURL(sender: UIButton) {
        
        let _submissions = JSON(self.hashtagSubmissionsObjects)
        let reportCoordinates = _submissions[sender.tag]["geometry"]["geometries"][0]["coordinates"]
        
        UIApplication.sharedApplication().openURL(NSURL(string: "https://www.google.com/maps/dir//\(reportCoordinates[1]),\(reportCoordinates[0])")!)
    }
    
    @IBAction func openUserActionDirectionsURL(sender: UIButton) {
        
        let _submissions = JSON(self.hashtagActionsObjects)
        let reportCoordinates = _submissions[sender.tag]["geometry"]["geometries"][0]["coordinates"]
        
        UIApplication.sharedApplication().openURL(NSURL(string: "https://www.google.com/maps/dir//\(reportCoordinates[1]),\(reportCoordinates[0])")!)
    }
    
    @IBAction func shareSubmissionsButtonClicked(sender: UIButton) {
        
        let _submissions = JSON(self.hashtagSubmissionsObjects)
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
        
        let _actions = JSON(self.hashtagActionsObjects)
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
        
        nextViewController.reportObject = self.hashtagSubmissionsObjects[sender.tag]
        
        self.navigationController?.pushViewController(nextViewController, animated: true)
        
    }
    
    @IBAction func openUserSubmissionCommentsView(sender: UIButton) {
        let nextViewController = self.storyBoard.instantiateViewControllerWithIdentifier("CommentsTableViewController") as! CommentsTableViewController
        
        nextViewController.report = self.hashtagSubmissionsObjects[sender.tag]
        
        self.navigationController?.pushViewController(nextViewController, animated: true)
        
    }
    
    @IBAction func openUserActionMapView(sender: UIButton) {
        let nextViewController = self.storyBoard.instantiateViewControllerWithIdentifier("ActivityMapViewController") as! ActivityMapViewController
        
        nextViewController.reportObject = self.hashtagActionsObjects[sender.tag]
        
        self.navigationController?.pushViewController(nextViewController, animated: true)
        
    }
    
    @IBAction func openUserActionCommentsView(sender: UIButton) {
        let nextViewController = self.storyBoard.instantiateViewControllerWithIdentifier("CommentsTableViewController") as! CommentsTableViewController
        
        nextViewController.report = self.hashtagActionsObjects[sender.tag]
        
        self.navigationController?.pushViewController(nextViewController, animated: true)
        
    }
    
    @IBAction func openHashtagGroupView(sender: UIButton) {
        let nextViewController = self.storyBoard.instantiateViewControllerWithIdentifier("OrganizationTableViewController") as! OrganizationTableViewController
        
        let _groups = JSON(self.hashtagGroupsObjects)
        let _group_id = _groups[sender.tag]["properties"]["id"]
        
        nextViewController.groupId = "\(_group_id)"
        nextViewController.groupObject = _groups[sender.tag]
        
        self.navigationController?.pushViewController(nextViewController, animated: true)
    }
    
    @IBAction func loadCommentOwnerProfile(sender: UIButton) {
        
        let nextViewController = self.storyBoard.instantiateViewControllerWithIdentifier("ProfileTableViewController") as! ProfileTableViewController
        
        var _thisReport: JSON!
        
        if self.hashtagSelectedTab == "Submissions" {
            _thisReport = JSON(self.hashtagSubmissionsObjects[(sender.tag)])
        }
        else if self.hashtagSelectedTab == "Actions" {
            _thisReport = JSON(self.hashtagActionsObjects[(sender.tag)])
        }
        else if self.hashtagSelectedTab == "Groups" {
            _thisReport = JSON(self.hashtagGroupsObjects[(sender.tag)])
        }
        
        nextViewController.userId = "\(_thisReport["properties"]["owner"]["id"])"
        nextViewController.userObject = _thisReport["properties"]["owner"]
        
        self.navigationController?.pushViewController(nextViewController, animated: true)
    }
    
    @IBAction func loadTerritoryProfile(sender: UIButton) {
        
        let nextViewController = self.storyBoard.instantiateViewControllerWithIdentifier("TerritoryViewController") as! TerritoryViewController
        
        var _thisReport: JSON!
        
        if self.hashtagSelectedTab == "Submissions" {
            _thisReport = JSON(self.hashtagSubmissionsObjects[(sender.tag)])
        }
        else if self.hashtagSelectedTab == "Actions" {
            _thisReport = JSON(self.hashtagActionsObjects[(sender.tag)])
        }
        else if self.hashtagSelectedTab == "Groups" {
            _thisReport = JSON(self.hashtagGroupsObjects[(sender.tag)])
        }
        
        print("\(_thisReport["properties"]["territory"])")
        
        nextViewController.territory = "\(_thisReport["properties"]["territory"]["properties"]["huc_8_name"])"
        nextViewController.territoryId = "\(_thisReport["properties"]["territory_id"])"
        nextViewController.territoryHUC8Code = "\(_thisReport["properties"]["territory"]["properties"]["huc_8_code"])"
        
        self.navigationController?.pushViewController(nextViewController, animated: true)
    }
    
    @IBAction func changeGroupProfileTab(sender: UIButton) {
        
        if (sender.restorationIdentifier == "buttonTabActionNumber" || sender.restorationIdentifier == "buttonTabActionLabel") {
            
            self.hashtagSelectedTab = "Actions"
            
            print("Show the Actions tab")
            
            //
            // Restyle the form Log In Navigation button to appear with an underline
            //
            let buttonWidth = self.hashtagActionLabel.frame.width*0.6
            let borderWidth = buttonWidth
            
            self.hashtagActionsUnderline.borderColor = CGColor.colorBrand()
            self.hashtagActionsUnderline.borderWidth = 3.0
            self.hashtagActionsUnderline.frame = CGRectMake(self.hashtagActionLabel.frame.width*0.2, self.hashtagActionLabel.frame.size.height - 3.0, borderWidth, self.hashtagActionLabel.frame.size.height)
            
            self.hashtagActionLabel.layer.addSublayer(self.hashtagActionsUnderline)
            self.hashtagActionLabel.layer.masksToBounds = true
            
            self.hashtagSubmissionsUnderline.removeFromSuperlayer()
            self.hashtagGroupsUnderline.removeFromSuperlayer()
            
            self.tableView.reloadData()
            
        } else if (sender.restorationIdentifier == "buttonTabGroupNumber" || sender.restorationIdentifier == "buttonTabGroupLabel") {
            
            self.hashtagSelectedTab = "Groups"
            
            //
            // Restyle the form Log In Navigation button to appear with an underline
            //
            let buttonWidth = self.hashtagGroupsLabel.frame.width*0.6
            let borderWidth = buttonWidth
            
            self.hashtagGroupsUnderline.borderColor = CGColor.colorBrand()
            self.hashtagGroupsUnderline.borderWidth = 3.0
            self.hashtagGroupsUnderline.frame = CGRectMake(self.hashtagGroupsLabel.frame.width*0.2, self.hashtagGroupsLabel.frame.size.height - 3.0, borderWidth, self.hashtagGroupsLabel.frame.size.height)
            
            self.hashtagGroupsLabel.layer.addSublayer(self.hashtagGroupsUnderline)
            self.hashtagGroupsLabel.layer.masksToBounds = true
            
            self.hashtagSubmissionsUnderline.removeFromSuperlayer()
            self.hashtagActionsUnderline.removeFromSuperlayer()
            
            self.tableView.reloadData()
            
        } else if (sender.restorationIdentifier == "buttonTabSubmissionNumber" || sender.restorationIdentifier == "buttonTabSubmissionLabel") {
            
            self.hashtagSelectedTab = "Submissions"
            
            //
            // Restyle the form Log In Navigation button to appear with an underline
            //
            let buttonWidth = self.hashtagSubmissionsLabel.frame.width*0.8
            let borderWidth = buttonWidth
            
            self.hashtagSubmissionsUnderline.borderColor = CGColor.colorBrand()
            self.hashtagSubmissionsUnderline.borderWidth = 3.0
            self.hashtagSubmissionsUnderline.frame = CGRectMake(self.hashtagSubmissionsLabel.frame.width*0.1, self.hashtagSubmissionsLabel.frame.size.height - 3.0, borderWidth, self.hashtagSubmissionsLabel.frame.size.height)
            
            self.hashtagSubmissionsLabel.layer.addSublayer(self.hashtagSubmissionsUnderline)
            self.hashtagSubmissionsLabel.layer.masksToBounds = true
            
            self.hashtagActionsUnderline.removeFromSuperlayer()
            self.hashtagGroupsUnderline.removeFromSuperlayer()
            
            self.tableView.reloadData()
        }
        
    }
    
    @IBAction func openNewReportForm(sender: UIButton){
        self.tabBarController?.selectedIndex = 2
    }

    //
    //
    //
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if hashtag != "" {
            self.labelHashtagName.text = "#\(self.hashtag)"
        }

        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        // LOAD DATA INTO THE SUBMISSIONS, ACTIONS, & GROUPS TABS
        //
        self.attemptLoadHashtagSubmissions(true)
        self.attemptLoadHashtagActions(true)
        self.attemptLoadHashtagGroups(true)
        
        self.tableView.rowHeight = UITableViewAutomaticDimension;
        self.tableView.estimatedRowHeight = 368.0
        
        
        //
        // Restyle the form Log In Navigation button to appear with an underline
        //
        let buttonWidth = self.hashtagSubmissionsLabel.frame.width*0.8
        let borderWidth = buttonWidth-10
        
        self.hashtagSubmissionsUnderline.borderColor = CGColor.colorBrand()
        self.hashtagSubmissionsUnderline.borderWidth = 3.0
        self.hashtagSubmissionsUnderline.frame = CGRectMake(self.hashtagSubmissionsLabel.frame.width*0.1, self.hashtagSubmissionsLabel.frame.size.height - 3.0, borderWidth, self.hashtagSubmissionsLabel.frame.size.height)
        
        self.hashtagSubmissionsLabel.layer.addSublayer(self.hashtagSubmissionsUnderline)
        self.hashtagSubmissionsLabel.layer.masksToBounds = true
        
        self.hashtagActionsUnderline.removeFromSuperlayer()
        self.hashtagGroupsUnderline.removeFromSuperlayer()

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
    
    func attemptLoadHashtagSubmissions(isRefreshingReportsList: Bool = false) {
        
        let _parameters = [
            "q": "{\"filters\":[{\"name\":\"tags\",\"op\":\"any\",\"val\": {\"name\":\"tag\",\"op\":\"eq\",\"val\":\"\(self.hashtag)\"}}],\"order_by\": [{\"field\":\"report_date\",\"direction\":\"desc\"},{\"field\":\"id\",\"direction\":\"desc\"}]}",
            "page": "\(self.hashtagSubmissionsPage)"
        ]
        
        print("_parameters \(_parameters)")
        
        Alamofire.request(.GET, Endpoints.GET_MANY_REPORTS, parameters: _parameters)
            .responseJSON { response in
                
                switch response.result {
                case .Success(let value):
//                    print("attemptLoadHashtagSubmissions::Request Success \(Endpoints.GET_MANY_REPORTS) \(value)")
                    
                    // Assign response to groups variable
                    if (isRefreshingReportsList) {
                        self.hashtagSubmissions = JSON(value)
                        self.hashtagSubmissionsObjects = value["features"] as! [AnyObject]
                        self.hashtagSubmissionsRefreshControl.endRefreshing()
                    }
                    else {
                        self.hashtagSubmissions = JSON(value)
                        self.hashtagSubmissionsObjects += value["features"] as! [AnyObject]
                    }
                    
                    // Set visible button count
                    let _submission_count = self.hashtagSubmissions!["properties"]["num_results"]
                    
                    if (_submission_count != "") {
                        self.hashtagSubmissionsCount.setTitle("\(_submission_count)", forState: .Normal)
                    }
                    
                    // Refresh the data in the table so the newest items appear
                    self.tableView.reloadData()
                    
                    self.hashtagSubmissionsPage += 1
                    
                    break
                case .Failure(let error):
                    print("Request Failure: \(error)")
                    
                    // Stop showing the loading indicator
                    //self.status("doneLoadingWithError")
                    
                    break
                }
                
        }
        
    }
    
    
    func attemptLoadHashtagActions(isRefreshingReportsList: Bool = false) {
        
        let _parameters = [
            "q": "{\"filters\":[{\"name\":\"tags\",\"op\":\"any\",\"val\": {\"name\":\"tag\",\"op\":\"eq\",\"val\":\"\(self.hashtag)\"}},{\"name\":\"state\", \"op\":\"eq\", \"val\":\"closed\"}],\"order_by\": [{\"field\":\"report_date\",\"direction\":\"desc\"},{\"field\":\"id\",\"direction\":\"desc\"}]}",
            "page": "\(self.hashtagActionsPage)"
        ]
        
        Alamofire.request(.GET, Endpoints.GET_MANY_REPORTS, parameters: _parameters)
            .responseJSON { response in
                
                switch response.result {
                case .Success(let value):
//                    print("attemptLoadHashtagActions::Request Success \(Endpoints.GET_MANY_REPORTS) \(value)")
                    
                    // Assign response to groups variable
                    if (isRefreshingReportsList) {
                        self.hashtagActions = JSON(value)
                        self.hashtagActionsObjects = value["features"] as! [AnyObject]
                        self.hashtagActionsRefreshControl.endRefreshing()
                    }
                    else {
                        self.hashtagActions = JSON(value)
                        self.hashtagActionsObjects += value["features"] as! [AnyObject]
                    }
                    
                    // Set visible button count
                    let _action_count = self.hashtagActions!["properties"]["num_results"]
                    
                    if (_action_count >= 1) {
                        self.hashtagActionsCount.setTitle("\(_action_count)", forState: .Normal)
                    }
                    
                    // Refresh the data in the table so the newest items appear
                    self.tableView.reloadData()
                    
                    self.hashtagActionsPage += 1
                    
                    break
                case .Failure(let error):
                    print("Request Failure: \(error)")
                    
                    // Stop showing the loading indicator
                    //self.status("doneLoadingWithError")
                    
                    break
                }
                
        }
        
    }
    
    
    
    func attemptLoadHashtagGroups(isRefreshingReportsList: Bool = false) {
        
        let _parameters = [
            "q": "{\"filters\":[{\"name\":\"reports\",\"op\":\"any\",\"val\":{\"name\":\"tags\",\"op\":\"any\",\"val\":{\"name\":\"tag\",\"op\":\"eq\",\"val\":\"\(self.hashtag)\"}}}]}",
            "page": "\(self.hashtagGroupsPage)"
        ]
        
        Alamofire.request(.GET, Endpoints.GET_MANY_ORGANIZATIONS, parameters: _parameters)
            .responseJSON { response in
                
                switch response.result {
                case .Success(let value):
//                    print("attemptLoadHashtagActions::Request Success \(Endpoints.GET_MANY_ORGANIZATIONS) \(value)")
                    
                    // Assign response to groups variable
                    if (isRefreshingReportsList) {
                        self.hashtagGroups = JSON(value)
                        self.hashtagGroupsObjects = value["features"] as! [AnyObject]
                        self.hashtagGroupsRefreshControl.endRefreshing()
                    }
                    else {
                        self.hashtagGroups = JSON(value)
                        self.hashtagGroupsObjects += value["features"] as! [AnyObject]
                    }
                    
                    // Set visible button count
                    let _action_count = self.hashtagGroups!["properties"]["num_results"]
                    
                    if (_action_count >= 1) {
                        self.hashtagGroupsCount.setTitle("\(_action_count)", forState: .Normal)
                    }
                    
                    // Refresh the data in the table so the newest items appear
                    self.tableView.reloadData()
                    
                    self.hashtagGroupsPage += 1
                    
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
        
        if self.hashtagSelectedTab == "Submissions" {
            
            guard (JSON(self.hashtagSubmissionsObjects) != nil) else { return 0 }

            if self.hashtagSubmissionsObjects.count == 0 {
                return 1
            }

            return (self.hashtagSubmissionsObjects.count)
            
        } else if self.hashtagSelectedTab == "Actions" {
            
            guard (JSON(self.hashtagActionsObjects) != nil) else { return 0 }

            if self.hashtagActionsObjects.count == 0 {
                return 1
            }
            
            return (self.hashtagActionsObjects.count)
            
        } else if self.hashtagSelectedTab == "Groups" {
            
            guard (JSON(self.hashtagGroupsObjects) != nil) else { return 0 }
            
            if self.hashtagGroupsObjects.count == 0 {
                return 1
            }

            return (self.hashtagGroupsObjects.count)
            
        }
        
        return 0
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let emptyCell = tableView.dequeueReusableCellWithIdentifier("emptyTableViewCell", forIndexPath: indexPath) as! EmptyTableViewCell
        
        if self.hashtagSelectedTab == "Submissions" {
            
            let cell = tableView.dequeueReusableCellWithIdentifier("hashtagSubmissionCell", forIndexPath: indexPath) as! UserProfileSubmissionTableViewCell
            
            guard (JSON(self.hashtagSubmissionsObjects) != nil) else { return emptyCell }
            
            let _submission = JSON(self.hashtagSubmissionsObjects)
            let _thisSubmission = _submission[indexPath.row]["properties"]
            
            if _thisSubmission == nil {
                emptyCell.emptyMessageAction.addTarget(self, action: #selector(self.openNewReportForm(_:)), forControlEvents: .TouchUpInside)
                emptyCell.emptyMessageDescription.text = "Looks like this group hasn't posted anything yet.  Join their group and share a report to get them started!"
                emptyCell.emptyMessageAction.hidden = false
                
                return emptyCell
            }

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
                cell.labelReportDescription.enabledTypes = [.Hashtag, .URL]
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
//            var reportImageURL:NSURL!
//            
//            if let thisReportImageURL = _thisSubmission["images"][0]["properties"]["square"].string {
//                reportImageURL = NSURL(string: String(thisReportImageURL))
//            }
//            
//            cell.reportImageView.kf_indicatorType = .Activity
//            cell.reportImageView.kf_showIndicatorWhenLoading = true
//            
//            cell.reportImageView.kf_setImageWithURL(reportImageURL, placeholderImage: nil, optionsInfo: nil, progressBlock: nil, completionHandler: {
//                (image, error, cacheType, imageUrl) in
//                
//                if (image != nil) {
//                    cell.reportImageView.image = UIImage(CGImage: (image?.CGImage)!, scale: (image?.scale)!, orientation: UIImageOrientation.Up)
//                }
//            })

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
                let badgeImage: UIImage = UIImage(named: "Icon--Comment")!
                cell.buttonReportComments.setImage(badgeImage, forState: .Normal)
                cell.buttonReportComments.imageView?.contentMode = .ScaleAspectFit
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
                
            }

            if (indexPath.row == self.hashtagSubmissionsObjects.count - 2 && self.hashtagSubmissionsObjects.count < self.hashtagSubmissions!["properties"]["num_results"].int) {
                self.attemptLoadHashtagSubmissions()
            }
            
            return cell
            
        }
        else if self.hashtagSelectedTab == "Actions" {
            
            print("ACTIONS TABLE")
            
            let cell = tableView.dequeueReusableCellWithIdentifier("hashtagActionCell", forIndexPath: indexPath) as! UserProfileActionsTableViewCell
            
            guard (self.hashtagActions != nil) else { return emptyCell }
            
            let _actions = JSON(self.hashtagActionsObjects)
            let _thisSubmission = _actions[indexPath.row]["properties"]
            print("Show _thisSubmission \(_thisSubmission)")
            
            if _thisSubmission == nil {
                
                emptyCell.emptyMessageAction.addTarget(self, action: #selector(self.openNewReportForm(_:)), forControlEvents: .TouchUpInside)
                emptyCell.emptyMessageDescription.text = "Looks like no actions have been taken yet."
                emptyCell.emptyMessageAction.hidden = true
                
                return emptyCell
            }
            
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
                cell.labelReportDescription.enabledTypes = [.Hashtag, .URL]
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
            
//            // Report > Image
//            //
//            //
//            // REPORT > IMAGE
//            //
//            var reportImageURL:NSURL!
//            
//            if let thisReportImageURL = _thisSubmission["images"][0]["properties"]["square"].string {
//                reportImageURL = NSURL(string: String(thisReportImageURL))
//            }
//            
//            cell.reportImageView.kf_indicatorType = .Activity
//            cell.reportImageView.kf_showIndicatorWhenLoading = true
//            
//            cell.reportImageView.kf_setImageWithURL(reportImageURL, placeholderImage: nil, optionsInfo: nil, progressBlock: nil, completionHandler: {
//                (image, error, cacheType, imageUrl) in
//                
//                if (image != nil) {
//                    cell.reportImageView.image = UIImage(CGImage: (image?.CGImage)!, scale: (image?.scale)!, orientation: UIImageOrientation.Up)
//                }
//            })
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
                let badgeImage: UIImage = UIImage(named: "Icon--Comment")!
                cell.buttonReportComments.setImage(badgeImage, forState: .Normal)
                cell.buttonReportComments.imageView?.contentMode = .ScaleAspectFit
            }
            
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
                
            }

            
            if (indexPath.row == self.hashtagActionsObjects.count - 2 && self.hashtagActionsObjects.count < self.hashtagActions!["properties"]["num_results"].int) {
                self.attemptLoadHashtagActions()
            }
            
            return cell
        }
        else if self.hashtagSelectedTab == "Groups" {
            
            let cell = tableView.dequeueReusableCellWithIdentifier("hashtagGroupCell", forIndexPath: indexPath) as! UserProfileGroupsTableViewCell
            
            guard (JSON(self.hashtagGroupsObjects) != nil) else { return emptyCell }
            
            // Display Group Name
            let _groups = JSON(self.hashtagGroupsObjects)
            
            if _groups[indexPath.row]["properties"] == nil {
                
                emptyCell.emptyMessageDescription.text = "Looks like no groups have used this hashtag. Be the agent of change!"
                emptyCell.emptyMessageAction.hidden = false
                
                return emptyCell
            }

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
            
            if (indexPath.row == self.hashtagGroupsObjects.count - 2 && self.hashtagGroupsObjects.count < self.hashtagGroups!["properties"]["num_results"].int) {
                self.attemptLoadHashtagGroups()
            }
            
            return cell

        }
        
        print("NO CELL SHOW THE EMPTY!!!!")

        return emptyCell
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
        
        if (self.hashtagSelectedTab == "Actions") {
            var _cell = self.tableView.cellForRowAtIndexPath(_indexPath) as! UserProfileActionsTableViewCell
            _report = JSON(self.hashtagActionsObjects[(indexPathRow)].objectForKey("properties")!)
            
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
        else if (self.hashtagSelectedTab == "Submissions") {
            var _cell = self.tableView.cellForRowAtIndexPath(_indexPath) as! UserProfileSubmissionTableViewCell
            _report = JSON(self.hashtagSubmissionsObjects[(indexPathRow)].objectForKey("properties")!)
            
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
            
            if (self.hashtagSelectedTab == "Actions") {
                _report = JSON(self.hashtagActionsObjects[(senderTag)])
            }
            else if (self.hashtagSelectedTab == "Submissions") {
                _report = JSON(self.hashtagSubmissionsObjects[(senderTag)])
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
            
            if (self.hashtagSelectedTab == "Actions") {
                _report = JSON(self.hashtagActionsObjects[(senderTag)])
            }
            else if (self.hashtagSelectedTab == "Submissions") {
                _report = JSON(self.hashtagSubmissionsObjects[(senderTag)])
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
                    
                    if (self.hashtagSelectedTab == "Actions") {
                        self.hashtagActionsObjects[(reportSenderTag)] = value
                    }
                    else if (self.hashtagSelectedTab == "Submissions") {
                        self.hashtagSubmissionsObjects[(reportSenderTag)] = value
                    }
                    else {
                        return;
                    }
                    
                    break
                case .Failure(let error):
                    print("Response Failure \(error)")
                    break
                    
                }
                
        }
        
    }    
}
