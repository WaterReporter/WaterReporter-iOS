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
        // Show the loading indicator while the profile loads
        //
        self.loading()

        
        //
        // Set the Navigation Bar title
        //
        self.navigationItem.title = "Profile"
        
        //
        //
        //
        if let _userId = NSUserDefaults.standardUserDefaults().objectForKey("currentUserAccountUID")?.string {
            print("attemptLoadUserProfile")
            self.attemptLoadUserProfile()
        } else {
            print("attemptRetrieveUserID")
            self.attemptRetrieveUserID()
        }
        
        let expandUserProfileDescription = UITapGestureRecognizer(target: self, action: #selector(ProfileTableViewController.expandUserProfileDescription(_:)))

        self.profileUserDescription.addGestureRecognizer(expandUserProfileDescription)

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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

    }
    
    func loadingComplete() {
        self.loadingView.removeFromSuperview()
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
    
    func expandUserProfileDescription(sender: UITapGestureRecognizer) {
        
        let description = self.profileUserDescription
        
        if (description.numberOfLines == 3) {
            self.profileUserDescription.numberOfLines = 0
        } else if (description.numberOfLines == 0) {
            self.profileUserDescription.numberOfLines = 3
        }
        
        print("expandUserProfileDescription \(sender)")
    }
    
}

