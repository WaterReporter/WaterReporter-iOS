//
//  ActivityTableViewController.swift
//  WaterReporter
//
//  Created by Viable Industries on 7/25/16.
//  Copyright © 2016 Viable Industries, L.L.C. All rights reserved.
//

import Foundation
import Alamofire
import UIKit

class ActivityTableViewController: UITableViewController {
    
    var reports = [AnyObject]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        
        //
        // Set the Navigation Bar title
        //
        self.navigationItem.title = "Activity"

//        self.tableView.rowHeight = UITableViewAutomaticDimension;
//        self.tableView.estimatedRowHeight = 400.0; // set to whatever your "average" cell height is

        //
        // Send a request to the defined endpoint with the given parameters
        //
        Alamofire.request(.GET, Endpoints.GET_MANY_REPORTS, parameters: ["":""])
            .responseJSON { response in
                
                switch response.result {
                    
                case .Success(let value):
                    self.reports = value["features"] as! [AnyObject]
                    self.tableView.reloadData()
                case .Failure(let error):
                    print(error)
                    break
                }
                
        }
        
        self.tableView.backgroundColor = UIColor.whiteColor()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let destViewController = segue.destinationViewController as! ActivityMapViewController
        
        if segue.identifier == "reportToActivityMap" {
            print("sender.tag")
            destViewController.reportObject = self.reports[(sender?.tag)!]
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
        
        let report = self.reports[indexPath.row].objectForKey("properties")
        let reportDescription = report?.objectForKey("report_description")
        let reportImages = report?.objectForKey("images")![0]?.objectForKey("properties")
        let reportImageURL = reportImages?.objectForKey("square")

        let reportOwner = report?.objectForKey("owner")?.objectForKey("properties")
        let reportOwnerName = ((reportOwner?.objectForKey("first_name"))! as! String) + " " + ((reportOwner?.objectForKey("last_name"))! as! String)
        let reportOwnerImageURL = reportOwner?.objectForKey("picture")
        
        let reportTerritory = report?.objectForKey("territory")?.objectForKey("properties")
        let reportTerritoryName = ((reportTerritory?.objectForKey("huc_8_name"))! as! String) + " Watershed"
        
//        let reportGroups = report?.objectForKey("groups")!.objectForKey("features") as! [Dictionary<String, AnyObject>]

        cell.reportObject = report

        cell.reportUserName.text = reportOwnerName
        cell.reportTerritoryName.text = reportTerritoryName
        cell.reportDescription.text = reportDescription as! String
        
        cell.reportGroups.text = "Group 1 Test, Group 2 Test"
        
        ImageLoader.sharedLoader.imageForUrl(reportOwnerImageURL as! String, completionHandler:{(image: UIImage?, url: String) in
            cell.reportOwnerImage.image = image!
            cell.reportOwnerImage.layer.cornerRadius = cell.reportOwnerImage.frame.size.width / 2;
            cell.reportOwnerImage.clipsToBounds = true;
        })
        
        ImageLoader.sharedLoader.imageForUrl(reportImageURL as! String, completionHandler:{(image: UIImage?, url: String) in
            cell.reportImage.image = UIImage(CGImage: (image?.CGImage)!, scale: 1.0, orientation: .Up)
        })

        cell.reportGetDirectionsButton.tag = indexPath.row

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
