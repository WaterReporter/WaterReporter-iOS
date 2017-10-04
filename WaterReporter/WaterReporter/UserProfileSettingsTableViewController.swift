//
//  UserProfileSettingsTableViewController.swift
//  Water-Reporter
//
//  Created by Viable Industries on 10/13/16.
//  Copyright © 2016 Viable Industries, L.L.C. All rights reserved.
//

import Alamofire
import Foundation
import SwiftyJSON
import UIKit

class UserProfileSettingsTableViewController: UITableViewController, UINavigationControllerDelegate {
    
    var notificationCount: Int = 2
    var tempGroups: [String] = [String]()
    
    @IBOutlet weak var buttonEditProfile: UIButton!
    @IBOutlet weak var buttonUserLogOut: UIButton!
    @IBOutlet weak var buttonGroups: UIButton!
    
    @IBOutlet weak var can_notify_owner_comment_on_owned_report: UISwitch!
    @IBOutlet weak var can_notify_admin_user_joins_group: UISwitch!
    @IBOutlet weak var can_notify_owner_admin_closes_owned_report: UISwitch!
    @IBOutlet weak var can_notify_admin_user_submits_report_in_territory: UISwitch!
    @IBOutlet weak var can_notify_admin_user_submits_report_in_group: UISwitch!
    @IBOutlet weak var can_notify_admin_comment_on_report_in_territory: UISwitch!
    @IBOutlet weak var can_notify_admin_comment_on_report_in_group: UISwitch!
    @IBOutlet weak var can_notify_owner_like_report: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        buttonUserLogOut.addTarget(self, action: #selector(UserProfileSettingsTableViewController.attemptUserLogOut(_:)), forControlEvents: .TouchUpInside)
        
        buttonGroups.enabled = false
        
        self.can_notify_owner_comment_on_owned_report.enabled = false
        self.can_notify_owner_like_report.enabled = false
        self.can_notify_admin_user_joins_group.enabled = false
        self.can_notify_owner_admin_closes_owned_report.enabled = false
        self.can_notify_admin_user_submits_report_in_territory.enabled = false
        self.can_notify_admin_user_submits_report_in_group.enabled = false
        self.can_notify_admin_comment_on_report_in_territory.enabled = false
        self.can_notify_admin_comment_on_report_in_group.enabled = false

        //
        //
        //
        self.tableView.backgroundColor = UIColor.colorBackground(1.00)
        
        
        // Load the defaults for the notifications from the user profile
        //
        let _userId = NSUserDefaults.standardUserDefaults().objectForKey("currentUserAccountUID")
        
        if (_userId != nil) {
            print("viewDidLoad::_userId \(_userId)")
            self.attemptLoadUserProfile()
        } else {
            self.attemptRetrieveUserID()
        }

        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "showMyGroupsTableViewController" {
            let destViewController = segue.destinationViewController as! UINavigationController
            let _groupTableViewController = destViewController.topViewController as! GroupsTableViewController
            
            _groupTableViewController.tempGroups = self.tempGroups
        }
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
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        var numberOfRowsInSection: Int = 3
        
        switch(section) {
            case 0:
                numberOfRowsInSection = notificationCount
                break
            default:
                break
        }
        
        return numberOfRowsInSection
    }
    
    //
    // MARK: Custom Functionality
    //
    @IBAction func dismissSettingsTableViewController(sender: UIBarButtonItem) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    @IBAction func doneMakingChangesToNotificationSettings(sender: UIBarButtonItem) {
        print("SAVE AND DISMISS")
        
        

        let uiBusy = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
        uiBusy.hidesWhenStopped = true
        uiBusy.startAnimating()
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: uiBusy)
        
        //
        // Construct the necessary headers and parameters to complete the request
        //
        let accessToken = NSUserDefaults.standardUserDefaults().objectForKey("currentUserAccountAccessToken")
        let headers = [
            "Authorization": "Bearer " + (accessToken! as! String)
        ]
        
        Alamofire.request(.GET, Endpoints.GET_USER_ME, headers: headers, encoding: .JSON)
            .responseJSON { response in
                
                switch response.result {
                case .Success(let value):
                    print("Request \(Endpoints.GET_USER_ME) Success \(value)")
                    
                    if let userId = value.valueForKey("id") as? NSNumber {
                        self.attemptUserProfileSave("\(userId)", _headers: headers)
                    }
                    
                case .Failure(let error):
                    print("Request \(Endpoints.GET_USER_ME) Failure \(error)")
                    break
                }
                
        }
    }

    @IBAction func attemptUserLogOut(sender:UIButton) {

        NSUserDefaults.standardUserDefaults().removeObjectForKey("currentUserAccountAccessToken")
        NSUserDefaults.standardUserDefaults().removeObjectForKey("currentUserAccountUID")
        NSUserDefaults.standardUserDefaults().removeObjectForKey("currentUserAccountUID")
        
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        
        let nextViewController = storyBoard.instantiateViewControllerWithIdentifier("LoginTableViewController") as! LoginTableViewController
        
        self.presentViewController(nextViewController, animated: false, completion: {
            print("showLoginViewController > presentViewController")
            
        })

        
    }
    
    func attemptUserProfileSave(_userId: String, _headers: [String: String]) {
        
        let _endpoint = Endpoints.POST_USER_PROFILE + _userId;
        
        let _parameters: [String: AnyObject] = [
            "can_notify_admin_user_joins_group": self.can_notify_admin_user_joins_group.on,
            "can_notify_admin_comment_on_report_in_group": self.can_notify_admin_comment_on_report_in_group.on,
            "can_notify_owner_like_report": self.can_notify_owner_like_report.on,
            "can_notify_admin_comment_on_report_in_territory": self.can_notify_admin_comment_on_report_in_territory.on,
            "can_notify_admin_admin_closes_report_in_group": self.can_notify_admin_comment_on_report_in_group.on,
            "can_notify_admin_admin_closes_report_in_territory": self.can_notify_admin_comment_on_report_in_territory.on,
            "can_notify_admin_user_submits_report_in_group": self.can_notify_admin_user_submits_report_in_group.on,
            "can_notify_admin_user_submits_report_in_territory": self.can_notify_admin_user_submits_report_in_territory.on,
            "can_notify_owner_comment_on_owned_report": self.can_notify_owner_comment_on_owned_report.on,
            "can_notify_owner_admin_closes_owned_report": self.can_notify_owner_admin_closes_owned_report.on,
        ]
        
        Alamofire.request(.PATCH, _endpoint, parameters: _parameters, headers: _headers, encoding: .JSON)
            .responseJSON { response in
                
                print("Response \(response)")
                
                switch response.result {
                case .Success(let value):
                    
                    print("Response Success \(value)")
                    
                    self.dismissViewControllerAnimated(true, completion: {
                        self.dismissViewControllerAnimated(true, completion: nil)
                    })
                    
                case .Failure(let error):
                    print("attemptUserProfileSave::Failure")
                    print(error)
                    break
                }
                
        }
        
        
    }
    
    //
    // MARK: HTTP Request/Response functionality
    //
    func attemptLoadUserProfile() {
        
        let accessToken = NSUserDefaults.standardUserDefaults().objectForKey("currentUserAccountAccessToken")
        let headers = [
            "Authorization": "Bearer " + (accessToken! as! String)
        ]
        
        if let userId = NSUserDefaults.standardUserDefaults().objectForKey("currentUserAccountUID") as? NSNumber {
            
            let revisedEndpoint = Endpoints.GET_USER_PROFILE + "\(userId)"
            
            Alamofire.request(.GET, revisedEndpoint, headers: headers, encoding: .JSON).responseJSON { response in
                
                print("response.result \(response.result)")
                
                switch response.result {
                case .Success(let value):
                    let json = JSON(value)
                    
                    if (json != nil) {
                        let _user_profile = json
                        
                        if (_user_profile["properties"]["groups"].count >= 1) {
                            print("groups found")
                            // Add groups to tempGroups
                            self.tempGroups = self.createTempGroupsArray(_user_profile["properties"]["groups"])
                            
                        }
                        else {
                            print("no groups")
                        }
                        self.buttonGroups.enabled = true
                        
                        if (_user_profile["properties"]["roles"].count >= 1) {
                            if (_user_profile["properties"]["roles"][0]["properties"]["name"] == "admin") {

                                if _user_profile["properties"]["can_notify_admin_user_joins_group"] {
                                    self.can_notify_admin_user_joins_group.on = _user_profile["properties"]["can_notify_admin_user_joins_group"].bool! || false
                                }
                                self.can_notify_admin_user_joins_group.enabled = true

                                if _user_profile["properties"]["can_notify_admin_user_submits_report_in_territory"] {
                                    self.can_notify_admin_user_submits_report_in_territory.on = _user_profile["properties"]["can_notify_admin_user_submits_report_in_territory"].bool! || false
                                }
                                self.can_notify_admin_user_submits_report_in_territory.enabled = true
                                
                                if _user_profile["properties"]["can_notify_admin_user_submits_report_in_group"] {
                                    self.can_notify_admin_user_submits_report_in_group.on = _user_profile["properties"]["can_notify_admin_user_submits_report_in_group"].bool! || false
                                }
                                self.can_notify_admin_user_submits_report_in_group.enabled = true
                                
                                if _user_profile["properties"]["can_notify_admin_comment_on_report_in_territory"] {
                                    self.can_notify_admin_comment_on_report_in_territory.on = _user_profile["properties"]["can_notify_admin_comment_on_report_in_territory"].bool! || false
                                }
                                self.can_notify_admin_comment_on_report_in_territory.enabled = true
                                
                                if _user_profile["properties"]["can_notify_admin_comment_on_report_in_group"] {
                                    self.can_notify_admin_comment_on_report_in_group.on = _user_profile["properties"]["can_notify_admin_comment_on_report_in_group"].bool! || false
                                }
                                self.can_notify_admin_comment_on_report_in_group.enabled = true
                                
                                if _user_profile["properties"]["can_notify_owner_like_report"]
                                {
                                    self.can_notify_owner_like_report.on = _user_profile["properties"]["can_notify_owner_like_report"].bool! || false
                                }
                                self.can_notify_owner_like_report.enabled = true
                                
                                // Update the total number of rows to display for administrators
                                self.notificationCount = 7
                            }
                        }
                        
                        if _user_profile["properties"]["can_notify_owner_comment_on_owned_report"] {
                            self.can_notify_owner_comment_on_owned_report.on = _user_profile["properties"]["can_notify_owner_comment_on_owned_report"].bool!
                        }
                        self.can_notify_owner_comment_on_owned_report.enabled = true
                        
                        if _user_profile["properties"]["can_notify_owner_admin_closes_owned_report"] {
                            self.can_notify_owner_admin_closes_owned_report.on = _user_profile["properties"]["can_notify_owner_admin_closes_owned_report"].bool! || false
                        }
                        self.can_notify_owner_admin_closes_owned_report.enabled = true

                        self.tableView.reloadData()

                    }
                    
                case .Failure(let error):
                    print(error)
                }
            }
            
        } else {
            self.attemptRetrieveUserID()
        }
        
    }
    
    func createTempGroupsArray(_groups: JSON) -> [String] {
        
        var _temp_groups: [String] = [String]()
        
        for _group in _groups {
            _temp_groups.append("\(_group.1["properties"]["organization_id"])")
        }
        
        return _temp_groups
    }
    
    func attemptRetrieveUserID() {
        
        let accessToken = NSUserDefaults.standardUserDefaults().objectForKey("currentUserAccountAccessToken")
        let headers = [
            "Authorization": "Bearer " + (accessToken! as! String)
        ]
        
        Alamofire.request(.GET, Endpoints.GET_USER_ME, headers: headers, encoding: .JSON)
            .responseJSON { response in
                
                switch response.result {
                case .Success(let value):
                    let json = JSON(value)
                    
                    if let data: AnyObject = json.rawValue {
                        NSUserDefaults.standardUserDefaults().setValue(data["id"], forKeyPath: "currentUserAccountUID")
                        
                        self.attemptLoadUserProfile()
                    }
                    
                case .Failure(let error):
                    print(error)
                }
        }
    }

}
