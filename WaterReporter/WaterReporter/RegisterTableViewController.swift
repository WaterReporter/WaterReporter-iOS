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
    
    @IBOutlet weak var navigationButtonLogin: UIButton!
    @IBOutlet weak var navigationButtonSignUp: UIButton!
    
    @IBOutlet weak var textfieldEmailAddress: UITextField!
    @IBOutlet weak var textfieldPassword: UITextField!
    @IBOutlet weak var textfieldPasswordAgain: UITextField!

    @IBOutlet weak var buttonSignUp: UIButton!
    
    @IBOutlet weak var indicatorSignUp: UIActivityIndicatorView!
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        
        if let _account = NSUserDefaults.standardUserDefaults().objectForKey("currentUserAccountAccessToken") {
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
    
    
    //
    // Basic Login Button Feedback States
    //
    func isReady() {
        buttonSignUp.hidden = false
        buttonSignUp.enabled = false
        indicatorSignUp.hidden = true
    }
    
    func isLoading() {
        buttonSignUp.hidden = true
        indicatorSignUp.hidden = false
        indicatorSignUp.startAnimating()
    }
    
    func isFinishedLoadingWithError() {
        buttonSignUp.hidden = false
        indicatorSignUp.hidden = true
        indicatorSignUp.stopAnimating()
    }
    
    func enableLoginButton() {
        buttonSignUp.enabled = true
        buttonSignUp.setTitleColor(UIColor.colorBrand(), forState: .Normal)
    }
    
    func disableLoginButton() {
        buttonSignUp.enabled = false
        buttonSignUp.setTitleColor(UIColor.colorBrand(0.35), forState: .Normal)
    }
    
    func displayErrorMessage(title: String, message: String) {
        
        let alertController = UIAlertController(title: title, message:message, preferredStyle: UIAlertControllerStyle.Alert)
        
        alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default,handler: nil))
        
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
        if (self.textfieldEmailAddress.text == "" || self.textfieldPassword.text == "" || self.textfieldPasswordAgain.text == "") {
            self.disableLoginButton()
        } else {
            let passwordCheck = self.passwordsAreMatching(self.textfieldPassword.text!, passwordAgain:self.textfieldPasswordAgain.text!)
            
            if (passwordCheck) {
                print("passwords match")
                self.enableLoginButton()
            }
            else {
                print("passwords are not matching, show some feedback")
            }
        }
        
    }
    
    
    //
    //
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
                        print("attemptRegistration::IF: responseCode")
                        print(responseCode)
                        
                        self.responseRegistration(responseCode as! NSNumber, meta: value)
                    }
                    else if let responseCode = value.objectForKey("code") {
                        print("attemptRegistration::ELSE: responseCode")
                        self.responseRegistration(responseCode as! NSNumber, meta: value)
                    }
                    break
                case .Failure(let error):
                    print("Error")
                    print(error)
                    self.isFinishedLoadingWithError()
                    self.displayErrorMessage("An Error Occurred", message:"Please check the email address and password you entered and try again.")
                    break
                }
                
        }
    }
    
    func responseRegistration(responseCode: NSNumber, meta: AnyObject?) {
        
        switch responseCode {
            case 200:
                print("Code: 200")
                self.attemptAuthentication(self.textfieldEmailAddress.text!, password: self.textfieldPassword.text!)
                break
            case 400:
                print("400 meta feedback")
                print(meta)
                
                var _message = "Please check the email address and password you entered and try again."
                
                if (meta!.objectForKey("response")!.objectForKey("errors")!.objectForKey("email") != nil) {
                    _message = self.textfieldEmailAddress.text! + " is already associated with an account."
                }
                
                self.isFinishedLoadingWithError()
                self.displayErrorMessage("Something went wrong", message: _message)
                break
            default:
                print("unknown status code")
                print(responseCode)
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
                    
                    print("value after successful POST_AUTH_REMOTE")
                    print(value)
                    
                    if let responseCode = value.objectForKey("meta")?.objectForKey("code") {
                        print("attemptAuthentication::IF: responseCode")
                        self.responseAuthentication(responseCode as! NSNumber, value: value)
                    }
                    else if let responseCode = value.objectForKey("code") {
                        print("attemptAuthentication::ELSE: responseCode")
                        self.responseAuthentication(responseCode as! NSNumber, value: value)
                    }
                    else if let accessToken = value.objectForKey("access_token") {
                        print("no response codes ....")
                        let responseCode: NSNumber = 200
                        self.responseAuthentication(responseCode, value: value)
                    }
                case .Failure(let _):
                    self.isFinishedLoadingWithError()
                    self.displayErrorMessage("An Error Occurred", message:"Please check the email address and password you entered and try again.")
                    break
                }
                
        }
    }
    
    func responseAuthentication(responseCode: NSNumber, value: AnyObject) {
        
        switch responseCode {
            case 200:
                print("responseAuthentication after registration >> 200")

                var attemptToDismissLoginTableViewController: Bool = true;
                
                NSUserDefaults.standardUserDefaults().setValue(value["access_token"], forKeyPath: "currentUserAccountAccessToken")
                NSUserDefaults.standardUserDefaults().setValue(self.textfieldEmailAddress.text, forKeyPath: "currentUserAccountEmailAddress")
                
                //
                //
                //
                self.textfieldPassword.text = ""
                self.isReady()
                
                self.dismissViewControllerAnimated(true, completion: {
                    attemptToDismissLoginTableViewController = false
                    self.performSegueWithIdentifier("showActivityTableViewControllerFromRegistrationViewController", sender: self)
                })
                
                if (attemptToDismissLoginTableViewController) {
                    self.performSegueWithIdentifier("showActivityTableViewControllerFromRegistrationViewController", sender: self)
                }
                
                break
            case 400:
                self.isFinishedLoadingWithError()
                self.displayErrorMessage("An Error Occurred", message:"Please check the email address and password you entered and try again.")
                break
            default:
                print("unknown status code")
                print(responseCode)
                break
        }
    }

    
    func passwordsAreMatching(password: String, passwordAgain: String) -> Bool {
        
        let passwordsAreMatching = (password == passwordAgain)
        
        if (passwordsAreMatching) {
            return true;
        }
        
        return false;
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