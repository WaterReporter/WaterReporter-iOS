//
//  UserProfileEditTableViewController.swift
//  Water-Reporter
//
//  Created by Viable Industries on 9/22/16.
//  Copyright © 2016 Viable Industries, L.L.C. All rights reserved.
//

import Foundation
import UIKit

class UserProfileEditTableViewController: UITableViewController {
    
    @IBOutlet weak var buttonUserLogOut: UIButton!
    
    @IBOutlet weak var navigationButtonBarItemCancel: UIBarButtonItem!
    @IBOutlet weak var navigationButtonBarItemSave: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //
        // Make sure we are getting 'auto layout' specific sizes
        // otherwise any math we do will be messed up
        //
        self.view.setNeedsLayout()
        self.view.layoutIfNeeded()
        
        buttonUserLogOut.layer.borderColor = CGColor.colorBrand()
        
        navigationButtonBarItemSave.target = self
        navigationButtonBarItemSave.action = #selector(buttonSaveUserProfileEditTableViewController(_:))

        navigationButtonBarItemCancel.target = self
        navigationButtonBarItemCancel.action = #selector(buttonDismissUserProfileEditTableViewController(_:))
        
        buttonUserLogOut.addTarget(self, action:#selector(attemptUserLogOut(_:)), forControlEvents: .TouchUpInside)
        
    }
    
    func attemptUserLogOut(sender:UIButton) {
        NSUserDefaults.standardUserDefaults().removeObjectForKey("currentUserAccountAccessToken")
        
        self.dismissViewControllerAnimated(true, completion: {
            let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
            let nextViewController = storyBoard.instantiateViewControllerWithIdentifier("LoginTableViewController") as! LoginTableViewController
            self.presentViewController(nextViewController, animated: false, completion: nil)
        })
    }
    
    func buttonDismissUserProfileEditTableViewController(sender:UIBarButtonItem) {
        print("dismiss")
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    func buttonSaveUserProfileEditTableViewController(sender:UIBarButtonItem) {
        print("save")
        self.dismissViewControllerAnimated(true, completion: nil)
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