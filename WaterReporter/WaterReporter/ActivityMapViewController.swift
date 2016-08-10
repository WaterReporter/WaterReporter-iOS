//
//  ActivityMapViewController.swift
//  WaterReporter
//
//  Created by Viable Industries on 8/1/16.
//  Copyright © 2016 Viable Industries, L.L.C. All rights reserved.
//

import Alamofire
import Foundation
import Mapbox
import UIKit

class ActivityMapViewController: UIViewController {
    
    var reports = [AnyObject]()
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
        
        //
        // Load additional region based pins
        //
        self.loadAllReportsInRegion(mapView)
        
        //
        // Add map to subview
        //
        view.addSubview(mapView)
    }
    
    func addReportToMap(mapView: AnyObject, latitude: Double, longitude: Double) {
        let selectedReportAnnotation = MGLPointAnnotation()
        selectedReportAnnotation.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        mapView.addAnnotation(selectedReportAnnotation)
    }
    
    func loadAllReportsInRegion(mapView: AnyObject) {

        //
        // Send a request to the defined endpoint with the given parameters
        //
        let region = getViewportBoundaryString(mapView.visibleCoordinateBounds)
        let polygon = "SRID=4326;POLYGON((" + region + "))"
        let parameters = [
            "q": "{\"filters\":[{\"name\":\"geometry\",\"op\":\"intersects\",\"val\":\"" + polygon + "\"}],\"   order_by\": [{\"field\":\"report_date\",\"direction\":\"desc\"},{\"field\":\"id\",\"direction\":\"desc\"}]}"
        ]
        
        print("region")
        print(region)
        print("polygon")
        print(polygon)
        print("parameters")
        print(parameters)
        

        Alamofire.request(.GET, Endpoints.GET_MANY_REPORTS, parameters: parameters)
            .responseJSON { response in
                
                switch response.result {
                case .Success(let value):
//                    self.reports = value["features"] as! [AnyObject]
                    
                    print(value)
                    
                case .Failure(let error):
                    print(error)
                    break
                }
                
        }
        
        
    }
    
    func getViewportBoundaryString(boundary: MGLCoordinateBounds) -> String {
        
        print("boundary")
        print(boundary)
        
        let topLeft: String = String(format:"%f %f", boundary.ne.longitude, boundary.sw.latitude)
        let topRight: String = String(format:"%f %f", boundary.ne.longitude, boundary.ne.latitude)
        let bottomRight: String = String(format:"%f %f", boundary.sw.longitude, boundary.ne.latitude)
        let bottomLeft: String = String(format:"%f %f", boundary.sw.longitude, boundary.sw.latitude)

        return [topLeft, topRight, bottomRight, bottomLeft, topLeft].joinWithSeparator(",")
    }
    
    func setCoordinateDefaults() {
        let reportGeometry = reportObject?.objectForKey("geometry")
        let reportGeometries = reportGeometry!.objectForKey("geometries")
        let reportCoordinates = reportGeometries![0].objectForKey("coordinates") as! Array<Double>
        
        reportLongitude = reportCoordinates[0]
        reportLatitude = reportCoordinates[1]
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
