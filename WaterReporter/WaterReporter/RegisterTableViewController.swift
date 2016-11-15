//
//  RegisterTableViewController.swift
//  Water-Reporter
//
//  Created by Viable Industries on 9/22/16.
//  Copyright © 2016 Viable Industries, L.L.C. All rights reserved.
//

import Alamofire
import Foundation
import UIKit

class RegisterTableViewController: UITableViewController {
    
    
    //
    // MARK: @IBOutlets
    //
    @IBOutlet weak var navigationButtonLogin: UIButton!
    @IBOutlet weak var navigationButtonSignUp: UIButton!
    
    @IBOutlet weak var textfieldEmailAddress: UITextField!
    @IBOutlet weak var textfieldPassword: UITextField!
    @IBOutlet weak var textfieldPasswordAgain: UITextField!

    @IBOutlet weak var buttonSignUp: UIButton!
    @IBOutlet weak var buttonTerms: UIButton!
    
    @IBOutlet weak var indicatorSignUp: UIActivityIndicatorView!
    
    
    //
    // MARK: Variables
    //
    let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
    
    
    //
    // MARK: Overrides
    //
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        
        if NSUserDefaults.standardUserDefaults().objectForKey("currentUserAccountAccessToken") != nil {
            self.dismissViewControllerAnimated(false, completion: nil);
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //
        // Make sure we are getting 'auto layout' specific sizes
        // otherwise any math we do will be messed up
        //
        self.view.setNeedsLayout()
        self.view.layoutIfNeeded()
        
        //
        // Restyle the form Log In Navigation button to appear with an underline
        //
        let border = CALayer()
        let buttonWidth = self.navigationButtonSignUp.frame.width
        let borderWidth = buttonWidth/2
        
        border.borderColor = CGColor.colorBrand()
        border.borderWidth = 3.0
        border.frame = CGRectMake(borderWidth/2, self.navigationButtonSignUp.frame.size.height - 3.0, borderWidth, self.navigationButtonSignUp.frame.size.height)
        
        self.navigationButtonSignUp.layer.addSublayer(border)
        self.navigationButtonSignUp.layer.masksToBounds = true
        
        // Setup Navigation button
        self.navigationButtonLogin.addTarget(self, action: #selector(RegisterTableViewController.presentLoginViewController(_:)), forControlEvents: .TouchUpInside)
        
        self.buttonTerms.addTarget(self, action: #selector(RegisterTableViewController.openTermsURL(_:)), forControlEvents: .TouchUpInside)
        
        //
        // Set all table row separators to appear transparent
        //
        self.tableView.separatorColor = UIColor(white: 1.0, alpha: 0.0)
        
        //
        // Alter the appearence of the Log In button
        //
        self.buttonSignUp.layer.borderWidth = 1.0
        self.buttonSignUp.setTitleColor(UIColor.colorBrand(0.35), forState: .Normal)
        self.buttonSignUp.setTitleColor(UIColor.colorBrand(), forState: .Highlighted)
        self.buttonSignUp.layer.borderColor = CGColor.colorBrand(0.35)
        self.buttonSignUp.layer.cornerRadius = 4.0
        
        buttonSignUp.addTarget(self, action: #selector(buttonClickSignUp(_:)), forControlEvents: .TouchUpInside)

        //
        // Watch the Email Address and Password field's for changes.
        // We will be enabling and disabling the "Login Button" based
        // on whether or not the fields contain content.
        //
        textfieldEmailAddress.addTarget(self, action: #selector(RegisterTableViewController.textFieldDidChange(_:)), forControlEvents: UIControlEvents.EditingChanged)
        textfieldPassword.addTarget(self, action: #selector(RegisterTableViewController.textFieldDidChange(_:)), forControlEvents: UIControlEvents.EditingChanged)
        textfieldPasswordAgain.addTarget(self, action: #selector(RegisterTableViewController.textFieldDidChange(_:)), forControlEvents: UIControlEvents.EditingChanged)
        
        //
        // Hide the "Log in attempt" indicator by default, we do not
        // need this indicator until a user interacts with the login
        // button
        //
        self.isReady()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    //
    // MARK: Custom Methods
    //

    // Set State: Ready
    func isReady() {
        buttonSignUp.hidden = false
        buttonSignUp.enabled = false
        indicatorSignUp.hidden = true
    }
    
    // Set State: Loading
    func isLoading() {
        buttonSignUp.hidden = true
        indicatorSignUp.hidden = false
        indicatorSignUp.startAnimating()
    }
    
    // Set State: Loading with Error
    func isFinishedLoadingWithError() {
        buttonSignUp.hidden = false
        indicatorSignUp.hidden = true
        indicatorSignUp.stopAnimating()
    }
    
    // Enable Login button
    func enableLoginButton() {
        buttonSignUp.enabled = true
        buttonSignUp.setTitleColor(UIColor.colorBrand(), forState: .Normal)
    }
    
    // Disable Login button
    func disableLoginButton() {
        buttonSignUp.enabled = false
        buttonSignUp.setTitleColor(UIColor.colorBrand(0.35), forState: .Normal)
    }
    
    // Display error message as alert
    func displayErrorMessage(title: String, message: String) {
        
        let alertController = UIAlertController(title: title, message:message, preferredStyle: UIAlertControllerStyle.Alert)
        
        alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default,handler: nil))
        
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    // Present LoginTableViewController
    func presentLoginViewController(sender: UITabBarItem) {
        let nextViewController = self.storyBoard.instantiateViewControllerWithIdentifier("LoginTableViewController") as! LoginTableViewController
        
        self.presentViewController(nextViewController, animated: false, completion: nil)
    }

    // Present UserProfileCreateTableViewController
    func presentUserProfileCreateTableViewController() {
        
        let nextViewController = self.storyBoard.instantiateViewControllerWithIdentifier("UserProfileCreateTableViewController") as! UserProfileCreateTableViewController
        
        let navigationViewController = UINavigationController(rootViewController: nextViewController)
    
        self.presentViewController(navigationViewController, animated:true, completion: nil)
    }
    
    // Open the URL to the Terms and Conditions in a Safari window
    func openTermsURL(sender: UIButton) {
        
        let termsUrl: NSURL! = NSURL(string: "https://www.waterreporter.org/terms")
        
        UIApplication.sharedApplication().openURL(termsUrl)
    }
    
    // Validate whether passwords match or not
    func passwordsAreMatching(password: String, passwordAgain: String) -> Bool {
        
        let passwordsAreMatching = (password == passwordAgain)
        
        if (passwordsAreMatching) {
            return true;
        }
        
        return false;
    }
    
    // Detect Textfield Changes
    func textFieldDidChange(textField: UITextField) {
        
        //
        // - IF a textfield is not an empty string, enable the login button
        // - ELSE disable the button so that a user cannot tap it to submit an invalid request
        //
        if (self.textfieldEmailAddress.text == "" || self.textfieldPassword.text == "" || self.textfieldPasswordAgain.text == "") {
            self.disableLoginButton()
        } else {
            let passwordCheck = self.passwordsAreMatching(self.textfieldPassword.text!, passwordAgain:self.textfieldPasswordAgain.text!)
            
            if (passwordCheck) {
                self.enableLoginButton()
            }
        }
        
    }
    
    // Handle Textfield navigation with the Next and Done buttons
    // on the keyboard
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
    
    
    //
    // MARK: Form Functionality
    //
    func buttonClickSignUp(sender:UIButton) {
        
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
        self.attemptRegistration(self.textfieldEmailAddress.text!, password: self.textfieldPassword.text!)
    }
    
    func attemptRegistration(email: String, password: String) {
        
        //
        // Send a request to the defined endpoint with the given parameters
        //
        let parameters = [
            "email": email,
            "password": password,
            ]
        
        Alamofire.request(.POST, Endpoints.POST_USER_REGISTER, parameters: parameters, encoding: .JSON)
            .responseJSON { response in
                
                switch response.result {
                case .Success(let value):
                    
                    if let responseCode = value.objectForKey("meta")!.objectForKey("code") {
                        self.responseRegistration(responseCode as! NSNumber, meta: value)
                    }
                    else if let responseCode = value.objectForKey("code") {
                        self.responseRegistration(responseCode as! NSNumber, meta: value)
                    }
                    
                    break
                case .Failure(let error):
                    
                    print("An Error Occurred: \(error)")
                    
                    self.isFinishedLoadingWithError()
                    self.displayErrorMessage("An Error Occurred", message:"Please check the email address and password you entered and try again.")
                    break
                }
                
        }
    }
    
    func responseRegistration(responseCode: NSNumber, meta: AnyObject?) {
        
        switch responseCode {
        case 200:
            self.attemptAuthentication(self.textfieldEmailAddress.text!, password: self.textfieldPassword.text!)
            break
        case 400:
            
            // Set a default message just in case the system doesn't give us anything to work with
            var _message = "Please check the email address and password you entered and try again."
            
            // Attempt to use the system supplied email or password message
            if (meta!.objectForKey("response")!.objectForKey("errors")!.objectForKey("email") != nil) {
                let rawEmailMessageList: AnyObject = meta!.objectForKey("response")!.objectForKey("errors")!.objectForKey("email")!
                let emailMessageList = (rawEmailMessageList as! NSArray) as Array
                _message = String(emailMessageList[0])
            }
            else if (meta!.objectForKey("response")!.objectForKey("errors")!.objectForKey("password") != nil) {
                let rawPasswordMessageList: AnyObject = meta!.objectForKey("response")!.objectForKey("errors")!.objectForKey("password")!
                let passwordMessageList = (rawPasswordMessageList as! NSArray) as Array
                _message = String(passwordMessageList[0])
            }
            
            // return the message to the user's device
            self.isFinishedLoadingWithError()
            self.displayErrorMessage("Something went wrong", message: _message)
            break
        default:
            break
        }
        
    }
    
    func attemptAuthentication(email: String, password: String) {
        
        //
        // Send a request to the defined endpoint with the given parameters
        //
        let parameters = [
            "email": email,
            "password": password,
            "response_type": Environment.RESPONSE_TYPE,
            "client_id": Environment.CLIENT_ID,
            "redirect_uri": Environment.REDIRECT_URI,
            "scope": Environment.SCOPE,
            "state": Environment.STATE
        ]
        
        Alamofire.request(.POST, Endpoints.POST_AUTH_REMOTE, parameters: parameters, encoding: .JSON)
            .responseJSON { response in
                
                switch response.result {
                case .Success(let value):
                    
                    print("Response Failure \(value)")

                    if let responseCode = value.objectForKey("meta")?.objectForKey("code") {
                        self.responseAuthentication(responseCode as! NSNumber, value: value)
                    }
                    else if let responseCode = value.objectForKey("code") {
                        self.responseAuthentication(responseCode as! NSNumber, value: value)
                    }
                    else if value.objectForKey("access_token") != nil {
                        let responseCode: NSNumber = 200
                        self.responseAuthentication(responseCode, value: value)
                    }
                case .Failure(let error):
                    
                    print("Response Failure \(error)")
                    
                    self.isFinishedLoadingWithError()
                    self.displayErrorMessage("An Error Occurred", message:"Please check the email address and password you entered and try again.")
                    break
                }
                
        }
    }
    
    func responseAuthentication(responseCode: NSNumber, value: AnyObject) {
        
        switch responseCode {
        case 200:
            NSUserDefaults.standardUserDefaults().setValue(value["access_token"], forKeyPath: "currentUserAccountAccessToken")
            NSUserDefaults.standardUserDefaults().setValue(self.textfieldEmailAddress.text, forKeyPath: "currentUserAccountEmailAddress")
            
            self.presentUserProfileCreateTableViewController()
            
            break
        case 400:
            self.isFinishedLoadingWithError()
            self.displayErrorMessage("An Error Occurred", message:"Please check the email address and password you entered and try again.")
            break
        default:
            break
        }
    }
    

}
