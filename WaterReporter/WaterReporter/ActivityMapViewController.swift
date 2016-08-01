//
//  ActivityMapViewController.swift
//  WaterReporter
//
//  Created by Viable Industries on 8/1/16.
//  Copyright © 2016 Viable Industries, L.L.C. All rights reserved.
//

import Foundation
import Mapbox
import UIKit

class ActivityMapViewController: UIViewController {
    
    var reportObject:AnyObject!
    var reportLongitude:Double!
    var reportLatitude:Double!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //
        // Set the "Get Directions" Bar Button
        //
        let rightBarButton = UIBarButtonItem(title: "Get Directions", style: UIBarButtonItemStyle.Plain, target: self, action:#selector(openDirectionsURL(_:)))
        
        self.navigationItem.rightBarButtonItem = rightBarButton
        
        //
        // Setup default coordinates based on the Report selected on the previous page
        //
        self.setCoordinateDefaults()
        
        //
        // Setup map view and add it to the view controller
        //
        self.setupMap()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setupMap() {
        let mapView = MGLMapView(frame: view.bounds)

        mapView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        mapView.setCenterCoordinate(CLLocationCoordinate2D(latitude: reportLatitude, longitude: reportLongitude), zoomLevel: 15, animated: false)
        
        //
        // Add default center pin to the map
        //
        self.addReportToMap(mapView, latitude: reportLatitude, longitude: reportLongitude)
        
        
        view.addSubview(mapView)
    }
    
    func addReportToMap(mapView: AnyObject, latitude: Double, longitude: Double) {
        let selectedReportAnnotation = MGLPointAnnotation()
        selectedReportAnnotation.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        mapView.addAnnotation(selectedReportAnnotation)
    }
    
    func setCoordinateDefaults() {
        let reportCoordinates = reportObject?.objectForKey("geometry")!.objectForKey("geometries")![0].objectForKey("coordinates")
        
        reportLongitude = (reportCoordinates![0] as? NSNumber)!.doubleValue
        reportLatitude = (reportCoordinates![1] as? NSNumber)!.doubleValue
    }
    
    func openDirectionsURL(sender: UIBarButtonItem) {
        
        if ((reportLongitude) != nil && (reportLatitude) != nil) {
            UIApplication.sharedApplication().openURL(NSURL(string: "https://www.google.com/maps/dir//" + String(reportLatitude) + "," + String(reportLongitude))!)
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
