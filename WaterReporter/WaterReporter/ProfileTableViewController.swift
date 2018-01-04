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
    @IBAction func openSubmissionsLikesList(sender: UIButton) {
        
        let nextViewController = self.storyBoard.instantiateViewControllerWithIdentifier("LikesTableViewController") as! LikesTableViewController
        
        let report = self.userSubmissionsObjects[(sender.tag)]
        nextViewController.report = report
        
        self.navigationController?.pushViewController(nextViewController, animated: true)
        
    }
    
    @IBAction func openActionsLikesList(sender: UIButton) {
        
        let nextViewController = self.storyBoard.instantiateViewControllerWithIdentifier("LikesTableViewController") as! LikesTableViewController
        
        let report = self.userActionsObjects[(sender.tag)]
        nextViewController.report = report
        
        self.navigationController?.pushViewController(nextViewController, animated: true)
        
    }
    
    @IBAction func openSubmissionOpenGraphURL(sender: UIButton) {
        
        let reportId = sender.tag
        let report = JSON(self.userSubmissionsObjects[reportId])
        
        let reportURL = "\(report["properties"]["social"][0]["properties"]["og_url"])"
        
        print("openOpenGraphURL \(reportURL)")
        
        UIApplication.sharedApplication().openURL(NSURL(string: "\(reportURL)")!)
    }

    @IBAction func openActionsOpenGraphURL(sender: UIButton) {
        
        let reportId = sender.tag
        let report = JSON(self.userActionsObjects[reportId])
        
        let reportURL = "\(report["properties"]["social"][0]["properties"]["og_url"])"
        
        print("openOpenGraphURL \(reportURL)")
        
        UIApplication.sharedApplication().openURL(NSURL(string: "\(reportURL)")!)
    }

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
        
        let _thisReport = JSON(self.userSubmissionsObjects[(sender.tag)])
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
                
                activityVC.popoverPresentationController?.sourceView = sender
                
                self.presentViewController(activityVC, animated: true, completion: nil)
            }
            else {
                let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
                
                activityVC.popoverPresentationController?.sourceView = sender
                
                self.presentViewController(activityVC, animated: true, completion: nil)
            }
        })

    }
    
    @IBAction func shareActionsButtonClicked(sender: UIButton) {
        
        let _thisReport = JSON(self.userActionsObjects[(sender.tag)])
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
                
                activityVC.popoverPresentationController?.sourceView = sender
                
                self.presentViewController(activityVC, animated: true, completion: nil)
            }
            else {
                let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
                
                activityVC.popoverPresentationController?.sourceView = sender
                
                self.presentViewController(activityVC, animated: true, completion: nil)
            }
        })

    }

    @IBAction func openUserSubmissionMapView(sender: UIButton) {
        let nextViewController = self.storyBoard.instantiateViewControllerWithIdentifier("ActivityMapViewController") as! ActivityMapViewController
        
        nextViewController.reportObject = self.userSubmissionsObjects[sender.tag]
        
        self.navigationController?.pushViewController(nextViewController, animated: true)
        
    }
    
    @IBAction func openUserSubmissionCommentsView(sender: UIButton) {
        let nextViewController = self.storyBoard.instantiateViewControllerWithIdentifier("ReportCommentsTableViewController") as! ReportCommentsTableViewController
        
        nextViewController.report = self.userSubmissionsObjects[sender.tag]
        
        self.navigationController?.pushViewController(nextViewController, animated: true)
        
    }
    
    @IBAction func openUserActionMapView(sender: UIButton) {
        let nextViewController = self.storyBoard.instantiateViewControllerWithIdentifier("ActivityMapViewController") as! ActivityMapViewController
        
        nextViewController.reportObject = self.userActionsObjects[sender.tag]
        
        self.navigationController?.pushViewController(nextViewController, animated: true)
        
    }

    @IBAction func openUserActionCommentsView(sender: UIButton) {
        let nextViewController = self.storyBoard.instantiateViewControllerWithIdentifier("ReportCommentsTableViewController") as! ReportCommentsTableViewController
        
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
    
    @IBAction func openModificationSelector(sender: UIButton) {
        
        let thisActionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        
        let editReportAction = UIAlertAction(title: "Edit Report", style: .Default, handler: {
            UIAlertAction in
            let _submissions = JSON(self.userSubmissionsObjects)
            let _report = _submissions[sender.tag]
            let _report_id: String! = "\(_submissions[sender.tag]["id"])"

            self.attemptEditReport(_report, reportId: _report_id)
        })
        thisActionSheet.addAction(editReportAction)

        let deleteReportAction = UIAlertAction(title: "Delete Report", style: .Default, handler: {
            UIAlertAction in
            let _submissions = JSON(self.userSubmissionsObjects)
            let _report_id: String! = "\(_submissions[sender.tag]["id"])"
            
            self.attemptConfirmDeleteReport(_report_id)
        })
        thisActionSheet.addAction(deleteReportAction)

        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        thisActionSheet.addAction(cancelAction)
        
        presentViewController(thisActionSheet, animated: true, completion: nil)

    }

    @IBAction func loadTerritoryProfileFromSubmissions(sender: UIButton) {
        
        let nextViewController = self.storyBoard.instantiateViewControllerWithIdentifier("TerritoryViewController") as! TerritoryViewController
        
        var _thisReport: JSON!
        
        _thisReport = JSON(self.userSubmissionsObjects[(sender.tag)])
        
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
        
        _thisReport = JSON(self.userActionsObjects[(sender.tag)])
        
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
    
    var likeDelay: NSTimer = NSTimer()
    var unlikeDelay: NSTimer = NSTimer()
    
    //
    // Table header view
    //
    
    var profileTableHeader = UIView()
    
    //
    // Stat group view
    //
    
    lazy var statGroupView: UIView = {
        let view = UIView()
        view.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 32)
        view.center = CGPoint(x: 160, y: 200)
        view.alpha = 0.0
        view.backgroundColor = UIColor(
            red: 200.0/255.0,
            green: 208.0/255.0,
            blue: 216.0/255.0,
            alpha: 0.0
        )
        return view
    }()
    
//    lazy var statStackView: UIStackView = {
//        let stackView = UIStackView(arrangedSubviews: [postCountLabel, actionCountLabel, groupCountLabel])
//        stackView.alignment = .Fill
//        stackView.distribution = .Fill
//        stackView.axis = .Horizontal
//        stackView.translatesAutoresizingMaskIntoConstraints = false
//        return stackView
//    }()
//    
//    var postCountLabel: UILabel = {
//        let label = UILabel()
//        label.textAlignment = .Center
//        label.font = UIFont.systemFontOfSize(15, weight: UIFontWeightMedium)
//        label.heightAnchor.constraintEqualToConstant(24.0).active = true
//        label.translatesAutoresizingMaskIntoConstraints = false
//        return label
//    }()
//    
//    var actionCountLabel: UILabel = {
//        let label = UILabel()
//        label.textAlignment = .Center
//        label.font = UIFont.systemFontOfSize(15, weight: UIFontWeightMedium)
//        label.heightAnchor.constraintEqualToConstant(24.0).active = true
//        label.translatesAutoresizingMaskIntoConstraints = false
//        return label
//    }()
//    
//    var groupCountLabel: UILabel = {
//        let label = UILabel()
//        label.textAlignment = .Center
//        label.font = UIFont.systemFontOfSize(15, weight: UIFontWeightMedium)
//        label.heightAnchor.constraintEqualToConstant(24.0).active = true
//        label.translatesAutoresizingMaskIntoConstraints = false
//        return label
//    }()
    
//    lazy var statStackView: UIStackView = {
//        let stackView = UIStackView(arrangedSubviews: [smallRectangleView, bigRectangleView, bigRectangleView2])
//        stackView.alignment = .Fill
//        stackView.distribution = .Fill
//        stackView.axis = .Horizontal
//        stackView.translatesAutoresizingMaskIntoConstraints = false
//        return stackView
//    }()

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
            
            if let _first_name = self.userProfile!["properties"]["first_name"].string,
                let _last_name = self.userProfile!["properties"]["last_name"].string {
                self.navigationItem.title = _first_name + " " + _last_name
            }
            
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
        //
        //
        // Set dynamic row heights
        self.submissionTableView.rowHeight = UITableViewAutomaticDimension;
        self.submissionTableView.estimatedRowHeight = 368.0;
        
        self.actionsTableView.rowHeight = UITableViewAutomaticDimension;
        self.actionsTableView.estimatedRowHeight = 368.0;

        self.groupsTableView.rowHeight = UITableViewAutomaticDimension;
        self.groupsTableView.estimatedRowHeight = 368.0;

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
        
        
        // SET DEFAULT SELECTED TAB
        //
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
    
    func retrieveUserTitle(userObject: JSON?) -> String {
        
        var userTitleString = ""
        
        var titleArray = [String]()
        
//        if let userTitleString = self.userProfile!["properties"]["title"].string,
//            userOrganizationNameString = self.userProfile!["properties"]["organization_name"].string {
//        
//            let completeTitleString = userTitleString + " at " + userOrganizationNameString as String
//            
//            return completeTitleString.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
//            
//        } else if let userTitleString = self.userProfile!["properties"]["title"].string {
//            
//            return userTitleString.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
//            
//        } else {
//            
//            return ""
//            
//        }
        
        if let userTitleString = self.userProfile!["properties"]["title"].string {
            
            if userTitleString != "" {
                titleArray.append(userTitleString)
            }
            
        }
        
        if let userOrganizationNameString = self.userProfile!["properties"]["organization_name"].string {
            
            if userOrganizationNameString != "" {
                titleArray.append(userOrganizationNameString)
            }
            
        }
        
        if titleArray.count > 1 {
            
            userTitleString = titleArray.joinWithSeparator(" at ").stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
            
        } else if titleArray.count == 1 {
            
            userTitleString = titleArray.joinWithSeparator("").stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
            
        }
        
        return userTitleString
        
//        let trimmedTitle = completeTitleString.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
//        
//        if trimmedTitle == "at" {
//            
//            return ""
//            
//        }
//        
//        return trimmedTitle
        
    }
    
    func displayUserSnapshotInformation() {
        
        print("displayUserSnapshotInformation")
        
        print("User snapshot value is: \(self.userSnapshot)")
        
        //
        // Summary stats group view
        //

        self.profileTableHeader.addSubview(statGroupView)
        
        UIView.animateWithDuration(0.25) { () -> Void in
            self.statGroupView.alpha = 1.0
        }
        
        //
        // Post count
        //
        
        let postCountLabel: UILabel = {
            let label = UILabel()
            label.textAlignment = .Center
            label.font = UIFont.systemFontOfSize(13, weight: UIFontWeightSemibold)
//            label.heightAnchor.constraintEqualToConstant(16.0).active = true
            label.translatesAutoresizingMaskIntoConstraints = false
            return label
        }()
        
        //
        // Action count
        //
        
        let actionCountLabel: UILabel = {
            let label = UILabel()
            label.textAlignment = .Center
            label.font = UIFont.systemFontOfSize(13, weight: UIFontWeightSemibold)
//            label.heightAnchor.constraintEqualToConstant(16.0).active = true
            label.translatesAutoresizingMaskIntoConstraints = false
            return label
        }()
        
        //
        // Group count
        //
        
        let groupCountLabel: UILabel = {
            let label = UILabel()
            label.textAlignment = .Center
            label.font = UIFont.systemFontOfSize(13, weight: UIFontWeightSemibold)
//            label.heightAnchor.constraintEqualToConstant(16.0).active = true
            label.translatesAutoresizingMaskIntoConstraints = false
            return label
        }()
        
        //
        // Stat stack view
        //
        
        let statStackView: UIStackView = {
            let stackView = UIStackView(arrangedSubviews: [postCountLabel, actionCountLabel, groupCountLabel])
            stackView.alignment = .Center
            stackView.distribution = .FillEqually
            stackView.axis = .Horizontal
            stackView.translatesAutoresizingMaskIntoConstraints = false
            return stackView
        }()
        
        statGroupView.addSubview(statStackView)
        
        statStackView.leadingAnchor.constraintEqualToAnchor(statGroupView.leadingAnchor).active = true
        statStackView.trailingAnchor.constraintEqualToAnchor(statGroupView.trailingAnchor).active = true
        statStackView.bottomAnchor.constraintEqualToAnchor(statGroupView.bottomAnchor).active = true
        statStackView.topAnchor.constraintEqualToAnchor(statGroupView.topAnchor).active = true
//        statStackView.heightAnchor.constraintEqualToConstant(24.0).active = true
        
        //
        // Populate values
        //
        
        if let postCount = self.userSnapshot!["posts"].int {
            
            postCountLabel.text = "\(postCount) posts"
            
            if postCount == 1 {
                
                postCountLabel.text = "\(postCount) post"
                
            }
            
        } else {
            
            print("No post count")
            
        }
        
        if let actionCount = self.userSnapshot!["actions"].int {
            
            actionCountLabel.text = "\(actionCount) actions"
            
            if actionCount == 1 {
                
                actionCountLabel.text = "\(actionCount) post"
                
            }
            
        } else {
            
            print("No action count")
            
        }

        
        if let groupCount = self.userSnapshot!["groups"].int {
            
            groupCountLabel.text = "\(groupCount) groups"
            
            if groupCount == 1 {
                
                groupCountLabel.text = "\(groupCount) group"
                
            }
            
        } else {
            
            print("No group count")
            
        }
        
    }
    
    func displayUserProfileInformation(withoutReportReload: Bool = false) {
        
        print("displayUserProfileInformation")
        
        print("User profile value is: \(self.userProfile)")
        
        // Ensure we have loaded the user profile
        guard (self.userProfile != nil) else {
            print("RETURNING NIL")
            return
        }
        
//        if self.userProfile!["properties"]["first_name"].string != "" && self.userProfile!["properties"]["last_name"].string != "" {
//            // Display user's first and last name
//
//            self.labelUserProfileName.text = self.userProfile!["properties"]["first_name"].string! + " " + self.userProfile!["properties"]["last_name"].string!
//            
//            print("Display User's Name \(self.labelUserProfileName.text)")
//        }
//        else {
//            self.labelUserProfileName.text = ""
//            
//            //
//            // Activate the "Finish Profile" prompt
//            //
//            print("Display Finish Profile Prompt")
//
//        }
        
//        // Display user's title
//        if self.userProfile!["properties"]["title"].string != "" {
//            self.labelUserProfileTitle.text = self.userProfile!["properties"]["title"].string
//        }
//        else {
//            self.labelUserProfileTitle.text = ""
//        }
//
//        // Display user's organization name
//        if self.userProfile!["properties"]["organization_name"].string != "" {
//            self.labelUserProfileOrganizationName.text = self.userProfile!["properties"]["organization_name"].string
//        }
//        else {
//            self.labelUserProfileOrganizationName.text = ""
//        }
//
//        // Display user's description/bio
//        if self.userProfile!["properties"]["description"].string != "" && self.userProfile!["properties"]["description"].string != "Bio" {
//            self.labelUserProfileDescription.text = self.userProfile!["properties"]["description"].string
//        }
//        else {
//            self.labelUserProfileDescription.text = ""
//        }

        // Display user's profile picture
//        var userProfileImageURL: NSURL! = NSURL(string: "https://www.waterreporter.org/community/images/badget--MissingUser.png")
//
//        if let thisUserProfileImageURLString = self.userProfile!["properties"]["picture"].string {
//            userProfileImageURL = NSURL(string: String(thisUserProfileImageURLString))
//        }
//        
//        self.imageViewUserProfileImage.kf_indicatorType = .Activity
//        self.imageViewUserProfileImage.kf_showIndicatorWhenLoading = true
//        
//        self.imageViewUserProfileImage.kf_setImageWithURL(userProfileImageURL, placeholderImage: nil, optionsInfo: nil, progressBlock: nil, completionHandler: {
//            (image, error, cacheType, imageUrl) in
//            if (image != nil) {
//                self.imageViewUserProfileImage.image = UIImage(CGImage: (image?.CGImage)!, scale: (image?.scale)!, orientation: UIImageOrientation.Up)
//            }
//            self.imageViewUserProfileImage.clipsToBounds = true
//        })
        
//        let headerView = UIView()
        
        profileTableHeader.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 216)
        
        profileTableHeader.backgroundColor = UIColor(
            red: 245.0/255.0,
            green: 247.0/255.0,
            blue: 249.0/255.0,
            alpha: 1.0
        )
        
//        let margins = self.view.layoutMarginsGuide
        
//        headerView.leadingAnchor.constraintEqualToAnchor(self.submissionTableView.leadingAnchor, constant: 0.0).active = true
//        
//        headerView.trailingAnchor.constraintEqualToAnchor(self.submissionTableView.trailingAnchor, constant: 0.0).active = true
        
        //
        // Default vertical offsets for header components
        //
        
        let userTitleYOffset = 124
//        let organizationNameYOffset = 124
        let userBioYOffset = 160
        
//        let headerStackView = UIStackView()
//        
//        headerStackView.axis = .Vertical;
//        headerStackView.distribution = .EqualSpacing;
//        headerStackView.alignment = .Center;
//        headerStackView.spacing = 10;
        
//        headerView.addSubview(headerStackView)
//        
//        headerStackView.leadingAnchor.constraintEqualToAnchor(headerView.leadingAnchor).active = true
//        headerStackView.trailingAnchor.constraintEqualToAnchor(headerView.trailingAnchor).active = true
//        headerStackView.topAnchor.constraintEqualToAnchor(headerView.topAnchor).active = true
//        headerStackView.bottomAnchor.constraintEqualToAnchor(headerView.bottomAnchor).active = true
        
        let userImageView = UIImageView()
        
        userImageView.frame = CGRect(x: 0, y: 0, width: 64, height: 64)
        
//        userImageView.heightAnchor.constraintEqualToConstant(64.0).active = true
//        userImageView.widthAnchor.constraintEqualToConstant(64.0).active = true
        
        userImageView.center = CGPoint(x: 160, y: 48)
        
        var userProfileImageURL: NSURL! = NSURL(string: "https://www.waterreporter.org/community/images/badget--MissingUser.png")
        
        if let thisUserProfileImageURLString = self.userProfile!["properties"]["picture"].string {
            userProfileImageURL = NSURL(string: String(thisUserProfileImageURLString))
        }
        
//        self.imageViewUserProfileImage.kf_indicatorType = .Activity
//        self.imageViewUserProfileImage.kf_showIndicatorWhenLoading = true
        
        userImageView.kf_setImageWithURL(userProfileImageURL, placeholderImage: nil, optionsInfo: nil, progressBlock: nil, completionHandler: {
            (image, error, cacheType, imageUrl) in
            if (image != nil) {
                userImageView.image = UIImage(CGImage: (image?.CGImage)!, scale: (image?.scale)!, orientation: UIImageOrientation.Up)
            }
            userImageView.layer.cornerRadius = userImageView.frame.size.width / 2
            userImageView.clipsToBounds = true
        })
        
        //
        // Center the user avatar horizontally in its container
        //
        
//        userImageView.centerXAnchor.constraintEqualToAnchor(headerView.centerXAnchor)
        
//        userImageView.centerXAnchor.constraint(equalTo: headerView.centerXAnchor).isActive = true
        
        profileTableHeader.addSubview(userImageView)
        
        if self.userProfile!["properties"]["first_name"].string != "" && self.userProfile!["properties"]["last_name"].string != "" {
            
            // Display user's first and last name
            
            let userNameLabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 24))
            
            userNameLabel.center = CGPoint(x: 160, y: 100)
            userNameLabel.textAlignment = .Center
            userNameLabel.font = UIFont.systemFontOfSize(17, weight: UIFontWeightRegular)
            
            userNameLabel.text = self.userProfile!["properties"]["first_name"].string! + " " + self.userProfile!["properties"]["last_name"].string!
            
            profileTableHeader.addSubview(userNameLabel)
            
            print("Display User's Name \(userNameLabel.text)")
            
        }
        else {
            
//            self.labelUserProfileName.text = ""
            
            //
            // Activate the "Finish Profile" prompt
            //
            print("Display Finish Profile Prompt")
            
        }
        
        // Display user's title
//        if self.userProfile!["properties"]["title"].string != "" &&
//            self.userProfile!["properties"]["organization_name"].string != "" {
//            
//            var userTitleString = self.userProfile!["properties"]["title"].string
//            
//            var userOrganizationNameString = self.userProfile!["properties"]["organization_name"].string
//            
//            let userTitleLabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 24))
//            
//            userTitleLabel.center = CGPoint(x: 160, y: userTitleYOffset)
//            userTitleLabel.textAlignment = .Center
//            userTitleLabel.font = UIFont.systemFontOfSize(13, weight: UIFontWeightRegular)
//            
//            if self.userProfile!["properties"]["organization_name"].string != "" {
//                
//                let userOrganizationNameString = self.userProfile!["properties"]["organization_name"].string
//                
//                userTitleString! += " at \(userOrganizationNameString)"
//    
//                
//            }
//            
//            userTitleLabel.text = userTitleString
//            
//            headerView.addSubview(userTitleLabel)
//            
//        }
//        else if self.userProfile!["properties"]["title"].string != "" &&
//            self.userProfile!["properties"]["organization_name"].string == "" {
//            
//            
//            
//        }
        
        let userTitleString = retrieveUserTitle(self.userProfile)
        
        if userTitleString != "" &&
            userTitleString != "at" {
            
            let userTitleLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 276, height: 24))

            userTitleLabel.center = CGPoint(x: 160, y: userTitleYOffset)
            userTitleLabel.textAlignment = .Center
            userTitleLabel.font = UIFont.systemFontOfSize(12, weight: UIFontWeightRegular)

            userTitleLabel.text = userTitleString

            profileTableHeader.addSubview(userTitleLabel)
            
        }
        
        // Display user's organization name
//        if self.userProfile!["properties"]["organization_name"].string != "" {
//            
//            let userOrganizationNameLabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 24))
//            
//            userOrganizationNameLabel.center = CGPoint(x: 160, y: organizationNameYOffset)
//            userOrganizationNameLabel.textAlignment = .Center
//            userOrganizationNameLabel.font = UIFont.systemFontOfSize(15, weight: UIFontWeightRegular)
//            
//            userOrganizationNameLabel.text = self.userProfile!["properties"]["organization_name"].string
//            
//            headerView.addSubview(userOrganizationNameLabel)
//            
//        }
        
        // Display user's description/bio
        if self.userProfile!["properties"]["description"].string != "" && self.userProfile!["properties"]["description"].string != "Bio" {
            
            let userBioLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 272, height: 32))
            
            userBioLabel.center = CGPoint(x: 160, y: userBioYOffset)
            userBioLabel.textAlignment = .Center
            userBioLabel.font = UIFont.systemFontOfSize(13, weight: UIFontWeightRegular)
            userBioLabel.numberOfLines = 2
            userBioLabel.lineBreakMode = .ByTruncatingTail
            
            userBioLabel.text = self.userProfile!["properties"]["description"].string
            
//            userBioLabel.sizeToFit()
            
            profileTableHeader.addSubview(userBioLabel)
            
        }
        
//        headerView.addSubview(headerStackView)
        
//        headerView.sizeToFit()
        
        self.submissionTableView.tableHeaderView = profileTableHeader
        
//        self.actionsTableView.tableHeaderView = profileTableHeader
//        
//        self.groupsTableView.tableHeaderView = profileTableHeader
        
        //
        // Load and display other user information
        //
        if !withoutReportReload {
            
            self.attemptLoadUserGroups()
            
            self.attemptLoadUserSubmissions()
            
            self.attemptLoadUserActions()
        }

        self.attemptLoadUserSnapshot()

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
    // Load user snapshot
    //
    
    func attemptLoadUserSnapshot() {
        
//        if userId == "" {
//            return
//        }
        
        let _headers = buildRequestHeaders()
        
        let revisedEndpoint = Endpoints.GET_USER_SNAPSHOT + "\(self.userId)"
        
        print("revisedEndpoint \(revisedEndpoint)")
        
        Alamofire.request(.GET, revisedEndpoint, headers: _headers, encoding: .JSON).responseJSON { response in
            
            print("response.result \(response.result)")
            
            switch response.result {
                
                case .Success(let value):
                    
                    let json = JSON(value)
                    
                    print("Response Success \(value)")
                    
                    if (json != nil) {
                        
                        // Retain the returned data
                        self.userSnapshot = json
                        
                        // Show the data on screen
                        self.displayUserSnapshotInformation()
                        
                    }
                    
                case .Failure(let error):
                    
                    print("Response Failure \(error)")
                
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
                    let _group_count = self.userGroups!["properties"]["num_results"]
                    
                    if (_group_count != "") {
                        self.buttonUserProfileGroupCount.setTitle("\(_group_count)", forState: .Normal)
                    }
                    
                    // Refresh the data in the table so the newest items appear
                    self.groupsTableView.reloadData()
                    
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
    
    func attemptLoadUserSubmissions(isRefreshingReportsList: Bool = false) {
        
        let _parameters = [
            "q": "{\"filters\":[{\"name\":\"owner_id\",\"op\":\"eq\",\"val\":\"\(self.userId)\"}],\"order_by\": [{\"field\":\"created\",\"direction\":\"desc\"}]}",
            "page": "\(self.userSubmissionsPage)"
        ]
        
        Alamofire.request(.GET, Endpoints.GET_MANY_REPORTS, parameters: _parameters)
            .responseJSON { response in
                
                switch response.result {
                case .Success(let value):
                    
                    print("Response Success: \(value)")
                    
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
                            self.userSubmissions = JSON(value)
                            self.userSubmissionsObjects = value["features"] as! [AnyObject]
                            self.submissionRefreshControl.endRefreshing()
                        } else {
                            if let features = value["features"] {
                                if features != nil {
                                    self.userSubmissions = JSON(value)
                                    self.userSubmissionsObjects += features as! [AnyObject]
                                }
                            }
                        }
                        
                        // Set visible button count
                        let _submission_count = self.userSubmissions!["properties"]["num_results"]
                        
                        if (_submission_count != "") {
                            self.buttonUserProfileSubmissionCount.setTitle("\(_submission_count)", forState: .Normal)
                        }
                        
                        // Refresh the data in the table so the newest items appear
                        self.submissionTableView.reloadData()
                        
                        self.userSubmissionsPage += 1
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

    
    func attemptLoadUserActions(isRefreshingReportsList: Bool = false) {
        
        // Load the user profile groups
        //
        let _headers = buildRequestHeaders()
        let GET_GROUPS_ENDPOINT = Endpoints.GET_USER_PROFILE + "\(userId)"
        
        Alamofire.request(.GET, GET_GROUPS_ENDPOINT, headers: _headers, encoding: .JSON).responseJSON { response in
            
            print("response.result \(response.result)")
            
            switch response.result {
            case .Success(let value):
                print("Request Success: \(value)")

                let json = JSON(value)
                
                // Retain the returned data
                self.userProfile = json

                var _parameters = [
                    "q": "{\"filters\":[{\"name\":\"owner_id\", \"op\":\"eq\", \"val\":\"\(self.userId!)\"}, {\"name\":\"state\", \"op\":\"eq\", \"val\":\"closed\"}],\"order_by\": [{\"field\":\"created\",\"direction\":\"desc\"}]}",
                    "page": "\(self.userActionsPage)"
                ]
                
                if (self.userProfile!["properties"]["roles"].count >= 1) {
                    if (self.userProfile!["properties"]["roles"][0]["properties"]["name"] == "admin") {
                        _parameters = [
                            "q": "{\"filters\":[{\"or\":[{\"and\":[{\"name\":\"owner_id\", \"op\":\"eq\", \"val\":\"\(self.userId!)\"},{\"name\":\"state\", \"op\":\"eq\", \"val\":\"closed\"}]},{\"name\":\"closed_id\", \"op\":\"eq\", \"val\":\"\(self.userId!)\"}]}],\"order_by\": [{\"field\":\"created\",\"direction\":\"desc\"}]}",
                            "page": "\(self.userActionsPage)"
                        ]
                        
                    }
                }
                
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
                                    self.userActions = JSON(value)
                                    self.userActionsObjects = value["features"] as! [AnyObject]
                                    self.actionRefreshControl.endRefreshing()
                                } else {
                                    
                                    if let features = value["features"] {
                                        if features != nil {
                                            self.userActions = JSON(value)
                                            self.userActionsObjects += features as! [AnyObject]
                                        }
                                    }
                                    
                                }

                                // Set visible button count
                                let _action_count = self.userActions!["properties"]["num_results"]
                                
                                if (_action_count >= 1) {
                                    self.buttonUserProfileActionCount.setTitle("\(_action_count)", forState: .Normal)
                                }
                                
                                // Refresh the data in the table so the newest items appear
                                self.actionsTableView.reloadData()
                                
                                self.userActionsPage += 1
                            }
                            
                            break
                        case .Failure(let error):
                            print("Request Failure: \(error)")
                            
                            // Stop showing the loading indicator
                            //self.status("doneLoadingWithError")
                            
                            break
                        }
                        
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
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if (tableView.restorationIdentifier == "submissionsTableView") {
            
            guard (JSON(self.userSubmissionsObjects) != nil) else { return 0 }

            if self.userSubmissionsObjects.count == 0 {
                return 1
            }

            return (self.userSubmissionsObjects.count)

        } else if (tableView.restorationIdentifier == "actionsTableView") {

            guard (JSON(self.userActionsObjects) != nil) else { return 0 }

            if self.userActionsObjects.count == 0 {
                return 1
            }

            return (self.userActionsObjects.count)
        
        } else if (tableView.restorationIdentifier == "groupsTableView") {
            
            guard (JSON(self.userGroupsObjects) != nil) else { return 0 }

            if self.userGroupsObjects.count == 0 {
                print("Groups showing 0, make sure at least 1 row is visible.")
                return 1
            }

            print("Groups showing count \(self.userGroupsObjects.count)")

            return (self.userGroupsObjects.count)

        }

        return 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let emptyCell = tableView.dequeueReusableCellWithIdentifier("emptyTableViewCell", forIndexPath: indexPath) as! EmptyTableViewCell

        if (tableView.restorationIdentifier == "submissionsTableView") {
            //
            // Submissions
            //
            let cell = tableView.dequeueReusableCellWithIdentifier("userProfileSubmissionCell", forIndexPath: indexPath) as! UserProfileSubmissionTableViewCell
            
            guard (self.userSubmissions != nil) else { return emptyCell }

            let _submissions = JSON(self.userSubmissionsObjects)
            
            let _thisSubmission = _submissions[indexPath.row]["properties"]
            
            print("Show (submissions) _thisSubmission \(_thisSubmission)")

            if _thisSubmission == nil {
                
                //
                // If the User Profile being viewed is no the Acting User's Profile
                // we need to change the empty message sentence to make sense in
                // this context.
                //
                if self.isActingUsersProfile == false {
                    emptyCell.emptyMessageDescription.text = "Looks like this user hasn't submitted any reports."
                    emptyCell.emptyMessageAction.hidden = true
                }
                else {
                    emptyCell.emptyMessageDescription.text = "No reports yet, post your first one now!"
                    emptyCell.emptyMessageAction.hidden = false
                    emptyCell.emptyMessageAction.addTarget(self, action: #selector(self.emptyMessageAddReport(_:)), forControlEvents: UIControlEvents.TouchUpInside)
                }

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
            if (indexPath.row == self.userSubmissionsObjects.count - 2 && self.userSubmissionsObjects.count < self.userSubmissions!["properties"]["num_results"].int) {
                self.attemptLoadUserSubmissions()
            }

            
            return cell
        } else if (tableView.restorationIdentifier == "actionsTableView") {
            //
            // Actions
            //
            let cell = tableView.dequeueReusableCellWithIdentifier("userProfileActionCell", forIndexPath: indexPath) as! UserProfileActionsTableViewCell
            
            guard (self.userActions != nil) else { return emptyCell }

            let _actions = JSON(self.userActionsObjects)
            let _thisSubmission = _actions[indexPath.row]["properties"]
            print("Show (actions) _thisSubmission \(_thisSubmission)")


            //
            // If the User Profile being viewed is no the Acting User's Profile
            // we need to change the empty message sentence to make sense in
            // this context.
            //
            if _thisSubmission == nil {

                if self.isActingUsersProfile == false {
                    emptyCell.emptyMessageDescription.text = "Looks like this user isn't affiliated with any actions yet."
                    emptyCell.emptyMessageAction.hidden = true
                }
                else {
                    emptyCell.emptyMessageDescription.text = "Looks like no actions have been taken yet."
                    emptyCell.emptyMessageAction.hidden = false
                    emptyCell.emptyMessageAction.addTarget(self, action: #selector(self.emptyMessageAddReport(_:)), forControlEvents: UIControlEvents.TouchUpInside)
                }
                
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
                cell.buttonReportLikeCount.addTarget(self, action: #selector(self.openActionsLikesList(_:)), forControlEvents: .TouchUpInside)

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

            if (indexPath.row == self.userActionsObjects.count - 2 && self.userActionsObjects.count < self.userActions!["properties"]["num_results"].int) {
                self.attemptLoadUserActions()
            }

            return cell
        } else if (tableView.restorationIdentifier == "groupsTableView") {
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
            
            if _thisSubmission == nil {
                
                if self.isActingUsersProfile == false {
                    emptyCell.emptyMessageDescription.text = "Looks like this user hasn't joined any groups."
                    emptyCell.emptyMessageAction.hidden = true
                }
                else {
                    emptyCell.emptyMessageDescription.text = "There’s power in numbers, join a group"
                    emptyCell.emptyMessageAction.hidden = false
                    emptyCell.emptyMessageAction.setTitle("Join a group", forState: .Normal)
                    emptyCell.emptyMessageAction.addTarget(self, action: #selector(self.emptyMessageJoinGroup(_:)), forControlEvents: UIControlEvents.TouchUpInside)
                }
                
                return emptyCell
            }
            
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
        }
        
        return emptyCell

    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        print("row tapped \(indexPath)")
    }
    
    
    //
    // MARK: Modify Reports
    //
    func attemptEditReport(report: JSON, reportId: String) {
        print("Push Edit Report View Controller")
        
        //
        // Load the activity controller from the storyboard
        //
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        
        let nextViewController = storyBoard.instantiateViewControllerWithIdentifier("NewPostTableViewController") as! NewPostTableViewController
        
        nextViewController.report = report
        nextViewController.reportId = reportId
        nextViewController.isEditingReport = true
        
        self.navigationController?.pushViewController(nextViewController, animated: true)

        
    }

    func attemptConfirmDeleteReport(reportId: String) {
        let thisActionSheet = UIAlertController(title: nil, message: "Are you sure you want to delete this report?", preferredStyle: .ActionSheet)
        
        let confirmDeleteReportAction = UIAlertAction(title: "Yes, delete this report", style: .Default, handler: {
            UIAlertAction in
            self.attemptDeleteReport(reportId)
        })
        thisActionSheet.addAction(confirmDeleteReportAction)
        
        let cancelDeleteReportAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        thisActionSheet.addAction(cancelDeleteReportAction)
        
        presentViewController(thisActionSheet, animated: true, completion: nil)
    }
    
    func attemptDeleteReport(reportId: String) {
        
        let _headers = buildRequestHeaders()
        let _endpoint = Endpoints.POST_REPORT + "/\(reportId)"
        
        Alamofire.request(.DELETE, _endpoint, headers: _headers, encoding: .JSON)
            .responseJSON { response in
                
                print("Response \(response)")
                
                switch response.result {
                case .Success(let value):
                    
                    print("Response Sucess \(value)")
                    
                    self.submissionRefreshControl.beginRefreshing()
                    
                    self.userSubmissionsPage = 1
                    self.userSubmissions = nil
                    self.userSubmissionsObjects = []
                    
                    self.attemptLoadUserSubmissions(true)

                case .Failure(let error):
                    
                    print("Response Failure \(error)")
                    
                    break
                }
                
        }
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
                    
                    if (self.actionsTableView.hidden == false) {
                        self.userActionsObjects[(reportSenderTag)] = value
                    }
                    else if (self.submissionTableView.hidden == false) {
                        self.userSubmissionsObjects[(reportSenderTag)] = value
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
