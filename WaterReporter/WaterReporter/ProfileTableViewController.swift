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
    @IBOutlet weak var buttonUserProfileSettings: UIBarButtonItem!
    @IBOutlet weak var imageViewUserProfileImage: UIImageView!
    @IBOutlet weak var labelUserProfileName: UILabel!
    @IBOutlet weak var labelUserProfileTitle: UILabel!
    @IBOutlet weak var labelUserProfileOrganizationName: UILabel!
    @IBOutlet weak var labelUserProfileDescription: UILabel!
    
    @IBOutlet weak var buttonUserProfileSubmissionCount: UIButton!
    @IBOutlet weak var buttonUserProfileSubmissionLabel: UIButton!
    @IBOutlet weak var buttonUserProfileActionCount: UIButton!
    @IBOutlet weak var buttonUserProfileActionLabel: UIButton!
    @IBOutlet weak var buttonUserProfileGroupCount: UIButton!
    @IBOutlet weak var buttonUserProfileGroupLabel: UIButton!

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
            
            //
            // Restyle the form Log In Navigation button to appear with an underline
            //
            let buttonWidth = self.buttonUserProfileActionLabel.frame.width*0.6
            let borderWidth = buttonWidth
            
            self.userActionsUnderline.borderColor = CGColor.colorBrand()
            self.userActionsUnderline.borderWidth = 3.0
            self.userActionsUnderline.frame = CGRectMake(self.buttonUserProfileActionLabel.frame.width*0.2, self.buttonUserProfileActionLabel.frame.size.height - 3.0, borderWidth, self.buttonUserProfileActionLabel.frame.size.height)
            
            self.buttonUserProfileActionLabel.layer.addSublayer(self.userActionsUnderline)
            self.buttonUserProfileActionLabel.layer.masksToBounds = true
            
            self.userGroupsUnderline.removeFromSuperlayer()
            self.userSubmissionsUnderline.removeFromSuperlayer()
            
        } else if (sender.restorationIdentifier == "buttonTabGroupNumber" || sender.restorationIdentifier == "buttonTabGroupLabel") {
            
            print("Show the Groups tab")
            self.actionsTableView.hidden = true
            self.submissionTableView.hidden = true
            self.groupsTableView.hidden = false
            
            //
            // Restyle the form Log In Navigation button to appear with an underline
            //
            let buttonWidth = self.buttonUserProfileGroupLabel.frame.width*0.6
            let borderWidth = buttonWidth
            
            self.userGroupsUnderline.borderColor = CGColor.colorBrand()
            self.userGroupsUnderline.borderWidth = 3.0
            self.userGroupsUnderline.frame = CGRectMake(self.buttonUserProfileGroupLabel.frame.width*0.2, self.buttonUserProfileGroupLabel.frame.size.height - 3.0, borderWidth, self.buttonUserProfileGroupLabel.frame.size.height)
            
            self.buttonUserProfileGroupLabel.layer.addSublayer(self.userGroupsUnderline)
            self.buttonUserProfileGroupLabel.layer.masksToBounds = true

            self.userActionsUnderline.removeFromSuperlayer()
            self.userSubmissionsUnderline.removeFromSuperlayer()

        } else if (sender.restorationIdentifier == "buttonTabSubmissionNumber" || sender.restorationIdentifier == "buttonTabSubmissionLabel") {
            
            print("Show the Subsmissions tab")
            self.actionsTableView.hidden = true
            self.submissionTableView.hidden = false
            self.groupsTableView.hidden = true
            
            //
            // Restyle the form Log In Navigation button to appear with an underline
            //
            let buttonWidth = self.buttonUserProfileSubmissionLabel.frame.width*0.8
            let borderWidth = buttonWidth
            
            self.userSubmissionsUnderline.borderColor = CGColor.colorBrand()
            self.userSubmissionsUnderline.borderWidth = 3.0
            self.userSubmissionsUnderline.frame = CGRectMake(self.buttonUserProfileSubmissionLabel.frame.width*0.1, self.buttonUserProfileSubmissionLabel.frame.size.height - 3.0, borderWidth, self.buttonUserProfileSubmissionLabel.frame.size.height)
            
            self.buttonUserProfileSubmissionLabel.layer.addSublayer(self.userSubmissionsUnderline)
            self.buttonUserProfileSubmissionLabel.layer.masksToBounds = true

            self.userGroupsUnderline.removeFromSuperlayer()
            self.userActionsUnderline.removeFromSuperlayer()

            
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
    
    @IBAction func openUserSubmissionDirectionsURL(sender: UIButton) {
        
        let _submissions = JSON(self.userSubmissionsObjects)
        let reportCoordinates = _submissions[sender.tag]["geometry"]["geometries"][0]["coordinates"]
        
        UIApplication.sharedApplication().openURL(NSURL(string: "https://www.google.com/maps/dir//\(reportCoordinates[1]),\(reportCoordinates[0])")!)
    }

    @IBAction func shareSubmissionsButtonClicked(sender: UIButton) {
        
        let _submissions = JSON(self.userSubmissionsObjects)
        let reportId: String = "\(_submissions[sender.tag]["id"])"
        let textToShare = "Check out this report on WaterReporter.org"
        
        if let myWebsite = NSURL(string: "https://www.waterreporter.org/reports/" + reportId) {
            let objectsToShare = [textToShare, myWebsite]
            let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
            
            activityVC.popoverPresentationController?.sourceView = sender
            self.presentViewController(activityVC, animated: true, completion: nil)
        }
    }
    
    @IBAction func shareActionsButtonClicked(sender: UIButton) {
        
        let _actions = JSON(self.userActionsObjects)
        let reportId: String = "\(_actions[sender.tag]["id"])"
        let textToShare = "Check out this report on WaterReporter.org"
        
        if let myWebsite = NSURL(string: "https://www.waterreporter.org/reports/" + reportId) {
            let objectsToShare = [textToShare, myWebsite]
            let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
            
            activityVC.popoverPresentationController?.sourceView = sender
            self.presentViewController(activityVC, animated: true, completion: nil)
        }
    }

    @IBAction func openUserSubmissionMapView(sender: UIButton) {
        let nextViewController = self.storyBoard.instantiateViewControllerWithIdentifier("ActivityMapViewController") as! ActivityMapViewController
        
        nextViewController.reportObject = self.userSubmissionsObjects[sender.tag]
        
        self.navigationController?.pushViewController(nextViewController, animated: true)
        
    }
    
    @IBAction func openUserSubmissionCommentsView(sender: UIButton) {
        let nextViewController = self.storyBoard.instantiateViewControllerWithIdentifier("CommentsTableViewController") as! CommentsTableViewController
        
        nextViewController.report = self.userSubmissionsObjects[sender.tag]
        
        self.navigationController?.pushViewController(nextViewController, animated: true)
        
    }
    
    @IBAction func openUserActionMapView(sender: UIButton) {
        let nextViewController = self.storyBoard.instantiateViewControllerWithIdentifier("ActivityMapViewController") as! ActivityMapViewController
        
        nextViewController.reportObject = self.userActionsObjects[sender.tag]
        
        self.navigationController?.pushViewController(nextViewController, animated: true)
        
    }

    @IBAction func openUserActionCommentsView(sender: UIButton) {
        let nextViewController = self.storyBoard.instantiateViewControllerWithIdentifier("CommentsTableViewController") as! CommentsTableViewController
        
        nextViewController.report = self.userActionsObjects[sender.tag]
        
        self.navigationController?.pushViewController(nextViewController, animated: true)
        
    }  

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

    var userGroups: JSON?
    var userGroupsObjects = [AnyObject]()
    var userGroupsPage: Int = 1
    var groupsRefreshControl: UIRefreshControl = UIRefreshControl()

    var userSubmissions: JSON?
    var userSubmissionsObjects = [AnyObject]()
    var userSubmissionsPage: Int = 1
    var submissionRefreshControl: UIRefreshControl = UIRefreshControl()

    var userActions: JSON?
    var userActionsObjects = [AnyObject]()
    var userActionsPage: Int = 1
    var actionRefreshControl: UIRefreshControl = UIRefreshControl()

    var userGroupsUnderline = CALayer()
    var userSubmissionsUnderline = CALayer()
    var userActionsUnderline = CALayer()
    
    //
    // MARK: UIKit Overrides
    //
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Check to see if a user id was passed to this view from
        // another view. If no user id was passed, then we know that
        // we should be displaying the acting user's profile

        if (self.userId == nil) {
            if let userIdNumber = NSUserDefaults.standardUserDefaults().objectForKey("currentUserAccountUID") as? NSNumber {
                self.userId = "\(userIdNumber)"
            } else {
                self.attemptRetrieveUserID()
            }
        }
        
        // Show User Profile Information in Header View
        if userObject != nil {
            
            // Retain the returned data
            self.userProfile = self.userObject
            
            print("User Profile \(self.userProfile)")
            
            if let _first_name = self.userProfile!["properties"]["first_name"].string,
                let _last_name = self.userProfile!["properties"]["last_name"].string {
                self.navigationItem.title = _first_name + " " + _last_name
            }
            
            self.navigationItem.rightBarButtonItem?.enabled = false

            
            // Show the data on screen
            self.displayUserProfileInformation()
            
        }
        else {
            self.attemptLoadUserProfile()
        }

        //
        //
        //
        // Set dynamic row heights
        self.submissionTableView.rowHeight = UITableViewAutomaticDimension;
        self.submissionTableView.estimatedRowHeight = 368.0;
        
        self.actionsTableView.rowHeight = UITableViewAutomaticDimension;
        self.actionsTableView.estimatedRowHeight = 368.0;

        //
        //
        //
        self.labelUserProfileTitle.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(ProfileTableViewController.toggleUILableNumberOfLines(_:))))
        
        self.labelUserProfileOrganizationName.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(ProfileTableViewController.toggleUILableNumberOfLines(_:))))
        
        self.labelUserProfileDescription.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(ProfileTableViewController.toggleUILableNumberOfLines(_:))))
        
        
        //
        // SETUP SUBMISSION TABLE
        //
        self.submissionTableView.delegate = self
        self.submissionTableView.dataSource = self
        
        submissionRefreshControl = UIRefreshControl()
        submissionRefreshControl.restorationIdentifier = "submissionRefreshControl"
        
        submissionRefreshControl.addTarget(self, action: #selector(ProfileTableViewController.refreshSubsmissionsTableView(_:)), forControlEvents: .ValueChanged)
        
        submissionTableView.addSubview(submissionRefreshControl)
        
        
        //
        // SETUP SUBMISSION TABLE
        //
        
        self.actionsTableView.delegate = self
        self.actionsTableView.dataSource = self
        
        actionRefreshControl = UIRefreshControl()
        actionRefreshControl.restorationIdentifier = "actionRefreshControl"
        
        actionRefreshControl.addTarget(self, action: #selector(ProfileTableViewController.refreshActionsTableView(_:)), forControlEvents: .ValueChanged)
        
        actionsTableView.addSubview(actionRefreshControl)
        
        
        //
        // SETUP SUBMISSION TABLE
        //
        
        self.groupsTableView.delegate = self
        self.groupsTableView.dataSource = self
        
        groupsRefreshControl = UIRefreshControl()
        groupsRefreshControl.restorationIdentifier = "groupRefreshControl"
        
        groupsRefreshControl.addTarget(self, action: #selector(ProfileTableViewController.refreshGroupsTableView(_:)), forControlEvents: .ValueChanged)
        
        groupsTableView.addSubview(groupsRefreshControl)
        
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
    func refreshSubsmissionsTableView(sender: UIRefreshControl) {
        
        self.userSubmissionsPage = 1
        self.userSubmissions = nil
        self.userSubmissionsObjects = []

        self.attemptLoadUserSubmissions(true)

    }
    
    func refreshActionsTableView(sender: UIRefreshControl) {
        
        self.userActionsPage = 1
        self.userActions = nil
        self.userActionsObjects = []
        
        self.attemptLoadUserActions(true)

    }
    
    func refreshGroupsTableView(sender: UIRefreshControl) {

        self.userGroupsPage = 1
        self.userGroups = nil
        self.userGroupsObjects = []
        
        self.attemptLoadUserGroups(true)

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

        // Display user's profile picture
        var userProfileImageURL: NSURL!

        if let thisUserProfileImageURLString = self.userProfile!["properties"]["picture"].string {
            userProfileImageURL = NSURL(string: String(thisUserProfileImageURLString))
        }
        
        self.imageViewUserProfileImage.kf_indicatorType = .Activity
        self.imageViewUserProfileImage.kf_showIndicatorWhenLoading = true
        
        self.imageViewUserProfileImage.kf_setImageWithURL(userProfileImageURL, placeholderImage: nil, optionsInfo: nil, progressBlock: nil, completionHandler: {
            (image, error, cacheType, imageUrl) in
            if (image != nil) {
                self.imageViewUserProfileImage.image = UIImage(CGImage: (image?.CGImage)!, scale: (image?.scale)!, orientation: UIImageOrientation.Up)
            }
            self.imageViewUserProfileImage.clipsToBounds = true
        })
        
        
        //
        // Load and display other user information
        //
        self.attemptLoadUserGroups()
        
        self.attemptLoadUserSubmissions()

        self.attemptLoadUserActions()


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

    func attemptLoadUserProfile() {
        
        let _headers = buildRequestHeaders()

        let revisedEndpoint = Endpoints.GET_USER_PROFILE + "\(userId)"
        
        print("revisedEndpoint \(revisedEndpoint)")
        
        Alamofire.request(.GET, revisedEndpoint, headers: _headers, encoding: .JSON).responseJSON { response in
            
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
                        self.attemptLoadUserProfile()
                        
                    }
                    
                case .Failure(let error):
                    print(error)
                }
        }
    }
    
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
                
                // Assign response to groups variable
                if (isRefreshingReportsList) {
                    self.userGroups = JSON(value)
                    self.userGroupsObjects = value["features"] as! [AnyObject]
                    self.groupsRefreshControl.endRefreshing()
                } else {
                    self.userGroups = JSON(value)
                    self.userGroupsObjects += value["features"] as! [AnyObject]
                    
                }
                
                // Set the number on the profile page
                let _group_count = self.userGroups!["properties"]["num_results"]
                
                if (_group_count != "") {
                    self.buttonUserProfileGroupCount.setTitle("\(_group_count)", forState: .Normal)
                }

                // Refresh the data in the table so the newest items appear
                self.groupsTableView.reloadData()
                
                self.userGroupsPage += 1
                
                break
            case .Failure(let error):
                print("Request Failure: \(error)")
                
                // Stop showing the loading indicator
                //self.status("doneLoadingWithError")
                
                break
            }
        }

    }
    
    func attemptLoadUserSubmissions(isRefreshingReportsList: Bool = false) {
        
        let _parameters = [
            "q": "{\"filters\":[{\"name\":\"owner_id\",\"op\":\"eq\",\"val\":\"\(self.userId)\"}],\"order_by\": [{\"field\":\"report_date\",\"direction\":\"desc\"},{\"field\":\"id\",\"direction\":\"desc\"}]}",
            "page": "\(self.userSubmissionsPage)"
        ]
        
        Alamofire.request(.GET, Endpoints.GET_MANY_REPORTS, parameters: _parameters)
            .responseJSON { response in
                
                switch response.result {
                case .Success(let value):
                    
                    print("Response Success: value")
                    
                    if (isRefreshingReportsList) {
                        // Assign response to groups variable
                        self.userSubmissions = JSON(value)
                        self.userSubmissionsObjects = value["features"] as! [AnyObject]
                        self.submissionRefreshControl.endRefreshing()
                    } else {
                        // Assign response to groups variable
                        self.userSubmissions = JSON(value)
                        self.userSubmissionsObjects += value["features"] as! [AnyObject]
                    }
                    
                    // Set visible button count
                    let _submission_count = self.userSubmissions!["properties"]["num_results"]
                    
                    if (_submission_count != "") {
                        self.buttonUserProfileSubmissionCount.setTitle("\(_submission_count)", forState: .Normal)
                    }
                    
                    // Refresh the data in the table so the newest items appear
                    self.submissionTableView.reloadData()
                    
                    self.userSubmissionsPage += 1
                    
                    break
                case .Failure(let error):
                    print("Request Failure: \(error)")
                    
                    // Stop showing the loading indicator
                    //self.status("doneLoadingWithError")
                    
                    break
                }
                
        }
        
    }

    
    func attemptLoadUserActions(isRefreshingReportsList: Bool = false) {
        
        let _parameters = [
            "q": "{\"filters\":[{\"name\":\"owner_id\",\"op\":\"eq\",\"val\":\"\(userId!)\"},{\"name\":\"closed_id\", \"op\":\"eq\", \"val\":\"\(userId!)\"}],\"order_by\": [{\"field\":\"report_date\",\"direction\":\"desc\"},{\"field\":\"id\",\"direction\":\"desc\"}]}",
            "page": "\(self.userActionsPage)"
        ]
        
        Alamofire.request(.GET, Endpoints.GET_MANY_REPORTS, parameters: _parameters)
            .responseJSON { response in
                
                switch response.result {
                case .Success(let value):
                    print("Request Success \(Endpoints.GET_MANY_REPORTS) \(value)")
                    
                    if (isRefreshingReportsList) {
                        // Assign response to groups variable
                        self.userActions = JSON(value)
                        self.userActionsObjects = value["features"] as! [AnyObject]
                        self.actionRefreshControl.endRefreshing()
                    } else {
                        // Assign response to groups variable
                        self.userActions = JSON(value)
                        self.userActionsObjects += value["features"] as! [AnyObject]
                    }

                    // Set visible button count
                    let _action_count = self.userActions!["properties"]["num_results"]
                    
                    if (_action_count >= 1) {
                        self.buttonUserProfileActionCount.setTitle("\(_action_count)", forState: .Normal)
                    }
                    
                    // Refresh the data in the table so the newest items appear
                    self.actionsTableView.reloadData()
                    
                    self.userActionsPage += 1
                    
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
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if (tableView.restorationIdentifier == "submissionsTableView") {
            
            guard (JSON(self.userSubmissionsObjects) != nil) else { return 0 }
            
            return (self.userSubmissionsObjects.count)

        } else if (tableView.restorationIdentifier == "actionsTableView") {

            guard (JSON(self.userActionsObjects) != nil) else { return 0 }
            
            return (self.userActionsObjects.count)
        
        } else if (tableView.restorationIdentifier == "groupsTableView") {
            
            guard (JSON(self.userGroupsObjects) != nil) else { return 0 }
            
            return (self.userGroupsObjects.count)

        } else {
            return 0
        }
        
    }
    
//    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
//        if (tableView.restorationIdentifier == "submissionsTableView") {
//            return 44.0
//        } else if (tableView.restorationIdentifier == "actionsTableView") {
//            return 44.0
//        } else if (tableView.restorationIdentifier == "groupsTableView") {
//            return 72.0
//        } else {
//            return 44.0
//        }
//    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if (tableView.restorationIdentifier == "submissionsTableView") {
            //
            // Submissions
            //
            let cell = tableView.dequeueReusableCellWithIdentifier("userProfileSubmissionCell", forIndexPath: indexPath) as! UserProfileSubmissionTableViewCell
            
            let _submissions = JSON(self.userSubmissionsObjects)
            guard (_submissions != nil) else { return cell }
            
            let _thisSubmission = _submissions[indexPath.row]["properties"]
            
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
            cell.labelReportDescription.text = "\(_thisSubmission["report_description"])"
            
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
                let badgeImage: UIImage = UIImage(named: "Icon--Comment")!
                cell.buttonReportComments.setImage(badgeImage, forState: .Normal)
                cell.buttonReportComments.imageView?.contentMode = .ScaleAspectFit
            }

            //
            // CONTIUOUS SCROLL
            //
            if (indexPath.row == self.userSubmissionsObjects.count - 2 && self.userSubmissionsObjects.count < self.userSubmissions!["properties"]["num_results"].int) {
                self.attemptLoadUserSubmissions()
            }

            
            return cell
        } else if (tableView.restorationIdentifier == "actionsTableView") {
            //
            // Actions
            //
            let cell = tableView.dequeueReusableCellWithIdentifier("userProfileActionCell", forIndexPath: indexPath) as! UserProfileActionsTableViewCell
            
            guard (self.userActions != nil) else { return cell }
            
            let _actions = JSON(self.userActionsObjects)
            let _thisSubmission = _actions[indexPath.row]["properties"]
            print("Show _thisSubmission \(_thisSubmission)")
            
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
            cell.labelReportDescription.text = "\(_thisSubmission["report_description"])"
            
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
                let badgeImage: UIImage = UIImage(named: "Icon--Comment")!
                cell.buttonReportComments.setImage(badgeImage, forState: .Normal)
                cell.buttonReportComments.imageView?.contentMode = .ScaleAspectFit
            }
            
            if (indexPath.row == self.userActionsObjects.count - 2 && self.userActionsObjects.count < self.userActions!["properties"]["num_results"].int) {
                self.attemptLoadUserActions()
            }

            return cell
        } else if (tableView.restorationIdentifier == "groupsTableView") {
            //
            // Groups
            //
            let cell = tableView.dequeueReusableCellWithIdentifier("userProfileGroupCell", forIndexPath: indexPath) as! UserProfileGroupsTableViewCell
            
            guard (JSON(self.userGroupsObjects) != nil) else { return cell }
            
            // Display Group Name
            let _groups = JSON(self.userGroupsObjects)
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
        } else {
            return UITableViewCell()
        }
        
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        print("row tapped \(indexPath)")
    }
    

}
