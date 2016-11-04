//
//  ProfileTableViewController.swift
//  WaterReporter
//
//  Created by Viable Industries on 7/24/16.
//  Copyright © 2016 Viable Industries, L.L.C. All rights reserved.
//

import Alamofire
import SwiftyJSON
import UIKit

class ProfileTableViewController: UITableViewController {
    
    @IBOutlet var profileHeaderView: UIView!
    
    @IBOutlet weak var buttonUserProfileOrganization: UIButton!
    @IBOutlet weak var buttonUserProfileSubmissions: UIButton!
    @IBOutlet weak var buttonUserProfileActions: UIButton!
    @IBOutlet var indicatorLoadingView: UIView!

    @IBOutlet weak var profileUserDescription: UILabel!
    @IBOutlet weak var profileUserImage: UIImageView!
    @IBOutlet weak var profileUserName: UILabel!
    @IBOutlet weak var profileUserTitleOrganization: UILabel!
    @IBOutlet weak var profileUserOrganizationName: UILabel!
    //
    // Controller-wide
    //
    var userProfile: JSON?
    var loadingView: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()
        NSLog("ProfileViewController::viewDidLoad")

        //
        // Make sure we are getting 'auto layout' specific sizes
        // otherwise any math we do will be messed up
        //
        self.view.setNeedsLayout()
        self.view.layoutIfNeeded()

        //
        // Show the loading indicator while the profile loads
        //
        self.loading()

        
        //
        // Set the Navigation Bar title
        //
        self.navigationItem.title = "Profile"
        
        
        //
        // Restyle the form Log In Navigation button to appear with an underline
        //
        let border = CALayer()
        let buttonWidth = self.buttonUserProfileSubmissions.frame.width
        let buttonHeight = self.buttonUserProfileSubmissions.frame.size.height
        
        border.borderColor = CGColor.colorBrand()
        border.borderWidth = 2.0
        
        border.frame = CGRectMake(0, self.buttonUserProfileSubmissions.frame.size.height - 2.0, buttonWidth, buttonHeight)
        
        self.buttonUserProfileSubmissions.layer.addSublayer(border)
        self.buttonUserProfileSubmissions.layer.masksToBounds = true

        
        //
        //
        //
        if let _userId = NSUserDefaults.standardUserDefaults().objectForKey("currentUserAccountUID")?.string {
            self.attemptLoadUserProfile()
        } else {
            self.attemptRetrieveUserID()
        }
        
        //
        // Setup Tap Gesture Recognizers so that we can toggle the
        // number of lines for user profile labels
        //
        self.profileUserTitleOrganization.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(ProfileTableViewController.toggleUILableNumberOfLines(_:))))
        self.profileUserDescription.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(ProfileTableViewController.toggleUILableNumberOfLines(_:))))
        self.profileUserOrganizationName.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(ProfileTableViewController.toggleUILableNumberOfLines(_:))))

    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
        
        tableView.sectionHeaderHeight = UITableViewAutomaticDimension
        tableView.estimatedSectionHeaderHeight = 200.0

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //
    // MARK:
    //
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let headerView: UIView = self.profileHeaderView
        
        switch section {
            default:
                return headerView
        }
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 200.0
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("UserProfileTableViewCell", forIndexPath: indexPath) as! UITableViewCell
        
        return cell

    }
    
    //
    // MARK: Server Request/Response functionality
    //
    func loading() {

        //
        // Create a view that covers the entire screen
        //
        self.loadingView = self.indicatorLoadingView
        self.loadingView.frame = CGRectMake(0, 0, self.view.frame.width, self.view.frame.height)
        
        self.view.addSubview(self.loadingView)
        self.view.bringSubviewToFront(self.loadingView)
        
        //
        //
        //
        self.profileHeaderView.hidden = true
    }
    
    func loadingComplete() {
        self.loadingView.removeFromSuperview()
        self.profileHeaderView.hidden = false
    }
    
    func attemptLoadUserProfile() {
        
        print("attemptLoadUserProfile")
        
        let accessToken = NSUserDefaults.standardUserDefaults().objectForKey("currentUserAccountAccessToken")
        let headers = [
            "Authorization": "Bearer " + (accessToken! as! String)
        ]
        
        if let _userId = NSUserDefaults.standardUserDefaults().objectForKey("currentUserAccountUID") {
            let revisedEndpoint = Endpoints.GET_USER_PROFILE + String(_userId)
            
            Alamofire.request(.GET, revisedEndpoint, headers: headers, encoding: .JSON).responseJSON { response in
                if let value = response.result.value {
                    self.userProfile = JSON(value)
                    
                    print("self.userProfile \(self.userProfile)")
                    
                    self.attemptDisplayUserProfile()
                }
            }
            
        }
        
    }
    
    func attemptRetrieveUserID() {
        
        let accessToken = NSUserDefaults.standardUserDefaults().objectForKey("currentUserAccountAccessToken")
        let headers = [
            "Authorization": "Bearer " + (accessToken! as! String)
        ]
        
        Alamofire.request(.GET, Endpoints.GET_USER_ME, headers: headers, encoding: .JSON)
            .responseJSON { response in
                
                switch response.result {
                case .Success(let value):
                    let json = JSON(value)
                    
                    if let data: AnyObject = json.rawValue {
                        NSUserDefaults.standardUserDefaults().setValue(data["id"], forKeyPath: "currentUserAccountUID")
                        
                        self.attemptLoadUserProfile()
                    }
                    
                case .Failure(let error):
                    print(error)
                }
        }
    }

    func attemptDisplayUserProfile() {
        
        //
        // Display User's First and Last Name
        //
        if let _userFirstName = self.userProfile!["properties"]["first_name"].string,
            let _userLastName = self.userProfile!["properties"]["last_name"].string {
            self.profileUserName.text = _userFirstName + " " + _userLastName
        }

        //
        // Display User's Title and/or Organization Name
        //
        if let _userTitle = self.userProfile!["properties"]["title"].string,
            let _userOrganization = self.userProfile!["properties"]["organization_name"].string {
            self.profileUserTitleOrganization.text = _userTitle
            self.profileUserOrganizationName.text = "at " + _userOrganization
        } else if let _userOrganization = self.userProfile!["properties"]["organization_name"].string {
            self.profileUserOrganizationName.text = _userOrganization
        } else if let _userTitle = self.userProfile!["properties"]["title"].string {
            self.profileUserTitleOrganization.text = _userTitle
        }
        
        //
        //
        //
        if let _userDescription = self.userProfile!["properties"]["description"].string {
            self.profileUserDescription.text = _userDescription
        }

        //
        // Display User's Profile Image
        //
        var profileUserImageUrl:NSURL! = NSURL(string: "https://www.waterreporter.org/images/badget--MissingUser.png")
        
        if let thisProfileUserImageURL = self.userProfile!["properties"]["picture"].string {
            profileUserImageUrl = NSURL(string: String(thisProfileUserImageURL))
        }
        
        self.profileUserImage.kf_indicatorType = .Activity
        self.profileUserImage.kf_showIndicatorWhenLoading = true
        
        self.profileUserImage.kf_setImageWithURL(profileUserImageUrl, placeholderImage: nil, optionsInfo: nil, progressBlock: nil, completionHandler: {
            (image, error, cacheType, imageUrl) in

            self.profileUserImage.image = image
            self.profileUserImage.layer.cornerRadius = 32.0
            self.profileUserImage.clipsToBounds = true

            self.loadingComplete()
        })
        
        //
        //
        //
        
    }
    
    @IBAction func toggleUILableNumberOfLines(sender: UITapGestureRecognizer) {
        
        let field: UILabel = sender.view as! UILabel
        
        var numberOfLines: Int = field.numberOfLines
        
        switch field.numberOfLines {
            case 0:
                if sender.view?.restorationIdentifier == "profileUserDescription" {
                    numberOfLines = 3
                }
                else {
                    numberOfLines = 1
                }
                break
            default:
                numberOfLines = 0
                break
        }
        
        field.numberOfLines = numberOfLines
        
    }
    
}

