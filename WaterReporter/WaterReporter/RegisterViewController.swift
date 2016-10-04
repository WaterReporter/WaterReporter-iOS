//
//  RegisterViewController.swift
//  Water-Reporter
//
//  Created by Viable Industries on 9/22/16.
//  Copyright © 2016 Viable Industries, L.L.C. All rights reserved.
//

import Foundation
//
//  RegisterViewController.swift
//  Water-Reporter
//
//  Created by Viable Industries on 9/22/16.
//  Copyright © 2016 Viable Industries, L.L.C. All rights reserved.
//

import Alamofire
import Foundation
import UIKit

class RegisterViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NSLog("LoginViewController::viewDidLoad")
        
        //
        // Set the Navigation Bar title
        //
        self.navigationItem.title = "Profile"
        
//        self.loginSubmitButtonFrame.layer.borderWidth = 1.0
//        self.loginSubmitButtonFrame.layer.borderColor = UIColor(red:0.10, green:0.67, blue:0.87, alpha: 1.00).CGColor
//        self.loginSubmitButtonFrame.layer.cornerRadius = 5.0
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        
        NSLog("LoginViewController::didReceiveMemoryWarning")
    }
    
}