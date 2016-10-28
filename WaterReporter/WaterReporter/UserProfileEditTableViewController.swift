//
//  UserProfileEditTableViewController.swift
//  Water-Reporter
//
//  Created by Viable Industries on 9/22/16.
//  Copyright © 2016 Viable Industries, L.L.C. All rights reserved.
//

import Alamofire
import Foundation
import SwiftyJSON
import UIKit

class UserProfileEditTableViewController: UITableViewController {
        
    @IBOutlet weak var navigationButtonBarItemCancel: UIBarButtonItem!
    @IBOutlet weak var navigationButtonBarItemSave: UIBarButtonItem!
    @IBOutlet weak var textfieldFirstName: UITextField!
    @IBOutlet weak var textfieldLastName: UITextField!
    
    @IBOutlet weak var textfieldOrganizationName: UITextField!
    @IBOutlet weak var textfieldTelephone: UITextField!
    @IBOutlet weak var textfieldTitlePosition: UITextField!
    @IBOutlet weak var textfieldPublicEmail: UITextField!
    
    @IBOutlet weak var textfieldBio: UITextView!

    @IBOutlet var indicatorLoadingProfileView: UIView!
    
    @IBOutlet weak var indicatorLoadingProfileLabel: UILabel!
    @IBOutlet weak var indicatorSavingProfileLabel: UILabel!
    
    var userProfile: JSON?
    var loadingView: UIView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //
        // Hide the user profile until all elements are loaded
        //
        self.loading()
        
        
        //
        // Make sure we are getting 'auto layout' specific sizes
        // otherwise any math we do will be messed up
        //
        self.view.setNeedsLayout()
        self.view.layoutIfNeeded()
        
        navigationButtonBarItemSave.target = self
        navigationButtonBarItemSave.action = #selector(buttonSaveUserProfileEditTableViewController(_:))
        
        navigationButtonBarItemCancel.target = self
        navigationButtonBarItemCancel.action = #selector(buttonDismissUserProfileEditTableViewController(_:))
        
        
        //
        //
        //
        textfieldBio.text = "Bio"
        textfieldBio.textColor = UIColor.lightGrayColor()
        
        print(NSUserDefaults.standardUserDefaults().objectForKey("currentUserAccountAccessToken"))
        
        if let _userId = NSUserDefaults.standardUserDefaults().objectForKey("currentUserAccountUID") {
            self.attemptLoadUserProfile()
        } else {
            self.attemptRetrieveUserID()
        }
        
    }
    
    func loading() {
        
        //
        // Create a view that covers the entire screen
        //
        self.loadingView = self.indicatorLoadingProfileView
        self.loadingView.frame = CGRectMake(0, 0, self.view.frame.width, self.view.frame.height)
        
        self.view.addSubview(self.loadingView)
        self.view.bringSubviewToFront(self.loadingView)

        //
        // Make sure that the Done/Save button is disabled
        //
        self.navigationItem.rightBarButtonItem?.enabled = false
        self.navigationItem.leftBarButtonItem?.enabled = true
        
        //
        // Display the right label for the right action
        //
        self.indicatorSavingProfileLabel.hidden = true
        self.indicatorLoadingProfileLabel.hidden = false

    }
    
    func loadingComplete() {
        
        //
        // Remove loading screen
        //
        self.loadingView.removeFromSuperview()
        
        //
        // Re-enable the save button
        //
        self.navigationItem.rightBarButtonItem?.enabled = true
    }
    
    func saving() {
        
        //
        // Create a view that covers the entire screen
        //
        self.loadingView = self.indicatorLoadingProfileView
        self.loadingView.frame = CGRectMake(0, 0, self.view.frame.width, self.view.frame.height)
        
        self.view.addSubview(self.loadingView)
        self.view.bringSubviewToFront(self.loadingView)
        
        //
        // Make sure that the Done/Save button is disabled
        //
        self.navigationItem.rightBarButtonItem?.enabled = false
        self.navigationItem.leftBarButtonItem?.enabled = true
        
        //
        // Display the right label for the right action
        //
        self.indicatorSavingProfileLabel.hidden = false
        self.indicatorLoadingProfileLabel.hidden = true
    
    }
    
    func buttonDismissUserProfileEditTableViewController(sender:UIBarButtonItem) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    func buttonSaveUserProfileEditTableViewController(sender:UIBarButtonItem) {
        
        //
        // Hide the form during saving
        //
        self.saving()
        
        //
        // Construct the necessary headers and parameters to complete the request
        //
        let accessToken = NSUserDefaults.standardUserDefaults().objectForKey("currentUserAccountAccessToken")
        let headers = [
            "Authorization": "Bearer " + (accessToken! as! String)
        ]
        
        let parameters = [
            "first_name": self.textfieldFirstName.text!,
            "last_name": self.textfieldLastName.text!,
            "organization_name": self.textfieldOrganizationName.text!,
            "title": self.textfieldTitlePosition.text!,
            "public_email": self.textfieldPublicEmail.text!,
            "telephone": "[{\"number\":\"" + self.textfieldTelephone.text! + "\"}]",
            "description": self.textfieldBio.text!
        ]

        
        Alamofire.request(.GET, Endpoints.GET_USER_ME, headers: headers, encoding: .JSON)
            .responseJSON { response in
            
                switch response.result {
                case .Success(let value):
                    
                    var userId: String? = ""
                    
                    if let userIdNumber = value.valueForKey("id") as? NSNumber
                    {
                        userId = "\(userIdNumber)"
                    }

                    if (userId != "") {
                        self.attemptUserProfileSave(userId!, headers: headers, parameters: parameters)
                    }
                    
                    print(value)
                    
                case .Failure(let error):
                    print(error)
                    break
                }
            
            }
        
    }
    
    func attemptUserProfileSave(userId: String, headers: [String: String], parameters: [String: String]) {
        
        let _endpoint = Endpoints.POST_USER_PROFILE + userId;
        
        Alamofire.request(.PATCH, _endpoint, parameters: parameters, headers: headers, encoding: .JSON)
            .responseJSON { response in
                
                switch response.result {
                case .Success(let value):
                    self.dismissViewControllerAnimated(true, completion: {
                        self.dismissViewControllerAnimated(true, completion: nil)
                    })
                    
                case .Failure(let error):
                    print("attemptUserProfileSave::Failure")
                    print(error)
                    break
                }
                
        }
        
    }

    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        let nextTage = textField.tag + 1;
        let nextResponder=textField.superview?.superview?.superview?.viewWithTag(nextTage) as UIResponder!
        
        if (nextResponder != nil){
            nextResponder?.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
        }
        
        return false
    }
    
    func textViewDidBeginEditing(textView: UITextView) {
        if textView.textColor == UIColor.lightGrayColor() {
            textView.text = nil
            textView.textColor = UIColor.blackColor()
        }
    }

    func textViewDidEndEditing(textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Bio"
            textView.textColor = UIColor.lightGrayColor()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        
        NSLog("LoginViewController::didReceiveMemoryWarning")
    }
    
    //
    // MARK: Server Request/Response functionality
    //
    
    func attemptLoadUserProfile() {
        
        let accessToken = NSUserDefaults.standardUserDefaults().objectForKey("currentUserAccountAccessToken")
        let headers = [
            "Authorization": "Bearer " + (accessToken! as! String)
        ]

        if let userId = NSUserDefaults.standardUserDefaults().objectForKey("currentUserAccountUID") {
            let revisedEndpoint = Endpoints.GET_USER_PROFILE + String(userId)
            
            Alamofire.request(.GET, revisedEndpoint, headers: headers, encoding: .JSON).responseJSON { response in
                if let value = response.result.value {
                    self.userProfile = JSON(value)
                    self.updateUserProfileFields()
                    
                    self.loadingComplete()
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
    
    func updateUserProfileFields() {
        print("updateUserProfileFields")
        print(self.userProfile)
        
        if let userFirstName = self.userProfile?["properties"]["first_name"].string {
            self.textfieldFirstName.text = userFirstName
        }

        if let userLastName = self.userProfile?["properties"]["last_name"].string {
            self.textfieldLastName.text = userLastName
        }

        if let userTitle = self.userProfile?["properties"]["title"].string {
            self.textfieldTitlePosition.text = userTitle
        }

        if let userOrganizationName = self.userProfile?["properties"]["organization_name"].string {
            self.textfieldOrganizationName.text = userOrganizationName
        }

        if let userPublicEmail = self.userProfile?["properties"]["public_email"].string {
            self.textfieldPublicEmail.text = userPublicEmail
        }

        if let userDescription = self.userProfile?["properties"]["description"].string {
            self.textfieldBio.text = userDescription
        }

        
        self.tableView.reloadData()
        
    }

}
