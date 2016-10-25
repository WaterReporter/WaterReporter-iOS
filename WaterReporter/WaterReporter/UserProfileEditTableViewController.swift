//
//  UserProfileEditTableViewController.swift
//  Water-Reporter
//
//  Created by Viable Industries on 9/22/16.
//  Copyright © 2016 Viable Industries, L.L.C. All rights reserved.
//

import Alamofire
import Foundation
import UIKit

class UserProfileEditTableViewController: UITableViewController {
        
    @IBOutlet weak var navigationButtonBarItemSave: UIBarButtonItem!
    @IBOutlet weak var textfieldFirstName: UITextField!
    @IBOutlet weak var textfieldLastName: UITextField!
    
    @IBOutlet weak var textfieldOrganizationName: UITextField!
    @IBOutlet weak var textfieldTelephone: UITextField!
    @IBOutlet weak var textfieldTitlePosition: UITextField!
    @IBOutlet weak var textfieldPublicEmail: UITextField!
    
    @IBOutlet weak var textfieldBio: UITextField!
    
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        
        NSLog("LoginViewController::didReceiveMemoryWarning")
    }
    
}
