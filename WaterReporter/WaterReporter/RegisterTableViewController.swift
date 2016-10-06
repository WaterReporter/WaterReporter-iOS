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
        let borderColor = UIColor(red:0.10, green:0.67, blue:0.87, alpha: 1.00).CGColor
        
        border.borderColor = borderColor
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
        self.buttonSignUp.layer.borderColor = borderColor
        self.buttonSignUp.layer.cornerRadius = 4.0
        
        buttonSignUp.addTarget(self, action: #selector(buttonClickLogin(_:)), forControlEvents: .TouchUpInside)
    }
    
    func buttonClickLogin(sender:UIButton) {
        print("buttonClickLogin")
        
        let emailAddress = self.textfieldEmailAddress
        let password = self.textfieldPassword
        let passwordAgain = self.textfieldPasswordAgain
        
        print("emailAddress")
        print(emailAddress)
        
        print("password")
        print(password)

        print("password again")
        print(password)

        
        //
        // 1. Get Email Address Field
        // 2. Get Password Field
        // 3. Send request with that information to api.
        // 4. Handle response
        // 4a. Dismiss and go to activity
        // 4b. Show error message
        //
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        
        NSLog("LoginViewController::didReceiveMemoryWarning")
    }

    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! UITableViewCell
        
        return cell
    }
    
    /*
     // Override to support conditional editing of the table view.
     override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
     // Return false if you do not want the specified item to be editable.
     return true
     }
     */
    
    /*
     // Override to support editing the table view.
     override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
     if editingStyle == .Delete {
     // Delete the row from the data source
     tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
     } else if editingStyle == .Insert {
     // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
     }
     }
     */
    
    /*
     // Override to support rearranging the table view.
     override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {
     
     }
     */
    
    /*
     // Override to support conditional rearranging of the table view.
     override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
     // Return false if you do not want the item to be re-orderable.
     return true
     }
     */
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */

}