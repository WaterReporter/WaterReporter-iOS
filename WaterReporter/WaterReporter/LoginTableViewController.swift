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
        let buttonWidth = self.navigationButtonLogin.frame.width
        let borderWidth = buttonWidth/2
        let borderColor = UIColor(red:0.10, green:0.67, blue:0.87, alpha: 1.00).CGColor
        
        border.borderColor = borderColor
        border.borderWidth = 3.0
        border.frame = CGRectMake(borderWidth/2, self.navigationButtonLogin.frame.size.height - 3.0, borderWidth, self.navigationButtonLogin.frame.size.height)
        
        self.navigationButtonLogin.layer.addSublayer(border)
        self.navigationButtonLogin.layer.masksToBounds = true
        
        //
        // Set all table row separators to appear transparent
        //
        self.tableView.separatorColor = UIColor(white: 1.0, alpha: 0.0)
        
        //
        // Alter the appearence of the Log In button
        //
        self.buttonLogin.layer.borderWidth = 1.0
        self.buttonLogin.layer.borderColor = borderColor
        self.buttonLogin.layer.cornerRadius = 4.0
        
        buttonLogin.addTarget(self, action: #selector(buttonClickLogin(_:)), forControlEvents: .TouchUpInside)
        
        
        //        navigationSignupButton.addTarget(self, action: #selector(buttonClickSignUp(_:)), forControlEvents: .TouchUpInside)
        //        navigationForgotPasswordButton.addTarget(self, action: #selector(buttonClickSignUp(_:)), forControlEvents: .TouchUpInside)
        
    }
    
    func buttonClickLogin(sender:UIButton) {
        print("buttonClickLogin")
        
        //
        // 1. Get Email Address Field
        // 2. Get Password Field
        // 3. Send request with that information to api.
        // 4. Handle response
        // 4a. Dismiss and go to activity
        // 4b. Show error message
        //
    }
    
    //    func buttonClickSignUp(sender:UIButton) {
    //        //
    //        // Load the activity controller from the storyboard
    //        //
    //        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
    //
    //        let nextViewController = storyBoard.instantiateViewControllerWithIdentifier("RegisterViewController") as! RegisterViewController
    //
    //        self.presentViewController(nextViewController, animated: false, completion: nil)
    //    }
    //
    //    func buttonClickForgotPassword(sender:UIButton) {
    //        //
    //        // Load the activity controller from the storyboard
    //        //
    //        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
    //
    //        let nextViewController = storyBoard.instantiateViewControllerWithIdentifier("RegisterViewController") as! RegisterViewController
    //
    //        self.presentViewController(nextViewController, animated: false, completion: nil)
    //    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        
        NSLog("LoginViewController::didReceiveMemoryWarning")
    }
    
}