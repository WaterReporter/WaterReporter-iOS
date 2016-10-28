//
//  ActivityTableViewController.swift
//  WaterReporter
//
//  Created by Viable Industries on 7/25/16.
//  Copyright © 2016 Viable Industries, L.L.C. All rights reserved.
//

import Alamofire
import Foundation
import UIKit

class ActivityTableViewController: UITableViewController {
    
    var reports = [AnyObject]()
    var singleReport: Bool = false
    var page: Int = 1
        
    @IBOutlet var indicatorLoadingView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //
        // Enable scroll to top of UITableView when title 
        // bar is tapped
        //
        self.tableView.scrollEnabled = true
        self.tableView.scrollsToTop = true
        
        //
        // Load 10 newest reports from API on Activity View load
        //
        if (!singleReport) {

            //
            // Display loading indicator
            //
            self.loading()
            
            if (self.refreshControl == nil) {
                self.refreshControl = UIRefreshControl()
            }
            
            self.reports = []
            self.page = 1
            self.tableView.reloadData()

            //
            // Set the Navigation Bar title
            //
            self.navigationItem.title = "Activity"
            
            self.navigationItem.setHidesBackButton(true, animated:true);
            
            //
            // Setup pull to refresh functionality for our TableView
            //
            self.refreshControl?.addTarget(self, action: #selector(ActivityTableViewController.refreshTableView(_:)), forControlEvents: UIControlEvents.ValueChanged)

            self.loadReports()
        }
        
    }
    
    func loading() {
        
        //
        // Create a view that covers the entire screen
        //
        self.indicatorLoadingView.frame = CGRectMake(0, 0, self.view.frame.width, self.view.frame.height)
        self.indicatorLoadingView.backgroundColor = UIColor.whiteColor()
        
        self.view.addSubview(self.indicatorLoadingView)
        self.view.bringSubviewToFront(self.indicatorLoadingView)
        
        self.tableView.separatorStyle = UITableViewCellSeparatorStyle.None

    }
    
    func loadingComplete() {
        
        //
        // Remove loading screen
        //
        self.indicatorLoadingView.removeFromSuperview()

        if (!singleReport) {
            self.tableView.separatorStyle = UITableViewCellSeparatorStyle.SingleLine
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        
        
        //
        // We need to execute the necessary code here to make
        // sure the Report Single view displays from the map view
        // and other views
        //
        print("Needs to reload for single report")

        self.tableView.rowHeight = UITableViewAutomaticDimension;
        self.tableView.estimatedRowHeight = 600.0;
        self.tableView.backgroundColor = UIColor.whiteColor()
        self.tableView.scrollsToTop = true
        
        //
        // Special directions for Single Report view
        //
        if (singleReport) {
            
            //
            // For single report view we need to disable pull-to-refresh
            //
            self.refreshControl = nil
            self.tableView.separatorStyle = UITableViewCellSeparatorStyle.None
            self.tableView.reloadData()
        }
        
    }

    
    func loadReports(isRefreshingReportsList: Bool = false) {
        
        //
        // Send a request to the defined endpoint with the given parameters
        //
        let parameters = [
            "q": "{\"order_by\": [{\"field\":\"report_date\",\"direction\":\"desc\"},{\"field\":\"id\",\"direction\":\"desc\"}]}",
            "page": self.page
        ]
        
        Alamofire.request(.GET, Endpoints.GET_MANY_REPORTS, parameters: parameters as? [String : AnyObject])
            .responseJSON { response in
                
                switch response.result {
                case .Success(let value):
                    
                    //
                    // Choose whether or not the reports should refresh or
                    // whether loaded reports should be appended to the existing
                    // list of reports
                    //
                    if (isRefreshingReportsList) {
                        self.reports = value["features"] as! [AnyObject]
                        self.refreshControl?.endRefreshing()
                    }
                    else {
                        self.reports += value["features"] as! [AnyObject]
                    }

                    self.tableView.reloadData()

                    print(value["features"])
                    self.page += 1
                    
                    //
                    // Dismiss the loading indicator
                    //
                    self.loadingComplete()
                    
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
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "reportToActivityMap" {
            let destViewController = segue.destinationViewController as! ActivityMapViewController
            destViewController.reportObject = self.reports[(sender?.tag)!]
        }
        else if segue.identifier == "reportToUserProfile" {
            let destViewController = segue.destinationViewController as! UserProfileTableViewController
            let reportOwner = self.reports[(sender?.tag)!].objectForKey("properties")?.objectForKey("owner")?.objectForKey("properties")
            destViewController.reportOwner = reportOwner
        }
    }
    
    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.reports.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCellWithIdentifier("SingleReport", forIndexPath: indexPath) as! TableViewCell
        
        //
        // Make sure we aren't loading old images into the new cells as
        // additional reports are loaded
        //
//        cell.reportImage.image = nil
//        cell.reportOwnerImage.image = nil
        
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
        
        cell.reportTerritoryName.text = reportTerritoryName

        
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
        
        cell.reportCommentCount.setTitle(reportCommentsCountText, forState: UIControlState.Normal)

        
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

        cell.reportGroups.text = reportGroupsNames

        
        //
        // USER NAME
        //
        if let firstName = reportOwner?.objectForKey("first_name"),
           let lastName = reportOwner?.objectForKey("last_name") {
            cell.reportUserName.text = (firstName as! String) + " " + (lastName as! String)
        } else {
            cell.reportUserName.text = "Unknown Reporter"
        }
        
        cell.reportDescription.text = reportDescription as? String
        
        //
        // IMAGES
        //
        cell.reportOwnerImageButton.tag = indexPath.row
        if let thisReportOwnerImageUrl = reportOwnerImageURL as? String  {
            ImageLoader.sharedLoader.imageForUrl(thisReportOwnerImageUrl, completionHandler:{(image: UIImage?, url: String) in
                cell.reportOwnerImage.image = image!
                cell.reportOwnerImage.layer.cornerRadius = cell.reportOwnerImage.frame.size.width / 2;
                cell.reportOwnerImage.clipsToBounds = true;
            })
        } else {
            ImageLoader.sharedLoader.imageForUrl("https://www.waterreporter.org/images/badget--MissingUser.png", completionHandler:{(image: UIImage?, url: String) in
                cell.reportOwnerImage.image = image!
                cell.reportOwnerImage.layer.cornerRadius = cell.reportOwnerImage.frame.size.width / 2;
                cell.reportOwnerImage.clipsToBounds = true;
            })
        }
        
        ImageLoader.sharedLoader.imageForUrl(reportImageURL as! String, completionHandler:{(image: UIImage?, url: String) in
            let image = UIImage(CGImage: (image?.CGImage)!, scale: 1.0, orientation: .Up)
            cell.reportImage.image = image
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
            cell.reportDate.text = thisDisplayDate
        }
        
        //
        // PASS ON DATA TO TABLE CELL
        //
        cell.reportGetDirectionsButton.tag = indexPath.row

        cell.reportDirectionsButton.tag = indexPath.row
        cell.reportDirectionsButton.addTarget(self, action: #selector(openDirectionsURL(_:)), forControlEvents: .TouchUpInside)
        
        
        //
        // CONTIUOUS SCROLL
        //
        if (indexPath.row == self.reports.count - 5 && !singleReport) {
            self.loadReports()
        }

        return cell
    }
    
    func openDirectionsURL(sender: UIBarButtonItem) {
        
        let reportId = sender.tag
        let report = self.reports[reportId]

        let reportGeometry = report.objectForKey("geometry")
        let reportGeometries = reportGeometry!.objectForKey("geometries")
        let reportCoordinates = reportGeometries![0].objectForKey("coordinates") as! Array<Double>
        
        UIApplication.sharedApplication().openURL(NSURL(string: "https://www.google.com/maps/dir//" + String(reportCoordinates[1]) + "," + String(reportCoordinates[0]))!)
    }
    
    func refreshTableView(refreshControl: UIRefreshControl) {
        
        //
        // Load 10 newest reports from API on Activity View load
        //
        if (!singleReport) {
            
            self.page = 1
            self.reports = []
            
            self.loadReports(true)
        } else {
            self.refreshControl?.endRefreshing()
        }
        
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
