//
//  LoginTableViewController.swift
//  Water-Reporter
//
//  Created by Viable Industries on 9/22/16.
//  Copyright © 2016 Viable Industries, L.L.C. All rights reserved.
//

import Alamofire
import Foundation
import UIKit

class LoginTableViewController: UITableViewController {
    
    @IBOutlet weak var navigationButtonLogin: UIButton!
    @IBOutlet weak var navigationButtonSignUp: UIButton!
    
    @IBOutlet weak var textfieldEmailAddress: UITextField!
    @IBOutlet weak var textfieldPassword: UITextField!
    @IBOutlet weak var buttonForgotYourPassword: UIButton!
    @IBOutlet weak var buttonLogin: UIButton!
    
    @IBOutlet weak var indicatorLogin: UIActivityIndicatorView!
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
    
        if NSUserDefaults.standardUserDefaults().objectForKey("currentUserAccountAccessToken") != nil {
            self.dismissViewControllerAnimated(false, completion: nil);
        }
    
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //
        // Make doubly sure that there is no `currentUserAccountAccessToken`
        //
        NSUserDefaults.standardUserDefaults().removeObjectForKey("currentUserAccountAccessToken")

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
        let buttonWidth = self.navigationButtonLogin.frame.width
        let borderWidth = buttonWidth/2
        
        border.borderColor = CGColor.colorBrand()
        border.borderWidth = 3.0
        border.frame = CGRectMake(borderWidth/2, self.navigationButtonLogin.frame.size.height - 3.0, borderWidth, self.navigationButtonLogin.frame.size.height)
        
        self.navigationButtonLogin.layer.addSublayer(border)
        self.navigationButtonLogin.layer.masksToBounds = true
        
        self.navigationButtonSignUp.addTarget(self, action: #selector(LoginTableViewController.showRegisterViewController(_:)), forControlEvents: .TouchUpInside)
        
        //
        //
        //
        if let _email_address = NSUserDefaults.standardUserDefaults().objectForKey("currentUserAccountEmailAddress") {
            self.textfieldEmailAddress.text = _email_address as? String
        }
        
        //
        // Set all table row separators to appear transparent
        //
        self.tableView.separatorColor = UIColor(white: 1.0, alpha: 0.0)
        
        //
        // Alter the appearence of the Log In button
        //
        self.buttonLogin.layer.borderWidth = 1.0
        self.buttonLogin.setTitleColor(UIColor.colorBrand(0.35), forState: .Normal)
        self.buttonLogin.setTitleColor(UIColor.colorBrand(), forState: .Highlighted)
        self.buttonLogin.layer.borderColor = CGColor.colorBrand(0.35)
        self.buttonLogin.layer.cornerRadius = 4.0
        
        buttonLogin.addTarget(self, action: #selector(buttonClickLogin(_:)), forControlEvents: .TouchUpInside)
        
        //
        // Watch the Email Address and Password field's for changes.
        // We will be enabling and disabling the "Login Button" based
        // on whether or not the fields contain content.
        //
        textfieldEmailAddress.addTarget(self, action: #selector(LoginTableViewController.textFieldDidChange(_:)), forControlEvents: UIControlEvents.EditingChanged)
        textfieldPassword.addTarget(self, action: #selector(LoginTableViewController.textFieldDidChange(_:)), forControlEvents: UIControlEvents.EditingChanged)
        
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
        buttonLogin.hidden = false
        buttonLogin.enabled = false
        indicatorLogin.hidden = true
    }

    func isLoading() {
        buttonLogin.hidden = true
        indicatorLogin.hidden = false
        indicatorLogin.startAnimating()
    }
    
    func isFinishedLoadingWithError() {
        buttonLogin.hidden = false
        indicatorLogin.hidden = true
        indicatorLogin.stopAnimating()
    }
    
    func enableLoginButton() {
        buttonLogin.enabled = true
        self.buttonLogin.setTitleColor(UIColor.colorBrand(), forState: .Normal)
    }
    
    func disableLoginButton() {
        buttonLogin.enabled = false
        self.buttonLogin.setTitleColor(UIColor.colorBrand(0.35), forState: .Normal)
    }
    
    func showRegisterViewController(sender: UITabBarItem) {
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)

        let nextViewController = storyBoard.instantiateViewControllerWithIdentifier("RegisterTableViewController") as! RegisterTableViewController

        self.presentViewController(nextViewController, animated: false, completion: {
            print("showRegisterViewController > LoginTableViewController > presentViewController")
            
        })
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
        if (self.textfieldEmailAddress.text == "" || self.textfieldPassword.text == "") {
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
        self.attemptAuthentication(self.textfieldEmailAddress.text!, password: self.textfieldPassword.text!)
        
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
                        
                        print(value)

                        if let responseCode = value["code"] {
                            
                            if responseCode != nil {
                                print("!= nil")
                                self.isFinishedLoadingWithError()
                                self.displayErrorMessage("An Error Occurred", message:"Please check the email address and password you entered and try again.")
                            }
                            else {
                                print("nil")
                                print(value)
                                
                                // var attemptToDismissLoginTableViewController: Bool = true;
                                
                                NSUserDefaults.standardUserDefaults().setValue(value["access_token"], forKeyPath: "currentUserAccountAccessToken")
                                NSUserDefaults.standardUserDefaults().setValue(self.textfieldEmailAddress.text, forKeyPath: "currentUserAccountEmailAddress")
                                
                                //
                                //
                                //
                                self.textfieldPassword.text = ""
                                self.isReady()

                                //
                                //
                                //
                                let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
                                
                                let nextViewController = storyBoard.instantiateViewControllerWithIdentifier("PrimaryTabBarController") as! UITabBarController
                                
                                self.presentViewController(nextViewController, animated: false, completion: {
                                    print("PrimaryTabBarController > presentViewController")

                                })
                                
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
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {

        let nextTag = textField.tag + 1;
        let nextResponder=textField.superview?.superview?.superview?.viewWithTag(nextTag) as UIResponder!
        
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
