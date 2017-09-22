//
//  OrganizationTableViewController.swift
//
//  Created by Viable Industries on 11/6/16.
//  Copyright © 2016 Viable Industries, L.L.C. All rights reserved.
//

import Alamofire
import Foundation
import SwiftyJSON
import UIKit

class OrganizationTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UINavigationControllerDelegate {
    
    
    //
    // @IBOUTLETS
    //
    @IBOutlet weak var imageViewGroupProfileImage: UIImageView!
    
    @IBOutlet weak var labelGroupProfileName: UILabel!
    @IBOutlet weak var labelGroupProfileDescription: UILabel!
    
    @IBOutlet weak var buttonGroupProfileSubmissionsCount: UIButton!
    @IBOutlet weak var buttonGroupProfileSubmissionsLabel: UIButton!
    @IBOutlet weak var buttonGroupProfileActionsCount: UIButton!
    @IBOutlet weak var buttonGroupProfileActionsLabel: UIButton!
    @IBOutlet weak var buttonGroupProfileUsersCount: UIButton!
    @IBOutlet weak var buttonGroupProfileUsersLabel: UIButton!

    @IBOutlet weak var submissionTableView: UITableView!
    @IBOutlet weak var actionTableView: UITableView!
    @IBOutlet weak var memberTableView: UITableView!
    
    
    //
    // MARK: @IBActions
    //
    @IBAction func openSubmissionOpenGraphURL(sender: UIButton) {
        
        let reportId = sender.tag
        let report = JSON(self.groupSubmissionsObjects[reportId])
        
        let reportURL = "\(report["properties"]["social"][0]["properties"]["og_url"])"
        
        print("openOpenGraphURL \(reportURL)")
        
        UIApplication.sharedApplication().openURL(NSURL(string: "\(reportURL)")!)
    }
    
    @IBAction func openActionsOpenGraphURL(sender: UIButton) {
        
        let reportId = sender.tag
        let report = JSON(self.groupActionsObjects[reportId])
        
        let reportURL = "\(report["properties"]["social"][0]["properties"]["og_url"])"
        
        print("openOpenGraphURL \(reportURL)")
        
        UIApplication.sharedApplication().openURL(NSURL(string: "\(reportURL)")!)
    }

    @IBAction func changeGroupProfileTab(sender: UIButton) {
        
        if (sender.restorationIdentifier == "buttonTabActionNumber" || sender.restorationIdentifier == "buttonTabActionLabel") {
            
            print("Show the Actions tab")
            self.actionTableView.hidden = false
            self.submissionTableView.hidden = true
            self.memberTableView.hidden = true
            
            //
            // Restyle the form Log In Navigation button to appear with an underline
            //
            let buttonWidth = self.buttonGroupProfileActionsLabel.frame.width*0.6
            let borderWidth = buttonWidth
            
            self.groupActionsUnderline.borderColor = CGColor.colorBrand()
            self.groupActionsUnderline.borderWidth = 3.0
            self.groupActionsUnderline.frame = CGRectMake(self.buttonGroupProfileActionsLabel.frame.width*0.2, self.buttonGroupProfileActionsLabel.frame.size.height - 3.0, borderWidth, self.buttonGroupProfileActionsLabel.frame.size.height)
            
            self.buttonGroupProfileActionsLabel.layer.addSublayer(self.groupActionsUnderline)
            self.buttonGroupProfileActionsLabel.layer.masksToBounds = true
            
            self.groupUsersUnderline.removeFromSuperlayer()
            self.groupSubmissionsUnderline.removeFromSuperlayer()
            
        } else if (sender.restorationIdentifier == "buttonTabGroupNumber" || sender.restorationIdentifier == "buttonTabGroupLabel") {
            
            print("Show the Groups tab")
            self.actionTableView.hidden = true
            self.submissionTableView.hidden = true
            self.memberTableView.hidden = false
            
            //
            // Restyle the form Log In Navigation button to appear with an underline
            //
            let buttonWidth = self.buttonGroupProfileUsersLabel.frame.width*0.6
            let borderWidth = buttonWidth
            
            self.groupUsersUnderline.borderColor = CGColor.colorBrand()
            self.groupUsersUnderline.borderWidth = 3.0
            self.groupUsersUnderline.frame = CGRectMake(self.buttonGroupProfileUsersLabel.frame.width*0.2, self.buttonGroupProfileUsersLabel.frame.size.height - 3.0, borderWidth, self.buttonGroupProfileUsersLabel.frame.size.height)
            
            self.buttonGroupProfileUsersLabel.layer.addSublayer(self.groupUsersUnderline)
            self.buttonGroupProfileUsersLabel.layer.masksToBounds = true
            
            self.groupActionsUnderline.removeFromSuperlayer()
            self.groupSubmissionsUnderline.removeFromSuperlayer()
            
        } else if (sender.restorationIdentifier == "buttonTabSubmissionNumber" || sender.restorationIdentifier == "buttonTabSubmissionLabel") {
            
            print("Show the Subsmissions tab")
            self.actionTableView.hidden = true
            self.submissionTableView.hidden = false
            self.memberTableView.hidden = true
            
            //
            // Restyle the form Log In Navigation button to appear with an underline
            //
            let buttonWidth = self.buttonGroupProfileSubmissionsLabel.frame.width*0.8
            let borderWidth = buttonWidth
            
            self.groupSubmissionsUnderline.borderColor = CGColor.colorBrand()
            self.groupSubmissionsUnderline.borderWidth = 3.0
            self.groupSubmissionsUnderline.frame = CGRectMake(self.buttonGroupProfileSubmissionsLabel.frame.width*0.1, self.buttonGroupProfileSubmissionsLabel.frame.size.height - 3.0, borderWidth, self.buttonGroupProfileSubmissionsLabel.frame.size.height)
            
            self.buttonGroupProfileSubmissionsLabel.layer.addSublayer(self.groupSubmissionsUnderline)
            self.buttonGroupProfileSubmissionsLabel.layer.masksToBounds = true
            
            self.groupUsersUnderline.removeFromSuperlayer()
            self.groupActionsUnderline.removeFromSuperlayer()
            
            
        }
        
    }
    
    @IBAction func toggleUILableNumberOfLines(sender: UITapGestureRecognizer) {
        
        let field: UILabel = sender.view as! UILabel
        
        switch field.numberOfLines {
        case 0:
            if sender.view?.restorationIdentifier == "labelGroupProfileDescription" {
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
        
        let _submissions = JSON(self.groupSubmissionsObjects)
        let reportCoordinates = _submissions[sender.tag]["geometry"]["geometries"][0]["coordinates"]
        
        UIApplication.sharedApplication().openURL(NSURL(string: "https://www.google.com/maps/dir//\(reportCoordinates[1]),\(reportCoordinates[0])")!)
    }

    @IBAction func openUserActionDirectionsURL(sender: UIButton) {
        
        let _actions = JSON(self.groupActionsObjects)
        let reportCoordinates = _actions[sender.tag]["geometry"]["geometries"][0]["coordinates"]
        
        UIApplication.sharedApplication().openURL(NSURL(string: "https://www.google.com/maps/dir//\(reportCoordinates[1]),\(reportCoordinates[0])")!)
    }

    @IBAction func shareSubmissionsButtonClicked(sender: UIButton) {
        
        let _submissions = JSON(self.groupSubmissionsObjects)
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
        
        let _actions = JSON(self.groupActionsObjects)
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
        
        nextViewController.reportObject = self.groupSubmissionsObjects[sender.tag]
        
        self.navigationController?.pushViewController(nextViewController, animated: true)
        
    }
    
    @IBAction func openUserSubmissionCommentsView(sender: UIButton) {
        let nextViewController = self.storyBoard.instantiateViewControllerWithIdentifier("CommentsTableViewController") as! CommentsTableViewController
        
        nextViewController.report = self.groupSubmissionsObjects[sender.tag]
        
        self.navigationController?.pushViewController(nextViewController, animated: true)
        
    }
    
    @IBAction func openUserActionMapView(sender: UIButton) {
        let nextViewController = self.storyBoard.instantiateViewControllerWithIdentifier("ActivityMapViewController") as! ActivityMapViewController
        
        nextViewController.reportObject = self.groupActionsObjects[sender.tag]
        
        self.navigationController?.pushViewController(nextViewController, animated: true)
        
    }
    
    @IBAction func openUserActionCommentsView(sender: UIButton) {
        let nextViewController = self.storyBoard.instantiateViewControllerWithIdentifier("CommentsTableViewController") as! CommentsTableViewController
        
        nextViewController.report = self.groupActionsObjects[sender.tag]
        
        self.navigationController?.pushViewController(nextViewController, animated: true)
        
    }
    
    @IBAction func openUserMemberView(sender: UIButton) {
        let nextViewController = self.storyBoard.instantiateViewControllerWithIdentifier("ProfileTableViewController") as! ProfileTableViewController
        
        let _members = JSON(self.groupMembersObjects)
        nextViewController.userId = "\(_members[sender.tag]["id"])"
        nextViewController.userObject = _members[sender.tag]
        
        self.navigationController?.pushViewController(nextViewController, animated: true)
        
    }

    @IBAction func loadTerritoryProfileFromSubmissions(sender: UIButton) {
        
        let nextViewController = self.storyBoard.instantiateViewControllerWithIdentifier("TerritoryViewController") as! TerritoryViewController
        
        var _thisReport: JSON!
        
        _thisReport = JSON(self.groupSubmissionsObjects[(sender.tag)])
        
        if "\(_thisReport["properties"]["territory_id"])" != "" && "\(_thisReport["properties"]["territory_id"])" != "null" {
            nextViewController.territory = "\(_thisReport["properties"]["territory"]["properties"]["huc_8_name"])"
            nextViewController.territoryId = "\(_thisReport["properties"]["territory_id"])"
            nextViewController.territoryHUC8Code = "\(_thisReport["properties"]["territory"]["properties"]["huc_8_code"])"
            
            self.navigationController?.pushViewController(nextViewController, animated: true)
        }
    }
    
    @IBAction func loadTerritoryProfileFromActions(sender: UIButton) {
        
        let nextViewController = self.storyBoard.instantiateViewControllerWithIdentifier("TerritoryViewController") as! TerritoryViewController
        
        var _thisReport: JSON!
        
        _thisReport = JSON(self.groupActionsObjects[(sender.tag)])
        
        if "\(_thisReport["properties"]["territory_id"])" != "" && "\(_thisReport["properties"]["territory_id"])" != "null" {
            nextViewController.territory = "\(_thisReport["properties"]["territory"]["properties"]["huc_8_name"])"
            nextViewController.territoryId = "\(_thisReport["properties"]["territory_id"])"
            nextViewController.territoryHUC8Code = "\(_thisReport["properties"]["territory"]["properties"]["huc_8_code"])"
            
            self.navigationController?.pushViewController(nextViewController, animated: true)
        }
    }

    @IBAction func emptyMessageAddReport(sender: UIButton) {
        
        self.tabBarController?.selectedIndex = 2
        
    }
    
    @IBAction func emptyMessageUpdateProfile(sender: UIButton) {
        
        let nextViewController = self.storyBoard.instantiateViewControllerWithIdentifier("UserProfileEditTableViewController") as! UserProfileEditTableViewController
        
        self.navigationController?.pushViewController(nextViewController, animated: true)
        
    }
    
    @IBAction func emptyMessageJoinGroup(sender: UIButton) {
        
        let nextViewController = self.storyBoard.instantiateViewControllerWithIdentifier("GroupsTableViewController") as! GroupsTableViewController
        
        self.navigationController?.pushViewController(nextViewController, animated: true)
        
    }

    @IBAction func openNewReportForm(sender: UIButton){
        self.tabBarController?.selectedIndex = 2
    }

    //
    // MARK: Variables
    //
    let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
    
    var groupId: String!
    var groupObject: JSON?
    var groupProfile: JSON?
    
    var groupMembers: JSON?
    var groupMembersObjects = [AnyObject]()
    var groupMembersPage: Int = 1
    var groupMembersRefreshControl: UIRefreshControl = UIRefreshControl()

    var groupSubmissions: JSON?
    var groupSubmissionsObjects = [AnyObject]()
    var groupSubmissionsPage: Int = 1
    var groupSubmissionsRefreshControl: UIRefreshControl = UIRefreshControl()
    
    var groupActions: JSON?
    var groupActionsObjects = [AnyObject]()
    var groupActionsPage: Int = 1
    var groupActionsRefreshControl: UIRefreshControl = UIRefreshControl()
    
    var groupSubmissionsUnderline = CALayer()
    var groupActionsUnderline = CALayer()
    var groupUsersUnderline = CALayer()
    
    var likeDelay: NSTimer = NSTimer()
    var unlikeDelay: NSTimer = NSTimer()

    //
    // MARK: UIKit Overrides
    //
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if groupObject != nil && self.groupProfile == nil {
            self.groupProfile = self.groupObject
            
            print("Group Profile \(self.groupProfile)")
            
            // Show the Group Name as the title
            self.navigationItem.title = "Group Profile"
            
            // Show the group profile data on screen
            self.displayGroupProfileInformation()
        }
        else if groupObject != nil && self.groupProfile != nil {
            
            print("Group Profile \(self.groupProfile!)")
            
            // Show the Group Name as the title
            self.navigationItem.title = "Group Profile"
            
            // Show the group profile data on screen
            self.displayGroupProfileInformation()
        }
        
        
        // Set dynamic row heights
        self.submissionTableView.rowHeight = UITableViewAutomaticDimension;
        self.submissionTableView.estimatedRowHeight = 368.0;
        
        self.actionTableView.rowHeight = UITableViewAutomaticDimension;
        self.actionTableView.estimatedRowHeight = 368.0;

        self.memberTableView.rowHeight = UITableViewAutomaticDimension;
        self.memberTableView.estimatedRowHeight = 368.0;

        //
        //
        //
        self.labelGroupProfileDescription.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(OrganizationTableViewController.toggleUILableNumberOfLines(_:))))
        
        
        //
        // SETUP SUBMISSION TABLE
        //
        self.submissionTableView.delegate = self
        self.submissionTableView.dataSource = self
        
        groupSubmissionsRefreshControl.restorationIdentifier = "submissionRefreshControl"
        groupSubmissionsRefreshControl.addTarget(self, action: #selector(OrganizationTableViewController.refreshSubmissionsTableView(_:)), forControlEvents: .ValueChanged)
        
        self.submissionTableView.addSubview(groupSubmissionsRefreshControl)
        
        
        //
        // SETUP SUBMISSION TABLE
        //
        self.actionTableView.delegate = self
        self.actionTableView.dataSource = self
        
        groupActionsRefreshControl.restorationIdentifier = "actionRefreshControl"
        groupActionsRefreshControl.addTarget(self, action: #selector(OrganizationTableViewController.refreshactionTableView(_:)), forControlEvents: .ValueChanged)
        
        self.actionTableView.addSubview(groupActionsRefreshControl)
        
        
        //
        // SETUP SUBMISSION TABLE
        //
        self.memberTableView.delegate = self
        self.memberTableView.dataSource = self
        
        groupMembersRefreshControl.restorationIdentifier = "groupRefreshControl"
        groupMembersRefreshControl.addTarget(self, action: #selector(OrganizationTableViewController.refreshMembersTableView(_:)), forControlEvents: .ValueChanged)
        
        self.memberTableView.addSubview(groupMembersRefreshControl)
        
        // Make sure we are getting 'auto layout' specific sizes
        // otherwise any math we do will be messed up
        self.view.setNeedsLayout()
        self.view.layoutIfNeeded()
        
        
        // SET THE DEFAULT TAB
        //
        self.actionTableView.hidden = true
        self.submissionTableView.hidden = false
        self.memberTableView.hidden = true
        
        //
        // Restyle the form Log In Navigation button to appear with an underline
        //
        let buttonWidth = self.buttonGroupProfileSubmissionsLabel.frame.width*0.8
        let borderWidth = buttonWidth
        
        self.groupSubmissionsUnderline.borderColor = CGColor.colorBrand()
        self.groupSubmissionsUnderline.borderWidth = 3.0
        self.groupSubmissionsUnderline.frame = CGRectMake(self.buttonGroupProfileSubmissionsLabel.frame.width*0.1, self.buttonGroupProfileSubmissionsLabel.frame.size.height - 3.0, borderWidth, self.buttonGroupProfileSubmissionsLabel.frame.size.height)
        
        self.buttonGroupProfileSubmissionsLabel.layer.addSublayer(self.groupSubmissionsUnderline)
        self.buttonGroupProfileSubmissionsLabel.layer.masksToBounds = true
        
        self.groupUsersUnderline.removeFromSuperlayer()
        self.groupActionsUnderline.removeFromSuperlayer()
        
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
    // MARK: Custom Functionality
    //
    func refreshSubmissionsTableView(sender: UIRefreshControl) {
        
        self.groupSubmissionsPage = 1
        self.groupSubmissions = nil
        self.groupSubmissionsObjects = []
        
        self.attemptLoadGroupSubmissions(true)
    }

    func refreshactionTableView(sender: UIRefreshControl) {
        
        self.groupActionsPage = 1
        self.groupActions = nil
        self.groupActionsObjects = []
        
        self.attemptLoadGroupActions(true)
    }

    func refreshMembersTableView(sender: UIRefreshControl) {
        
        self.groupMembersPage = 1
        self.groupMembers = nil
        self.groupMembersObjects = []
        
        self.attemptLoadGroupUsers(true)
    }

    func displayGroupProfileInformation() {
        
        // Ensure we have loaded the user profile
        guard (self.groupProfile != nil) else { return }
        
        // Display group's organization name
        if let _organization_name = self.groupProfile!["properties"]["organization"]["properties"]["name"].string {
            self.labelGroupProfileName.text = _organization_name
        }
        else if let _organization_name = self.groupProfile!["properties"]["name"].string {
            self.labelGroupProfileName.text = _organization_name
        }

        // Display group's organization name
        if let _organization_description = self.groupProfile!["properties"]["organization"]["properties"]["description"].string {
            self.labelGroupProfileDescription.text = _organization_description
        }
        else if let _organization_description = self.groupProfile!["properties"]["description"].string {
            self.labelGroupProfileDescription.text = _organization_description
        }

        // Display user's profile picture
        var groupProfileImageURL: NSURL!
        
        if let thisGroupProfileImageURLString = self.groupProfile!["properties"]["organization"]["properties"]["picture"].string {
            groupProfileImageURL = NSURL(string: String(thisGroupProfileImageURLString))
        }
        else if let thisGroupProfileImageURLString = self.groupProfile!["properties"]["picture"].string {
            groupProfileImageURL = NSURL(string: String(thisGroupProfileImageURLString))
        }
        
        self.imageViewGroupProfileImage.kf_indicatorType = .Activity
        self.imageViewGroupProfileImage.kf_showIndicatorWhenLoading = true
        
        self.imageViewGroupProfileImage.kf_setImageWithURL(groupProfileImageURL, placeholderImage: nil, optionsInfo: nil, progressBlock: nil, completionHandler: {
            (image, error, cacheType, imageUrl) in
            if (image != nil) {
                self.imageViewGroupProfileImage.image = UIImage(CGImage: (image?.CGImage)!, scale: (image?.scale)!, orientation: UIImageOrientation.Up)
            }
            self.imageViewGroupProfileImage.clipsToBounds = true
        })
        
        
        //
        // Load and display other user information
        //
        self.attemptLoadGroupSubmissions()
        
        self.attemptLoadGroupActions()
        
        self.attemptLoadGroupUsers()

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

    func attemptLoadGroupUsers(isRefreshingReportsList: Bool = false) {
        
        // Set headers
        let _headers = self.buildRequestHeaders()
        
        let GET_GROUP_MEMBERS_ENDPOINT = Endpoints.GET_MANY_ORGANIZATIONS + "/\(self.groupId)/users"
        
        let _parameters = [
            "page": "\(self.groupMembersPage)"
        ]

        Alamofire.request(.GET, GET_GROUP_MEMBERS_ENDPOINT, headers: _headers, parameters: _parameters).responseJSON { response in
            
            print("response.result \(response.result)")
            
            switch response.result {
            case .Success(let value):
                print("Request Success: \(value)")
                
                // Assign response to groups variable
                if (isRefreshingReportsList) {
                    self.groupMembers = JSON(value)
                    self.groupMembersObjects = value["features"] as! [AnyObject]
                    self.groupMembersRefreshControl.endRefreshing()
                }
                else {
                    self.groupMembers = JSON(value)
                    self.groupMembersObjects += value["features"] as! [AnyObject]
                }
                
                
                // Set the number on the profile page
                let _group_count = self.groupMembers!["properties"]["num_results"]
                
                if (_group_count != "") {
                    self.buttonGroupProfileUsersCount.setTitle("\(_group_count)", forState: .Normal)
                }
                
                // Refresh the data in the table so the newest items appear
                self.memberTableView.reloadData()
                
                self.groupMembersPage += 1
                
                break
            case .Failure(let error):
                print("Request Failure: \(error)")
                
                // Stop showing the loading indicator
                //self.status("doneLoadingWithError")
                
                break
            }
        }
        
    }
    
    func attemptLoadGroupSubmissions(isRefreshingReportsList: Bool = false) {
        
        let _parameters = [
            "q": "{\"filters\":[{\"name\":\"groups__id\",\"op\":\"any\",\"val\":\"\(self.groupId)\"}],\"order_by\": [{\"field\":\"report_date\",\"direction\":\"desc\"},{\"field\":\"id\",\"direction\":\"desc\"}]}",
            "page": "\(self.groupSubmissionsPage)"
        ]
        
        print("_parameters \(_parameters)")
        
        Alamofire.request(.GET, Endpoints.GET_MANY_REPORTS, parameters: _parameters)
            .responseJSON { response in
                
                switch response.result {
                case .Success(let value):
//                    print("Request Success \(Endpoints.GET_MANY_REPORTS) \(value)")
                    
                    if (value.objectForKey("code") != nil) {
                        break
                    }
                    
                    // Assign response to groups variable
                    if (isRefreshingReportsList) {
                        self.groupSubmissions = JSON(value)
                        self.groupSubmissionsObjects = value["features"] as! [AnyObject]
                        self.groupSubmissionsRefreshControl.endRefreshing()
                    }
                    else {
                        self.groupSubmissions = JSON(value)
                        self.groupSubmissionsObjects += value["features"] as! [AnyObject]
                    }
                    
                    // Set visible button count
                    let _submission_count = self.groupSubmissions!["properties"]["num_results"]
                    
                    if (_submission_count != "") {
                        self.buttonGroupProfileSubmissionsCount.setTitle("\(_submission_count)", forState: .Normal)
                    }
                    
                    // Refresh the data in the table so the newest items appear
                    self.submissionTableView.reloadData()
                    
                    self.groupSubmissionsPage += 1
                    
                    break
                case .Failure(let error):
                    print("Request Failure: \(error)")
                    
                    // Stop showing the loading indicator
                    //self.status("doneLoadingWithError")
                    
                    break
                }
                
        }
        
    }
    
    
    func attemptLoadGroupActions(isRefreshingReportsList: Bool = false) {
        
        let _parameters = [
            "q": "{\"filters\":[{\"name\":\"groups__id\",\"op\":\"any\",\"val\":\"\(self.groupId)\"},{\"name\":\"state\", \"op\":\"eq\", \"val\":\"closed\"}],\"order_by\": [{\"field\":\"report_date\",\"direction\":\"desc\"},{\"field\":\"id\",\"direction\":\"desc\"}]}",
            "page": "\(self.groupActionsPage)"
        ]
        
        Alamofire.request(.GET, Endpoints.GET_MANY_REPORTS, parameters: _parameters)
            .responseJSON { response in
                
                switch response.result {
                case .Success(let value):
//                    print("Request Success \(Endpoints.GET_MANY_REPORTS) \(value)")

                    if (value.objectForKey("code") != nil) {
                        break
                    }

                    // Assign response to groups variable
                    if (isRefreshingReportsList) {
                        self.groupActions = JSON(value)
                        self.groupActionsObjects = value["features"] as! [AnyObject]
                        self.groupActionsRefreshControl.endRefreshing()
                    }
                    else {
                        self.groupActions = JSON(value)
                        self.groupActionsObjects += value["features"] as! [AnyObject]
                    }
                
                    // Set visible button count
                    let _action_count = self.groupActions!["properties"]["num_results"]
                    
                    if (_action_count >= 1) {
                        self.buttonGroupProfileActionsCount.setTitle("\(_action_count)", forState: .Normal)
                    }
                    
                    // Refresh the data in the table so the newest items appear
                    self.actionTableView.reloadData()
                    
                    self.groupActionsPage += 1
                    
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
            
            guard (JSON(self.groupSubmissionsObjects) != nil) else { return 0 }
            
            if self.groupSubmissionsObjects.count == 0 {
                return 1
            }

            return (self.groupSubmissionsObjects.count)

        } else if (tableView.restorationIdentifier == "actionTableView") {
            
            guard (JSON(self.groupActionsObjects) != nil) else { return 0 }
            
            if self.groupActionsObjects.count == 0 {
                return 1
            }

            return (self.groupActionsObjects.count)
            
        } else if (tableView.restorationIdentifier == "membersTableView") {
            
            guard (JSON(self.groupMembersObjects) != nil) else { return 0 }

            if self.groupMembersObjects.count == 0 {
                return 1
            }

            return (self.groupMembersObjects.count)
            
        } else {
            return 0
        }
        
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let emptyCell = tableView.dequeueReusableCellWithIdentifier("emptyTableViewCell", forIndexPath: indexPath) as! EmptyTableViewCell

        if (tableView.restorationIdentifier == "submissionsTableView") {
            //
            // Submissions
            //
            let cell = tableView.dequeueReusableCellWithIdentifier("userProfileSubmissionCell", forIndexPath: indexPath) as! UserProfileSubmissionTableViewCell
            
            guard (JSON(self.groupSubmissionsObjects) != nil) else { return emptyCell }
            
            let _submission = JSON(self.groupSubmissionsObjects)
            let _thisSubmission = _submission[indexPath.row]["properties"]
            print("Show _thisSubmission \(_thisSubmission)")
            
            if _thisSubmission == nil {
                
                emptyCell.emptyMessageDescription.text = "Looks like this group hasn't posted anything yet.  Join their group and share a report to get them started!"
                emptyCell.emptyMessageAction.hidden = false
                emptyCell.emptyMessageAction.addTarget(self, action: #selector(self.emptyMessageAddReport(_:)), forControlEvents: UIControlEvents.TouchUpInside)

                return emptyCell
            }

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

            if (indexPath.row == self.groupSubmissionsObjects.count - 2 && self.groupSubmissionsObjects.count < self.groupSubmissions!["properties"]["num_results"].int) {
                self.attemptLoadGroupSubmissions()
            }
            
            return cell
        } else if (tableView.restorationIdentifier == "actionTableView") {
            //
            // Actions
            //
            let cell = tableView.dequeueReusableCellWithIdentifier("userProfileActionCell", forIndexPath: indexPath) as! UserProfileActionsTableViewCell
            
            guard (JSON(self.groupActionsObjects) != nil) else { return emptyCell }
            
            let _actions = JSON(self.groupActionsObjects)
            let _thisSubmission = _actions[indexPath.row]["properties"]
            print("Show _thisSubmission \(_thisSubmission)")
            
            if _thisSubmission == nil {
                
                emptyCell.emptyMessageDescription.text = "Looks like this group hasn't posted anything yet.  Join their group and share a report to get them started!"
                emptyCell.emptyMessageAction.hidden = false
                
                return emptyCell
            }

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
                cell.buttonOpenGraphLink.addTarget(self, action: #selector(self.openActionsOpenGraphURL(_:)), forControlEvents: .TouchUpInside)
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

            // Buttons > Territory
            //
            if cell.buttonReportTerritory != nil {
                cell.buttonReportTerritory.tag = indexPath.row
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

            
            if (indexPath.row == self.groupActionsObjects.count - 2 && self.groupActionsObjects.count < self.groupActions!["properties"]["num_results"].int) {
                self.attemptLoadGroupActions()
            }

            return cell
        } else if (tableView.restorationIdentifier == "membersTableView") {
            //
            // Groups
            //
            let cell = tableView.dequeueReusableCellWithIdentifier("userProfileMemberCell", forIndexPath: indexPath) as! UserProfileMembersTableViewCell
            
            guard (JSON(self.groupMembersObjects) != nil) else { return emptyCell }
            
            let _members = JSON(self.groupMembersObjects)
            let _thisSubmission = _members[indexPath.row]["properties"]
            print("Show _thisSubmission \(_thisSubmission)")

            if _thisSubmission == nil {
                
                emptyCell.emptyMessageDescription.text = "No members yet but you can always join!"
                emptyCell.emptyMessageAction.hidden = false
                emptyCell.emptyMessageAction.setTitle("Join this group", forState: .Normal)
                emptyCell.emptyMessageAction.addTarget(self, action: #selector(self.emptyMessageJoinGroup(_:)), forControlEvents: UIControlEvents.TouchUpInside)
                
                return emptyCell
            }
            
            // Display Member Name
            if let _first_name = _thisSubmission["first_name"].string,
               let _last_name = _thisSubmission["last_name"].string{
                cell.labelGroupMemberName.text = "\(_first_name) \(_last_name)"
            }
            
            // Display Member Image
            var groupProfileImageURL:NSURL! = NSURL(string: "https://www.waterreporter.org/community/images/badget--MissingUser.png")
            
            if let _group_image_url = _thisSubmission["picture"].string {
                groupProfileImageURL = NSURL(string: _group_image_url)
            }

            cell.imageViewGroupMemberProfileImage.kf_indicatorType = .Activity
            cell.imageViewGroupMemberProfileImage.kf_showIndicatorWhenLoading = true
            
            cell.imageViewGroupMemberProfileImage.kf_setImageWithURL(groupProfileImageURL, placeholderImage: nil, optionsInfo: nil, progressBlock: nil, completionHandler: {
                (image, error, cacheType, imageUrl) in
                if (image != nil) {
                    cell.imageViewGroupMemberProfileImage.image = UIImage(CGImage: (image?.CGImage)!, scale: (image?.scale)!, orientation: UIImageOrientation.Up)
                }
            })
            
            // Link to Member profile
            cell.buttonMemberSelection.tag = indexPath.row
            
            if (indexPath.row == self.groupMembersObjects.count - 2 && self.groupMembersObjects.count < self.groupMembers!["properties"]["num_results"].int) {
                self.attemptLoadGroupUsers()
            }

            return cell
        }
        
        return emptyCell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
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
        
        if (self.actionTableView.hidden == false) {
            var _cell = self.actionTableView.cellForRowAtIndexPath(_indexPath) as! UserProfileActionsTableViewCell
            _report = JSON(self.groupActionsObjects[(indexPathRow)].objectForKey("properties")!)
            
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
            _report = JSON(self.groupSubmissionsObjects[(indexPathRow)].objectForKey("properties")!)
            
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
            
            if (self.actionTableView.hidden == false) {
                _report = JSON(self.groupActionsObjects[(senderTag)])
            }
            else if (self.submissionTableView.hidden == false) {
                _report = JSON(self.groupSubmissionsObjects[(senderTag)])
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
            
            if (self.actionTableView.hidden == false) {
                _report = JSON(self.groupActionsObjects[(senderTag)])
            }
            else if (self.submissionTableView.hidden == false) {
                _report = JSON(self.groupSubmissionsObjects[(senderTag)])
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
                    
                    if (self.actionTableView.hidden == false) {
                        self.groupActionsObjects[(reportSenderTag)] = value
                    }
                    else if (self.submissionTableView.hidden == false) {
                        self.groupSubmissionsObjects[(reportSenderTag)] = value
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
