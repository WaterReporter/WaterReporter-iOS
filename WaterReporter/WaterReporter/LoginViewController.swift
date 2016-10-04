//
//  LoginViewController.swift
//  Water-Reporter
//
//  Created by Viable Industries on 9/22/16.
//  Copyright © 2016 Viable Industries, L.L.C. All rights reserved.
//

import Alamofire
import Foundation
import UIKit

class LoginViewController: UIViewController {

    @IBOutlet weak var navigationLoginButton: UIButton!
    @IBOutlet weak var navigationSignupButton: UIButton!
    @IBOutlet weak var navigationForgotPasswordButton: UIButton!

    @IBOutlet weak var loginEmailAddress: UITextField!
    @IBOutlet weak var loginPassword: UITextField!
    @IBOutlet weak var loginSubmitButton: UIButton!
    @IBOutlet weak var loginSubmitButtonFrame: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NSLog("LoginViewController::viewDidLoad")
        
        //
        // Set the Navigation Bar title
        //
        self.navigationItem.title = "Profile"
        
        //
        // Restyle the form Log In button
        //
        self.loginSubmitButtonFrame.layer.borderWidth = 1.0
        self.loginSubmitButtonFrame.layer.borderColor = UIColor(red:0.10, green:0.67, blue:0.87, alpha: 1.00).CGColor
        self.loginSubmitButtonFrame.layer.cornerRadius = 5.0
        
        navigationSignupButton.addTarget(self, action: #selector(buttonClickSignUp(_:)), forControlEvents: .TouchUpInside)
        navigationForgotPasswordButton.addTarget(self, action: #selector(buttonClickSignUp(_:)), forControlEvents: .TouchUpInside)

    }
    
    func buttonClickSignUp(sender:UIButton) {
        //
        // Load the activity controller from the storyboard
        //
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        
        let nextViewController = storyBoard.instantiateViewControllerWithIdentifier("RegisterViewController") as! RegisterViewController
        
        self.presentViewController(nextViewController, animated: false, completion: nil)
    }

    func buttonClickForgotPassword(sender:UIButton) {
        //
        // Load the activity controller from the storyboard
        //
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        
        let nextViewController = storyBoard.instantiateViewControllerWithIdentifier("RegisterViewController") as! RegisterViewController
        
        self.presentViewController(nextViewController, animated: false, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.

        NSLog("LoginViewController::didReceiveMemoryWarning")
    }
    
}