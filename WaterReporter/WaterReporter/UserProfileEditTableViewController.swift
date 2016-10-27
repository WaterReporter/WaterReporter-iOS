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
        
    @IBOutlet weak var navigationButtonBarItemSave: UIBarButtonItem!
    @IBOutlet weak var textfieldFirstName: UITextField!
    @IBOutlet weak var textfieldLastName: UITextField!
    
    @IBOutlet weak var textfieldOrganizationName: UITextField!
    @IBOutlet weak var textfieldTelephone: UITextField!
    @IBOutlet weak var textfieldTitlePosition: UITextField!
    @IBOutlet weak var textfieldPublicEmail: UITextField!
    
    @IBOutlet weak var textfieldBio: UITextView!
    
    var userProfile: JSON?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //
        // Make sure we are getting 'auto layout' specific sizes
        // otherwise any math we do will be messed up
        //
        self.view.setNeedsLayout()
        self.view.layoutIfNeeded()
        
        navigationButtonBarItemSave.target = self
        navigationButtonBarItemSave.action = #selector(buttonSaveUserProfileEditTableViewController(_:))
        
        
        //
        //
        //
        textfieldBio.text = "Bio"
        textfieldBio.textColor = UIColor.lightGrayColor()
        
        print("Current user token")
        print(NSUserDefaults.standardUserDefaults().objectForKey("currentUserAccountAccessToken"))
        
        if let _userId = NSUserDefaults.standardUserDefaults().objectForKey("currentUserAccountUID") {
            self.attemptLoadUserProfile()
        } else {
            self.attemptRetrieveUserID()
        }
        
    }
    
    func buttonDismissUserProfileEditTableViewController(sender:UIBarButtonItem) {
        print("dismiss")
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    func buttonSaveUserProfileEditTableViewController(sender:UIBarButtonItem) {
        print("save")
        
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
        
        print("parameters")
        print(parameters)

        print("headers")
        print(headers)

        let _endpoint = Endpoints.POST_USER_PROFILE + userId;
        print("_endpoint")
        print(_endpoint)
        
        Alamofire.request(.PATCH, _endpoint, parameters: parameters, headers: headers, encoding: .JSON)
            .responseJSON { response in
                
                switch response.result {
                case .Success(let value):
                    
                    print("attemptUserProfileSave::Success")
                    print(value)
                    
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
