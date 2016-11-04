//
//  ForgotPasswordTableViewController.swift
//  Water-Reporter
//
//  Created by Viable Industries on 9/22/16.
//  Copyright © 2016 Viable Industries, L.L.C. All rights reserved.
//

import Alamofire
import Foundation
import UIKit

class ForgotPasswordTableViewController: UITableViewController {
    
    @IBOutlet weak var textfieldEmailAddress: UITextField!
    @IBOutlet weak var buttonResetPassword: UIButton!
    
    @IBOutlet weak var indicatorResetPassword: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //
        // Make sure we are getting 'auto layout' specific sizes
        // otherwise any math we do will be messed up
        //
        self.view.setNeedsLayout()
        self.view.layoutIfNeeded()
        
        //
        // Set all table row separators to appear transparent
        //
        self.tableView.separatorColor = UIColor(white: 1.0, alpha: 0.0)
        
        //
        //
        //
        let cancelButton = UIBarButtonItem(title: "Cancel", style: UIBarButtonItemStyle.Plain, target: self, action:#selector(goBack))
        navigationItem.leftBarButtonItem = cancelButton

        //
        // Alter the appearence of the Log In button
        //
        buttonResetPassword.layer.borderWidth = 1.0
        buttonResetPassword.layer.borderColor = CGColor.colorBrand()
        buttonResetPassword.layer.cornerRadius = 4.0
        
        //
        // Set all table row separators to appear transparent
        //
        self.tableView.separatorColor = UIColor(white: 1.0, alpha: 0.0)
        
        //
        // Alter the appearence of the Log In button
        //
        self.buttonResetPassword.layer.borderWidth = 1.0
        self.buttonResetPassword.setTitleColor(UIColor.colorBrand(0.35), forState: .Normal)
        self.buttonResetPassword.setTitleColor(UIColor.colorBrand(), forState: .Highlighted)
        self.buttonResetPassword.layer.borderColor = CGColor.colorBrand(0.35)
        self.buttonResetPassword.layer.cornerRadius = 4.0
        
        buttonResetPassword.addTarget(self, action: #selector(buttonClickLogin(_:)), forControlEvents: .TouchUpInside)
        
        //
        // Watch the Email Address and Password field's for changes.
        // We will be enabling and disabling the "Login Button" based
        // on whether or not the fields contain content.
        //
        textfieldEmailAddress.addTarget(self, action: #selector(LoginTableViewController.textFieldDidChange(_:)), forControlEvents: UIControlEvents.EditingChanged)

        //
        //
        //
        if let _email_address = NSUserDefaults.standardUserDefaults().objectForKey("currentUserAccountEmailAddress") {
            self.textfieldEmailAddress.text = _email_address as! String
            self.isReady()
            self.enableLoginButton()
        }
        else {
            //
            // Hide the "Log in attempt" indicator by default, we do not
            // need this indicator until a user interacts with the login
            // button
            //
            self.isReady()
        }
    }
    
    
    //
    // Basic Login Button Feedback States
    //
    func isReady() {
        buttonResetPassword.hidden = false
        buttonResetPassword.enabled = false
        indicatorResetPassword.hidden = true
    }
    
    func isLoading() {
        buttonResetPassword.hidden = true
        indicatorResetPassword.hidden = false
        indicatorResetPassword.startAnimating()
    }
    
    func isFinishedLoadingWithError() {
        buttonResetPassword.hidden = false
        indicatorResetPassword.hidden = true
        indicatorResetPassword.stopAnimating()
    }
    
    func enableLoginButton() {
        buttonResetPassword.enabled = true
        buttonResetPassword.setTitleColor(UIColor.colorBrand(), forState: .Normal)
    }
    
    func disableLoginButton() {
        buttonResetPassword.enabled = false
        buttonResetPassword.setTitleColor(UIColor.colorBrand(0.35), forState: .Normal)
    }
    
    func displayErrorMessage(title: String, message: String) {
        
        let alertController = UIAlertController(title: title, message:message, preferredStyle: UIAlertControllerStyle.Alert)
        
        alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default, handler: nil))
        
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    
    //
    //
    //
    func textFieldDidChange(textField: UITextField) {
        
        //
        // - IF a textfield is not an empty string, enable the login button
        // - ELSE disable the button so that a user cannot tap it to submit an invalid request
        //
        if (self.textfieldEmailAddress.text == "") {
            self.disableLoginButton()
        } else {
            self.enableLoginButton()
        }
        
    }
    
    
    //
    //
    //
    func buttonClickLogin(sender:UIButton) {
        
        //
        // Hide the log in button so that the user cannot tap
        // it more than once. If they did tap it more than once
        // this would cause multiple requests to be sent to the
        // server and then multiple responses back to the app
        // which could cause the wrong `access_token` to be saved
        // to the user's Locksmith keychain.
        //
        self.isLoading()
        
        //
        // Send the email address and password along to the Authentication endpoint
        // for verification and processing
        //
        self.attemptPasswordReset(self.textfieldEmailAddress.text!)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        
        NSLog("LoginViewController::didReceiveMemoryWarning")
    }
    
    
    //
    // MARK: - Custom methods and functions
    //
    func goBack(){
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    func attemptPasswordReset(email: String) {
        
        //
        // Send a request to the defined endpoint with the given parameters
        //
        let parameters = [
            "email": email
        ]
        
        Alamofire.request(.POST, Endpoints.POST_PASSWORD_RESET, parameters: parameters, encoding: .JSON)
            .responseJSON { response in
                
                switch response.result {
                case .Success(let value):
                    
                    print(value)
                    
                    if let responseCode = value["code"] {
                        
                        if responseCode != nil {
                            print("!= nil")
                            self.isFinishedLoadingWithError()
                            self.displayErrorMessage("An Error Occurred", message:"Please check the email address you entered and try again.")
                        }
                        else {
                            print("nil")
//                            self.displayErrorMessage("We sent you an email", message:"We have sent an email to " + self.textfieldEmailAddress.text! + " with further instructions to help you reset your password.")
//                            self.dismissViewControllerAnimated(true, completion: nil)
                            
                            let alertController = UIAlertController(title: "We sent you an email", message:"We‘ve sent an email to " + self.textfieldEmailAddress.text! + " with further instructions to help you reset your password.", preferredStyle: UIAlertControllerStyle.Alert)
                            
                            alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default) {
                                    UIAlertAction in
                                    self.dismissViewControllerAnimated(true, completion: {
                                        self.dismissViewControllerAnimated(true, completion: nil)
                                    })
                                })
                            
                            self.presentViewController(alertController, animated: true, completion: nil)
                            
                            self.isReady()
                        }
                    }
                    
                case .Failure(let error):
                    print(error)
                    self.isFinishedLoadingWithError()
                    self.displayErrorMessage("An Error Occurred", message:"Please check the email address and password you entered and try again.")
                    break
                }
                
        }
    }
    
}
