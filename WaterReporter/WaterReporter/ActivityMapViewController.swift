//
//  ActivityMapViewController.swift
//  WaterReporter
//
//  Created by Viable Industries on 8/1/16.
//  Copyright © 2016 Viable Industries, L.L.C. All rights reserved.
//

import Foundation
import UIKit

class ActivityMapViewController: UIViewController {
    
    var reportObject:AnyObject!
    
    var reportLongitude:String!
    var reportLatitude:String!
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //
        // Set the "Get Directions" Bar Button
        //
        let rightBarButton = UIBarButtonItem(title: "Get Directions", style: UIBarButtonItemStyle.Plain, target: self, action:#selector(openDirectionsURL(_:)))
        
        self.navigationItem.rightBarButtonItem = rightBarButton
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func openDirectionsURL(sender: UIBarButtonItem) {
        
        //
        // Set coordinates to use for directions
        //
        let reportCoordinates = reportObject?.objectForKey("geometry")!.objectForKey("geometries")![0].objectForKey("coordinates")
        
        reportLongitude = String(reportCoordinates![0])
        reportLatitude = String(reportCoordinates![1])

        if ((reportLongitude) != nil && (reportLatitude) != nil) {
            UIApplication.sharedApplication().openURL(NSURL(string: "https://www.google.com/maps/dir//" + reportLatitude + "," + reportLongitude)!)
        } else {
            self.alertMissingCoordinates()
        }
    }
    
    func alertMissingCoordinates() {
        let alertController = UIAlertController(title: "No coordinates found", message:
            "We cannot display directions for this report because of missing coordinates.", preferredStyle: UIAlertControllerStyle.Alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default,handler: nil))
        
        self.presentViewController(alertController, animated: true, completion: nil)
    }
}
