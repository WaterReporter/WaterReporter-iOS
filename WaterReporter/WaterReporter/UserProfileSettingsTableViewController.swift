//
//  UserProfileSettingsTableViewController.swift
//  Water-Reporter
//
//  Created by Viable Industries on 10/13/16.
//  Copyright © 2016 Viable Industries, L.L.C. All rights reserved.
//

import Foundation
import UIKit

class UserProfileSettingsTableViewController: UITableViewController {
    
    @IBOutlet weak var buttonEditProfile: UIButton!
    @IBOutlet weak var buttonUserLogOut: UIButton!
    @IBOutlet weak var buttonGroups: UIButton!
    
    @IBOutlet weak var switchNotificationCommentMyReport: UISwitch!
    @IBOutlet weak var switchNotificationAdminClosesMyReport: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        buttonUserLogOut.addTarget(self, action: #selector(UserProfileSettingsTableViewController.attemptUserLogOut(_:)), forControlEvents: .TouchUpInside)
        
        //
        //
        //
        self.tableView.backgroundColor = UIColor.colorBackground(1.00)

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    //
    // MARK: Table View Controller Customization
    //
    override func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        
        let header: UITableViewHeaderFooterView = view as! UITableViewHeaderFooterView
        header.textLabel!.textColor = UIColor.colorDarkGray(0.5)
        header.contentView.backgroundColor = UIColor.colorBackground(1.00)
        
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        if section == 1 {
            return 24.0
        }

        return 48.0
    }
    
    override func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 1.0
    }
    
    
    //
    // MARK: Custom Functionality
    //
    @IBAction func attemptUserLogOut(sender:UIButton) {
        var attemptToDismissLoginTableViewController: Bool = true;

        NSUserDefaults.standardUserDefaults().removeObjectForKey("currentUserAccountAccessToken")
        NSUserDefaults.standardUserDefaults().removeObjectForKey("currentUserAccountUID")
        
        dismissViewControllerAnimated(true, completion: {
            attemptToDismissLoginTableViewController = false
            self.performSegueWithIdentifier("showLoginTableViewControllerFromLogoutViewController", sender: self)
        })

        if (attemptToDismissLoginTableViewController) {
            self.performSegueWithIdentifier("showLoginTableViewControllerFromLogoutViewController", sender: self)
        }
    }

}
