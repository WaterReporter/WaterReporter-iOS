//
//  UserProfileTableViewController.swift
//  Water-Reporter
//
//  Created by Viable Industries on 8/22/16.
//  Copyright © 2016 Viable Industries, L.L.C. All rights reserved.
//

import Alamofire
import Foundation
import UIKit

class UserProfileTableViewController: UITableViewController {
    
    var reportOwner:AnyObject!
    var reports = [AnyObject]()
    var page: Int = 1
    var currentTab: String = ""
    
    @IBOutlet weak var userProfileImage: UIImageView!
    @IBOutlet weak var userProfileName: UILabel!
    @IBOutlet weak var userProfileOrganization: UILabel!
    @IBOutlet weak var userProfileDescription: UILabel!
    
    @IBOutlet weak var userProfileButtonSubmissions: UIButton!
    @IBOutlet weak var userProfileButtonActions: UIButton!
    @IBOutlet weak var userProfileButtonGroups: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //
        // Load Basic User Profile Information
        //
        self.setupUserProfile()
        
        
        //
        // Load Basic Submissions Data
        //
        self.loadSubmissions()
        
        
        //
        // Setup Tab Targets
        //
        userProfileButtonSubmissions.addTarget(self, action: #selector(openSubmissionsTab(_:)), forControlEvents: .TouchUpInside)
        userProfileButtonActions.addTarget(self, action: #selector(openActionsTab(_:)), forControlEvents: .TouchUpInside)
        userProfileButtonGroups.addTarget(self, action: #selector(openGroupsTab(_:)), forControlEvents: .TouchUpInside)
    }
    
    func setupUserProfile() {
        
        //
        // User Profile Name
        //
        var reportOwnerFullName: String? = ""
        
        let reportOwnerFirstName = reportOwner?.objectForKey("first_name") as! String
        let reportOwnerLastName = reportOwner?.objectForKey("last_name") as! String
        
        reportOwnerFullName = reportOwnerFirstName + " " + reportOwnerLastName
        
        self.userProfileName.text = reportOwnerFullName

        //
        // User Profile Title/Organization
        //
        var reportOwnerOrganizationTitle: String? = ""
        
        let _title = reportOwner?.objectForKey("title") as? String
        let _organization = reportOwner?.objectForKey("organization_name") as? String
        
        if _title != nil && _organization != nil {
            reportOwnerOrganizationTitle = _title! + " at " + _organization!
        }
        else if _title != nil && _organization == nil {
            reportOwnerOrganizationTitle = _title!
        }
        else if _title == nil && _organization != nil {
            reportOwnerOrganizationTitle = _organization!
        }
        else {
            self.userProfileOrganization.hidden = true
        }
        
        self.userProfileOrganization.text = reportOwnerOrganizationTitle
        
        //
        // User Profile Description/Bio
        //
        let reportOwnerDescription = reportOwner?.objectForKey("description") as? String
        
        if reportOwnerDescription == nil {
            self.userProfileDescription.hidden = true
        }
        
        self.userProfileDescription.text = reportOwnerDescription
        
        //
        // User Profile Description/Bio
        //
        if let thisReportOwnerImageUrl = reportOwner?.objectForKey("picture") as? String  {
            ImageLoader.sharedLoader.imageForUrl(thisReportOwnerImageUrl, completionHandler:{(image: UIImage?, url: String) in
                self.userProfileImage.image = image!
                self.userProfileImage.layer.cornerRadius = self.userProfileImage.frame.size.width / 2;
                self.userProfileImage.clipsToBounds = true;
            })
        } else {
            ImageLoader.sharedLoader.imageForUrl("https://www.waterreporter.org/images/badget--MissingUser.png", completionHandler:{(image: UIImage?, url: String) in
                self.userProfileImage.image = image!
                self.userProfileImage.layer.cornerRadius = self.userProfileImage.frame.size.width / 2;
                self.userProfileImage.clipsToBounds = true;
            })
        }

    }
    
    func loadSubmissions() {
        
        print("loadSubmissions")

        //
        //
        //
        if (self.currentTab == "submissions") {
            return
        }

        self.currentTab = "submissions"

        //
        // Reset all list variables
        //
        self.page = 1
        reports = [AnyObject]()
        self.tableView.reloadData()
        
        //
        // Send a request to the defined endpoint with the given parameters
        //
        let userProfileId = reportOwner?.objectForKey("id")?.stringValue
        let parameters = [
            "q": "{\"filters\": [{\"name\":\"owner_id\", \"op\":\"eq\", \"val\":" + userProfileId! + "}], \"order_by\": [{\"field\":\"report_date\",\"direction\":\"desc\"},{\"field\":\"id\",\"direction\":\"desc\"}]}",
            "page": self.page
        ]
        
        Alamofire.request(.GET, Endpoints.GET_MANY_REPORTS, parameters: parameters as? [String : AnyObject])
            .responseJSON { response in
                
                switch response.result {
                case .Success(let value):
                    self.reports += value["features"] as! [AnyObject]
                    self.tableView.reloadData()
                    
                    print(value["features"])
                    self.page += 1
                    
                case .Failure(let error):
                    print(error)
                    break
                }
                
        }
    }
    
    func loadActions() {
        
        print("loadActions")
        
        //
        //
        //
        if (self.currentTab == "actions") {
            return
        }
        
        //
        //
        //
        self.currentTab = "actions"
        
        //
        // Reset all list variables
        //
        self.page = 1
        reports = [AnyObject]()
        self.tableView.reloadData()
        
        //
        // Send a request to the defined endpoint with the given parameters
        //
        let userProfileId = reportOwner?.objectForKey("id")?.stringValue
        let parameters = [
            "q": "{\"filters\": [{\"name\":\"owner_id\", \"op\":\"eq\", \"val\":" + userProfileId! + "},{\"name\":\"closed_id\", \"op\":\"eq\", \"val\":" + userProfileId! + "}], \"order_by\": [{\"field\":\"report_date\",\"direction\":\"desc\"},{\"field\":\"id\",\"direction\":\"desc\"}]}",
            "page": self.page
        ]
        
        Alamofire.request(.GET, Endpoints.GET_MANY_REPORTS, parameters: parameters as? [String : AnyObject])
            .responseJSON { response in
                                
                switch response.result {
                case .Success(let value):
                    self.reports += value["features"] as! [AnyObject]
                    self.tableView.reloadData()
                    
                    print(value["features"])
                    self.page += 1
                    
                case .Failure(let error):
                    print(error)
                    break
                }
                
        }
    }
    
    func loadGroups() {
        
        print("loadGroups")

        //
        //
        //
        if (self.currentTab == "groups") {
            return
        }
        
        self.currentTab = "groups"
        
        //
        // Reset all list variables
        //
        self.page = 1
        reports = [AnyObject]()
        self.tableView.reloadData()
        
        //
        // Send a request to the defined endpoint with the given parameters
        //
        let userProfileId = reportOwner?.objectForKey("id")?.stringValue
        let parameters = [
            "q": "",
            "page": 1
        ]
        
        let userEndpoint = Endpoints.GET_MANY_USER + "/" + userProfileId! + "/groups"
        
        Alamofire.request(.GET, userEndpoint, parameters: parameters as? [String : String])
            .responseJSON { response in
                
                switch response.result {
                case .Success(let value):
                    self.reports += value["features"] as! [AnyObject]
                    self.tableView.reloadData()
                    
                    print(value["features"])
//                    self.page += 1
                    
                case .Failure(let error):
                    print(error)
                    break
                }
                
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func createReportCell(indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("SingleReport", forIndexPath: indexPath) as! UserProfileTableViewCell
        
        //
        // Make sure we aren't loading old images into the new cells as
        // additional reports are loaded
        //
        cell.userReportImage.image = nil
        cell.userReportImage.image = nil

        //
        // Hide unused cells
        //
        cell.userReportImage.hidden = false
        cell.userReportDate.hidden = false
        cell.userReportTerritoryName.hidden = false
        cell.userReportButtonMap.hidden = false
        cell.userReportButtonProfile.hidden = false
        cell.userReportGroups.hidden = false
        cell.userReportDescription.hidden = false
        cell.userReportCommentsCount.hidden = false
        cell.userReportButtonComments.hidden = false
        cell.userReportButtonDirections.hidden = false
        
        //
        // REPORT OBJECT
        //
        let report = self.reports[indexPath.row].objectForKey("properties")
        cell.reportObject = report
        
        let reportDescription = report?.objectForKey("report_description")
        let reportDate = report?.objectForKey("report_date")
        let reportImages = report?.objectForKey("images")![0]?.objectForKey("properties")
        let reportImageURL = reportImages?.objectForKey("square")
        
        let reportOwner = report?.objectForKey("owner")?.objectForKey("properties")
        let reportOwnerImageURL = reportOwner?.objectForKey("picture")
        
        
        //
        // Territory
        //
        let reportTerritory = report?.objectForKey("territory") as? NSDictionary
        
        var reportTerritoryName: String? = "Unknown Watershed"
        if let thisReportTerritory = reportTerritory?.objectForKey("properties")?.objectForKey("huc_8_name") as? String {
            reportTerritoryName = (thisReportTerritory) + " Watershed"
        }
        
        cell.userReportTerritoryName.text = reportTerritoryName
        
        
        //
        // Comment Count
        //
        let reportComments = report?.objectForKey("comments") as! NSArray
        
        var reportCommentsCountText: String = "0 comments"
        
        if reportComments.count == 1 {
            reportCommentsCountText = "1 comment"
        }
        else if reportComments.count >= 1 {
            //reportCommentsCountText = reportComments.count as! String + " comments"
        } else {
            print("No objects")
        }
        
        cell.userReportCommentsCount.setTitle(reportCommentsCountText, forState: UIControlState.Normal)
        
        
        //
        // GROUPS
        //
        let reportGroups = report?.objectForKey("groups") as? NSArray
        var reportGroupsNames: String? = ""
        
        let reportGroupsTotal = reportGroups!.count
        var reportGroupsIncrementer = 1;
        
        for _group in reportGroups! as NSArray {
            let thisGroupName = _group.objectForKey("properties")!.objectForKey("name") as! String
            
            if reportGroupsTotal == 1 || reportGroupsIncrementer == 1 {
                reportGroupsNames = thisGroupName
            }
            else if (reportGroupsTotal > 1 && reportGroupsIncrementer > 1)  {
                reportGroupsNames = reportGroupsNames! + ", " + thisGroupName
            }
            
            reportGroupsIncrementer += 1
        }
        
        cell.userReportGroups.text = reportGroupsNames
        
        
        //
        // USER NAME
        //
        if let firstName = reportOwner?.objectForKey("first_name"),
            let lastName = reportOwner?.objectForKey("last_name") {
            cell.userReportOwnerName.text = (firstName as! String) + " " + (lastName as! String)
        } else {
            cell.userReportOwnerName.text = "Unknown Reporter"
        }
        
        cell.userReportDescription.text = reportDescription as? String
        
        //
        // IMAGES
        //
        cell.userReportButtonProfile.tag = indexPath.row
        if let thisReportOwnerImageUrl = reportOwnerImageURL as? String  {
            ImageLoader.sharedLoader.imageForUrl(thisReportOwnerImageUrl, completionHandler:{(image: UIImage?, url: String) in
                cell.userReportOwnerImage.image = image!
                cell.userReportOwnerImage.layer.cornerRadius = cell.userReportOwnerImage.frame.size.width / 2;
                cell.userReportOwnerImage.clipsToBounds = true;
            })
        } else {
            ImageLoader.sharedLoader.imageForUrl("https://www.waterreporter.org/images/badget--MissingUser.png", completionHandler:{(image: UIImage?, url: String) in
                cell.userReportOwnerImage.image = image!
                cell.userReportOwnerImage.layer.cornerRadius = cell.userReportOwnerImage.frame.size.width / 2;
                cell.userReportOwnerImage.clipsToBounds = true;
            })
        }
        
        ImageLoader.sharedLoader.imageForUrl(reportImageURL as! String, completionHandler:{(image: UIImage?, url: String) in
            let image = UIImage(CGImage: (image?.CGImage)!, scale: 1.0, orientation: .Up)
            cell.userReportImage.image = image
        })
        
        //
        // DATE
        //
        let dateString = reportDate as! String
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        
        let stringToFormat = dateFormatter.dateFromString(dateString)
        dateFormatter.dateFormat = "MMM d, yyyy"
        
        let displayDate = dateFormatter.stringFromDate(stringToFormat!)
        
        if let thisDisplayDate: String? = displayDate {
            cell.userReportDate.text = thisDisplayDate
        }
        
        //
        // PASS ON DATA TO TABLE CELL
        //
        cell.userReportButtonMap.tag = indexPath.row
        
        cell.userReportButtonDirections.tag = indexPath.row
        cell.userReportButtonDirections.addTarget(self, action: #selector(openDirectionsURL(_:)), forControlEvents: .TouchUpInside)
        
        
        //
        // CONTIUOUS SCROLL
        //
        if (indexPath.row == self.reports.count - 1) {
            self.loadSubmissions()
        }
        
        return cell
    }

    func createGroupCell(indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("SingleReport", forIndexPath: indexPath) as! UserProfileTableViewCell
        
        //
        // Make sure we aren't loading old images into the new cells as
        // additional reports are loaded
        //
        cell.userReportOwnerImage.image = nil
        
        //
        // Hide unused cells
        //
        cell.userReportImage.hidden = true
        cell.userReportDate.hidden = true
        cell.userReportTerritoryName.hidden = true
        cell.userReportButtonMap.hidden = true
        cell.userReportButtonProfile.hidden = true
        cell.userReportGroups.hidden = true
        cell.userReportDescription.hidden = true
        cell.userReportCommentsCount.hidden = true
        cell.userReportButtonComments.hidden = true
        cell.userReportButtonDirections.hidden = true
        
        //
        // REPORT OBJECT
        //
        let group = self.reports[indexPath.row].objectForKey("properties")?.objectForKey("organization")?.objectForKey("properties")
        cell.reportObject = group
        
        let reportGroupName = group?.objectForKey("name") as? String
        let reportGroupImageURL = group?.objectForKey("picture")
        
        //
        // USER NAME
        //
        cell.userReportOwnerName.text = reportGroupName
        
        //
        // IMAGES
        //
        cell.userReportButtonProfile.tag = indexPath.row
        if let thisReportOwnerImageUrl = reportGroupImageURL as? String  {
            ImageLoader.sharedLoader.imageForUrl(thisReportOwnerImageUrl, completionHandler:{(image: UIImage?, url: String) in
                cell.userReportOwnerImage.image = image!
                cell.userReportOwnerImage.layer.cornerRadius = cell.userReportOwnerImage.frame.size.width / 2
                cell.userReportOwnerImage.clipsToBounds = true
                
                cell.userReportOwnerImage.layer.borderColor = UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1.0).CGColor
                cell.userReportOwnerImage.layer.borderWidth = 1

//                cell.userReportOwnerImage.userInteractionEnabled = true
//                cell.userReportOwnerImage.addGestureRecognizer(tapGestureRecognizer)
            })
        }
        
        //
        // When a group row is tapped we need to load the related organization profile
        //
//        let tapGestureRecognizer = UITapGestureRecognizer(target:self, action:#selector(UserProfileTableViewController.imageTapped(_:)))
//        cell.addGestureRecognizer(tapGestureRecognizer)
        
        return cell
    }
    
//    func imageTapped(img: AnyObject)
//    {
//        print("load organization profile")
//    }

    
    
    // MARK: - Table view data source

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let group = self.reports[indexPath.row].objectForKey("properties")?.objectForKey("organization")?.objectForKey("properties")

        //
        // Load the activity controller from the storyboard
        //
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        
        let nextViewController = storyBoard.instantiateViewControllerWithIdentifier("OrganizationProfileTableViewController") as! OrganizationProfileTableViewController
        
        nextViewController.group = group
        
        self.navigationController?.pushViewController(nextViewController, animated: true)

    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.reports.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell: UITableViewCell
        
        if (self.currentTab == "groups") {
            cell = createGroupCell(indexPath)
        }
        else {
            cell = createReportCell(indexPath)
        }
        
        return cell
    }
    
    func openDirectionsURL(sender: UIBarButtonItem) {
        
        let reportId = sender.tag
        let report = self.reports[reportId]
        
        let reportGeometry = report.objectForKey("geometry")
        let reportGeometries = reportGeometry!.objectForKey("geometries")
        let reportCoordinates = reportGeometries![0].objectForKey("coordinates") as! Array<Double>
        
        let reportLongitude = reportCoordinates[0]
        let reportLatitude = reportCoordinates[1]
        
        UIApplication.sharedApplication().openURL(NSURL(string: "https://www.google.com/maps/dir//" + String(reportLatitude) + "," + String(reportLongitude))!)
    }

    
    func openActionsTab(sender: UIButton) {
        self.loadActions()
    }

    func openGroupsTab(sender: UIButton) {
        self.loadGroups()
    }

    func openSubmissionsTab(sender: UIButton) {
        self.loadSubmissions()
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