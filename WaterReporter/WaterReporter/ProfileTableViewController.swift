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

    @IBOutlet weak var submissionTableView: UITableView!

    
    //
    // MARK: @IBActions
    //
    
    @IBAction func openSubmissionsLikesList(sender: UIButton) {
        
        let nextViewController = self.storyBoard.instantiateViewControllerWithIdentifier("LikesTableViewController") as! LikesTableViewController
        
        let report = self.userPostsObjects[(sender.tag)]
        nextViewController.report = report
        
        self.navigationController?.pushViewController(nextViewController, animated: true)
        
    }
    
    @IBAction func openSubmissionOpenGraphURL(sender: UIButton) {
        
        let reportId = sender.tag
        let report = JSON(self.userPostsObjects[reportId])
        
        let reportURL = "\(report["properties"]["social"][0]["properties"]["og_url"])"
        
        print("openOpenGraphURL \(reportURL)")
        
        UIApplication.sharedApplication().openURL(NSURL(string: "\(reportURL)")!)
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
        
        let _submissions = JSON(self.userPostsObjects)
        let reportCoordinates = _submissions[sender.tag]["geometry"]["geometries"][0]["coordinates"]
        
        UIApplication.sharedApplication().openURL(NSURL(string: "https://www.google.com/maps/dir//\(reportCoordinates[1]),\(reportCoordinates[0])")!)
    }

    @IBAction func shareSubmissionsButtonClicked(sender: UIButton) {
        
        let _thisReport = JSON(self.userPostsObjects[(sender.tag)])
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
        
        nextViewController.reportObject = self.userPostsObjects[sender.tag]
        
        self.navigationController?.pushViewController(nextViewController, animated: true)
        
    }
    
    @IBAction func openUserSubmissionCommentsView(sender: UIButton) {
        let nextViewController = self.storyBoard.instantiateViewControllerWithIdentifier("ReportCommentsTableViewController") as! ReportCommentsTableViewController
        
        nextViewController.report = self.userPostsObjects[sender.tag]
        
        self.navigationController?.pushViewController(nextViewController, animated: true)
        
    }
    
    @IBAction func openModificationSelector(sender: UIButton) {
        
        let thisActionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        
        let editReportAction = UIAlertAction(title: "Edit Report", style: .Default, handler: {
            UIAlertAction in
            let _submissions = JSON(self.userPostsObjects)
            let _report = _submissions[sender.tag]
            let _report_id: String! = "\(_submissions[sender.tag]["id"])"

            self.attemptEditReport(_report, reportId: _report_id)
        })
        thisActionSheet.addAction(editReportAction)

        let deleteReportAction = UIAlertAction(title: "Delete Report", style: .Default, handler: {
            UIAlertAction in
            let _submissions = JSON(self.userPostsObjects)
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
        
        _thisReport = JSON(self.userPostsObjects[(sender.tag)])
        
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

    var userPosts: JSON?
    var userPostsObjects = [AnyObject]()
    var userPostsPage: Int = 1
    var submissionRefreshControl: UIRefreshControl = UIRefreshControl()

    var userGroupsUnderline = CALayer()
    var userPostsUnderline = CALayer()
    var userActionsUnderline = CALayer()
    
    var likeDelay: NSTimer = NSTimer()
    var unlikeDelay: NSTimer = NSTimer()
    
    //
    // Table header view
    //
    
    lazy var profileTableHeader: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(
            red: 245.0/255.0,
            green: 247.0/255.0,
            blue: 249.0/255.0,
            alpha: 1.0
        )
        return view
    }()
    
    //
    // Stat group view
    //
    
    lazy var statGroupView: UIView = {
        let view = UIView()
        view.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 32)
        view.alpha = 0.0
        view.backgroundColor = UIColor(
            red: 200.0/255.0,
            green: 208.0/255.0,
            blue: 216.0/255.0,
            alpha: 0.0
        )
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

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
            
            self.navigationItem.title = ""
            
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
        self.submissionTableView.frame = view.frame
        
        //
        // SETUP SUBMISSION TABLE
        //
        self.submissionTableView.delegate = self
        self.submissionTableView.dataSource = self
        
        submissionRefreshControl = UIRefreshControl()
        submissionRefreshControl.restorationIdentifier = "submissionRefreshControl"
        
        submissionRefreshControl.addTarget(self, action: #selector(ProfileTableViewController.refreshSubsmissionsTableView(_:)), forControlEvents: .ValueChanged)
        
        submissionTableView.addSubview(submissionRefreshControl)
        
        // Make sure we are getting 'auto layout' specific sizes
        // otherwise any math we do will be messed up
        self.view.setNeedsLayout()
        self.view.layoutIfNeeded()
        
        
        // SET DEFAULT SELECTED TAB
        //
        
        self.submissionTableView.hidden = false
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        let backItem = UIBarButtonItem()
        
        if let firstName = self.userProfile!["properties"]["first_name"].string,
            let lastName = self.userProfile!["properties"]["last_name"].string {
            
            backItem.title = firstName + " " + lastName
            
        }
        
        navigationItem.backBarButtonItem = backItem // This will show in the next view controller being pushed
        
    }
    
    //
    // MARK: Custom Functionality
    //
    
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
        
        let report = self.userPostsObjects[postId]
        
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
        
        let report = JSON(self.userPostsObjects[reportId])
        
        let reportURL = "\(report["properties"]["social"][0]["properties"]["og_url"])"
        
        print("openOpenGraphURL \(reportURL)")
        
        UIApplication.sharedApplication().openURL(NSURL(string: "\(reportURL)")!)
    }
    
    func openUserActionsList(gesture: UITapGestureRecognizer) {
        
        print("Open user actions list")
        
        let backItem = UIBarButtonItem()
        
        if let firstName = self.userProfile!["properties"]["first_name"].string,
            let lastName = self.userProfile!["properties"]["last_name"].string {
            
            backItem.title = firstName + " " + lastName
            
        }
        
        navigationItem.backBarButtonItem = backItem // This will show in the next view controller being pushed
        
        let nextViewController = self.storyBoard.instantiateViewControllerWithIdentifier("UserActionsTableViewController") as! UserActionsTableViewController
        
        nextViewController.userId = self.userId
        
        self.navigationController?.pushViewController(nextViewController, animated: true)
        
    }
    
    func openUserGroupsList(gesture: UITapGestureRecognizer) {
        
        print("Open user groups list")
        
        let backItem = UIBarButtonItem()
        
        if let firstName = self.userProfile!["properties"]["first_name"].string,
            let lastName = self.userProfile!["properties"]["last_name"].string {
            
            backItem.title = firstName + " " + lastName
            
        }
        
        navigationItem.backBarButtonItem = backItem // This will show in the next view controller being pushed
        
        let nextViewController = self.storyBoard.instantiateViewControllerWithIdentifier("UserGroupsTableViewController") as! UserGroupsTableViewController
        
        nextViewController.userId = self.userId
        
        self.navigationController?.pushViewController(nextViewController, animated: true)
        
    }
    
    func refreshSubsmissionsTableView(sender: UIRefreshControl) {
        
        self.userPostsPage = 1
        self.userPosts = nil
        self.userPostsObjects = []

        self.attemptLoadUserPosts(true)

    }
    
    func retrieveUserTitle(userObject: JSON?) -> String {
        
        var userTitleString = ""
        
        var titleArray = [String]()
        
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
        
        statGroupView.bottomAnchor.constraintEqualToAnchor(self.profileTableHeader.bottomAnchor, constant: 0.0).active = true
        statGroupView.leadingAnchor.constraintEqualToAnchor(self.profileTableHeader.leadingAnchor, constant: 0.0).active = true
        statGroupView.trailingAnchor.constraintEqualToAnchor(self.profileTableHeader.trailingAnchor, constant: 0.0).active = true
        statGroupView.heightAnchor.constraintEqualToConstant(40.0).active = true
        
        //
        // Post count
        //
        
        let postCountLabel: UILabel = {
            let label = UILabel()
            label.textAlignment = .Center
            label.font = UIFont.systemFontOfSize(13, weight: UIFontWeightSemibold)
            label.translatesAutoresizingMaskIntoConstraints = false
            label.userInteractionEnabled = true
            label.tag = 0
            return label
        }()
        
        //
        // Action count
        //
        
        let actionCountLabel: UILabel = {
            let label = UILabel()
            label.textAlignment = .Center
            label.font = UIFont.systemFontOfSize(13, weight: UIFontWeightSemibold)
            label.translatesAutoresizingMaskIntoConstraints = false
            label.userInteractionEnabled = true
            label.tag = 1
            return label
        }()
        
        let actionCountTapGesture: UITapGestureRecognizer = UITapGestureRecognizer.init(target: self, action: #selector(self.openUserActionsList(_:)))
        actionCountTapGesture.numberOfTapsRequired = 1
        
        //
        // Group count
        //
        
        let groupCountLabel: UILabel = {
            let label = UILabel()
            label.textAlignment = .Center
            label.font = UIFont.systemFontOfSize(13, weight: UIFontWeightSemibold)
            label.translatesAutoresizingMaskIntoConstraints = false
            label.userInteractionEnabled = true
            label.tag = 2
            return label
        }()
        
        let groupCountTapGesture: UITapGestureRecognizer = UITapGestureRecognizer.init(target: self, action: #selector(self.openUserGroupsList(_:)))
        groupCountTapGesture.numberOfTapsRequired = 1
        
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
            
            actionCountLabel.addGestureRecognizer(actionCountTapGesture)
            
        } else {
            
            print("No action count")
            
        }

        
        if let groupCount = self.userSnapshot!["groups"].int {
            
            groupCountLabel.text = "\(groupCount) groups"
            
            if groupCount == 1 {
                
                groupCountLabel.text = "\(groupCount) group"
                
            }
            
            groupCountLabel.addGestureRecognizer(groupCountTapGesture)
            
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
        
        //
        // User image view
        //
        
        let userImageView: UIImageView = {
            let imageView = UIImageView()
            imageView.frame = CGRect(x: 0, y: 0, width: 64, height: 64)
            imageView.heightAnchor.constraintEqualToConstant(64.0).active = true
            imageView.widthAnchor.constraintEqualToConstant(64.0).active = true
            imageView.translatesAutoresizingMaskIntoConstraints = false
            return imageView
        }()
        
        var userProfileImageURL: NSURL! = NSURL(string: "https://www.waterreporter.org/community/images/badget--MissingUser.png")
        
        if let thisUserProfileImageURLString = self.userProfile!["properties"]["picture"].string {
            userProfileImageURL = NSURL(string: String(thisUserProfileImageURLString))
        }
        
        userImageView.kf_setImageWithURL(userProfileImageURL, placeholderImage: nil, optionsInfo: nil, progressBlock: nil, completionHandler: {
            (image, error, cacheType, imageUrl) in
            if (image != nil) {
                userImageView.image = UIImage(CGImage: (image?.CGImage)!, scale: (image?.scale)!, orientation: UIImageOrientation.Up)
            }
            userImageView.layer.cornerRadius = userImageView.frame.size.width / 2
            userImageView.clipsToBounds = true
        })
        
        //
        // User name label
        //
        
        let userNameLabel: UILabel = {
            let label = UILabel()
            label.textAlignment = .Center
            label.font = UIFont.systemFontOfSize(17, weight: UIFontWeightRegular)
            label.widthAnchor.constraintEqualToConstant(272.0).active = true
            label.translatesAutoresizingMaskIntoConstraints = false
            return label
        }()
        
        if self.userProfile!["properties"]["first_name"].string != "" && self.userProfile!["properties"]["last_name"].string != "" {
            
            // Display user's first and last name
            
            userNameLabel.text = self.userProfile!["properties"]["first_name"].string! + " " + self.userProfile!["properties"]["last_name"].string!
            
            print("Display User's Name \(userNameLabel.text)")
            
        }
        else {
            
            //
            // Activate the "Finish Profile" prompt
            //
            print("Display Finish Profile Prompt")
            
        }
        
        //
        // Display user title
        //
        
        let userTitleLabel: UILabel = {
            let label = UILabel()
            label.textAlignment = .Center
            label.font = UIFont.systemFontOfSize(12, weight: UIFontWeightRegular)
            label.widthAnchor.constraintEqualToConstant(272.0).active = true
            label.translatesAutoresizingMaskIntoConstraints = false
            return label
        }()
        
        let userTitleString = retrieveUserTitle(self.userProfile)
        
        if userTitleString != "" &&
            userTitleString != "at" {

            userTitleLabel.text = userTitleString
            
        }
        
        //
        // Display user bio
        //
        
        let userBioLabel: UILabel = {
            let label = UILabel()
            label.textAlignment = .Center
            label.font = UIFont.systemFontOfSize(13, weight: UIFontWeightRegular)
            label.widthAnchor.constraintEqualToConstant(272.0).active = true
            label.numberOfLines = 2
            label.lineBreakMode = .ByTruncatingTail
            label.translatesAutoresizingMaskIntoConstraints = false
            return label
        }()
        
        if let userBio = self.userProfile!["properties"]["description"].string {
        
            if userBio != "Bio" && userBio.characters.count > 1 {
                
                userBioLabel.text = userBio
            
            }
            
        }
        
        //
        // Profile header master stack view
        //
        
        let headerStackView: UIStackView = {
            let stackView = UIStackView(arrangedSubviews: [userImageView, userNameLabel, userTitleLabel, userBioLabel])
            stackView.alignment = .Center
            stackView.distribution = .Fill
            stackView.spacing = 8
            stackView.axis = .Vertical
            stackView.translatesAutoresizingMaskIntoConstraints = false
            return stackView
        }()
        
        //
        // Adjust header container view height
        //
        
        var baseHeaderHeight = 113.0
        
        if let titleText = userTitleLabel.text where !titleText.isEmpty {
            
            baseHeaderHeight += 20.0
            
        }
        
        if let bioText = userBioLabel.text where !bioText.isEmpty {
            
            baseHeaderHeight += 50.0
            
        }
        
        let headerHeight = CGFloat(baseHeaderHeight + 40.0)
        
        profileTableHeader.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: headerHeight)
        
        profileTableHeader.addSubview(headerStackView)
        
        headerStackView.leadingAnchor.constraintEqualToAnchor(profileTableHeader.leadingAnchor).active = true
        headerStackView.trailingAnchor.constraintEqualToAnchor(profileTableHeader.trailingAnchor).active = true
        headerStackView.topAnchor.constraintEqualToAnchor(profileTableHeader.topAnchor, constant: 16.0).active = true
        
        self.submissionTableView.tableHeaderView = self.profileTableHeader
        
        //
        // Load and display other user information
        //
        if !withoutReportReload {
            
            self.attemptLoadUserPosts()
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
                
                print("Response Success \(value)")
                
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
    
    func attemptLoadUserPosts(isRefreshingReportsList: Bool = false) {
        
        let _parameters = [
            "q": "{\"filters\":[{\"name\":\"owner_id\",\"op\":\"eq\",\"val\":\"\(self.userId)\"}],\"order_by\": [{\"field\":\"created\",\"direction\":\"desc\"}]}",
            "page": "\(self.userPostsPage)"
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
                            self.userPosts = JSON(value)
                            self.userPostsObjects = value["features"] as! [AnyObject]
                            self.submissionRefreshControl.endRefreshing()
                        } else {
                            if let features = value["features"] {
                                if features != nil {
                                    self.userPosts = JSON(value)
                                    self.userPostsObjects += features as! [AnyObject]
                                }
                            }
                        }
                        
                        // Refresh the data in the table so the newest items appear
                        self.submissionTableView.reloadData()
                        
                        self.userPostsPage += 1
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
            
        guard (JSON(self.userPostsObjects) != nil) else { return 0 }

        if self.userPostsObjects.count == 0 {
            return 1
        }

        return (self.userPostsObjects.count)
        
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection  section: Int) -> UIView? {
        
        return self.profileTableHeader;
        
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let emptyCell = tableView.dequeueReusableCellWithIdentifier("emptyTableViewCell", forIndexPath: indexPath) as! EmptyTableViewCell
        
        let cell = tableView.dequeueReusableCellWithIdentifier("basePostTableCell", forIndexPath: indexPath) as! BasePostTableCell
        
        if (self.userPostsObjects.count >= 1) {
            
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
            let report = self.userPostsObjects[indexPath.row].objectForKey("properties")
            let reportJson = JSON(report!)
            cell.reportObject = report
            
            let reportDescription = report?.objectForKey("report_description")
            
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
                
            }
            
            //
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
            
            //
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
            
            if reportGroups?.count > 0 {
                cell.reportGroupStack.hidden = false
            }
            else {
                cell.reportGroupStack.hidden = true
            }
            
            for (index, _group) in reportGroups!.enumerate() {
                
                if let groupLogoUrl = _group.objectForKey("properties")!.objectForKey("picture") as? String,
                    let groupName = _group.objectForKey("properties")!.objectForKey("name") as? String{
                    
                    let imageURL:NSURL = NSURL(string: "\(groupLogoUrl)")!
                    
                    print("Group logo URL \(imageURL)")
                    
                    let imageView = UIImageView()
                    
                    imageView.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
                    
                    imageView.heightAnchor.constraintEqualToConstant(40.0).active = true
                    imageView.widthAnchor.constraintEqualToConstant(40.0).active = true
                    
                    imageView.setContentHuggingPriority(UILayoutPriorityRequired, forAxis: .Horizontal)
                    imageView.setContentCompressionResistancePriority(UILayoutPriorityRequired, forAxis: .Horizontal)
                    
                    imageView.kf_setImageWithURL(imageURL, placeholderImage: nil, optionsInfo: nil, progressBlock: nil, completionHandler: {
                        (image, error, cacheType, imageUrl) in
                        
                        if (image != nil) {
                            imageView.image = UIImage(CGImage: (image?.CGImage)!, scale: (image?.scale)!, orientation: UIImageOrientation.Up)
                            imageView.layer.cornerRadius = imageView.frame.size.width / 2
                            imageView.clipsToBounds = true
                        }
                        
                    })
                    
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
            
            if (indexPath.row == self.userPostsObjects.count - 5) {
                self.attemptLoadUserPosts()
            }
            
        }
        
        return cell

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
                    
                    self.userPostsPage = 1
                    self.userPosts = nil
                    self.userPostsObjects = []
                    
                    self.attemptLoadUserPosts(true)

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
        
        var _cell = self.submissionTableView.cellForRowAtIndexPath(_indexPath) as! UserProfileSubmissionTableViewCell
        _report = JSON(self.userPostsObjects[(indexPathRow)].objectForKey("properties")!)
        
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
            
            _report = JSON(self.userPostsObjects[(senderTag)])
            
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
        
        self.unlikeDelay = NSTimer.scheduledTimerWithTimeInterval(NSTimeInterval(1), target: self, selector: #selector(self.attemptUnlikeCurrentReport(_:)), userInfo: infoDict, repeats: false)
        
    }
    
    func attemptUnlikeCurrentReport(timer: NSTimer) {
        
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
            
            _report = JSON(self.userPostsObjects[(senderTag)])
            
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
                        
                        print("Response Success \(value)")
                        
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
                        
                        self.userPostsObjects[(reportSenderTag)] = value
                        
                        break
                        
                    case .Failure(let error):
                        
                        print("Response Failure \(error)")
                        
                        break
                    
                }
                
            }
        
    }

}
