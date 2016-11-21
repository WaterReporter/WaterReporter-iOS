//
//  ActivityMapViewController.swift
//  WaterReporter
//
//  Created by Viable Industries on 8/1/16.
//  Copyright © 2016 Viable Industries, L.L.C. All rights reserved.
//

import Alamofire
import Foundation
import Kingfisher
import Mapbox
import SwiftyJSON
import UIKit

class ActivityMapViewController: UIViewController, MGLMapViewDelegate {
    
    var reports = [AnyObject]() // THIS NEEDS TO BE A SET NOT AN ARRAY

    var reportObject: JSON!
    var reportLongitude:Double!
    var reportLatitude:Double!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        let styleURL = NSURL(string: "mapbox://styles/rdawes1/circfufio0013h4nlhibdw240")
        let mapView = MGLMapView(frame: view.bounds, styleURL:styleURL)
        
        mapView.delegate = self

        mapView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        mapView.setCenterCoordinate(CLLocationCoordinate2D(latitude: reportLatitude, longitude: reportLongitude), zoomLevel: 15, animated: false)
        
        //
        // Add default center pin to the map
        //
        self.addReportToMap(mapView, report: reportObject, latitude: reportLatitude, longitude: reportLongitude, center:true)
        
        //
        // Load additional region based pins
        //
        self.loadAllReportsInRegion(mapView)
        
        //
        // Add map to subview
        //
        view.addSubview(mapView)
    }
    
    func addReportToMap(mapView: AnyObject, report: JSON, latitude: Double, longitude: Double, center:Bool) {
        
        let thisAnnotation = MGLPointAnnotation()
        let _title = report["properties"]["report_description"].string
        var _subtitle: String = "Reported on "
        let _date = "\(report["properties"]["report_date"])"
        
        thisAnnotation.report = report as! AnyObject
        
        let dateString = _date
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        
        let stringToFormat = dateFormatter.dateFromString(dateString)
        dateFormatter.dateFormat = "MMM d, yyyy"
        
        let displayDate = dateFormatter.stringFromDate(stringToFormat!)
        
        if let thisDisplayDate: String? = displayDate {
            _subtitle += thisDisplayDate!
        }

        
        thisAnnotation.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        
        thisAnnotation.title = _title
        thisAnnotation.subtitle = _subtitle
        
        mapView.addAnnotation(thisAnnotation)
        
        if center {
            // Center the map on the annotation.
            mapView.setCenterCoordinate(thisAnnotation.coordinate, zoomLevel: 15, animated: false)
            
            // Pop-up the callout view.
            mapView.selectAnnotation(thisAnnotation, animated: true)
        }
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

        Alamofire.request(.GET, Endpoints.GET_MANY_REPORTS, parameters: parameters)
            .responseJSON { response in
                
                switch response.result {
                case .Success(let value):
                    
                    let returnValue = value["features"] as! [AnyObject]
                    self.reports = returnValue // WE NEED TO FILTER DOWN SO THERE ARE NO DUPLICATE REPORTS LOADED ONTO THE MAP
                    self.addReportsToMap(mapView, reports:self.reports)
                    
                case .Failure(let error):
                    print(error)
                    break
                }
        }
        
        
    }
    
    func addReportsToMap(mapView: AnyObject, reports: NSArray) {
        
        for _report in reports {
            
            if _report.objectForKey("id")?.string != self.reportObject["id"].string {
                let reportGeometry = _report.objectForKey("geometry")
                let reportGeometries = reportGeometry!.objectForKey("geometries")
                let reportCoordinates = reportGeometries![0].objectForKey("coordinates") as! Array<Double>
                
                reportLongitude = reportCoordinates[0]
                reportLatitude = reportCoordinates[1]
                
                self.addReportToMap(mapView, report: JSON(_report), latitude: reportCoordinates[1], longitude: reportCoordinates[0], center:false)
                print("report added")
            } else {
                print("report skipped")
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
        let reportCoordinates = self.reportObject["geometry"]["geometries"][0]["coordinates"]
        
        reportLongitude = reportCoordinates[0].double
        reportLatitude = reportCoordinates[1].double
    }
    
    func mapView(mapView: MGLMapView, viewForAnnotation annotation: MGLAnnotation) -> MGLAnnotationView? {
        return nil
    }
    
    // Allow callout view to appear when an annotation is tapped.
    func mapView(mapView: MGLMapView, annotationCanShowCallout annotation: MGLAnnotation) -> Bool {
        print("annotation tapped")
        return true
    }
    
    func mapView(mapView: MGLMapView, rightCalloutAccessoryViewForAnnotation annotation: MGLAnnotation) -> UIView? {
        
        let annotationButton: UIButton = UIButton(type: .DetailDisclosure)
        
        return annotationButton
    }
    
    func mapView(mapView: MGLMapView, annotation: MGLAnnotation, calloutAccessoryControlTapped control: UIControl) {
        
        //
        // Hide the pop up
        //
        mapView.deselectAnnotation(annotation, animated: false)
        
        //
        // Load the activity controller from the storyboard
        //
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        
        let nextViewController = storyBoard.instantiateViewControllerWithIdentifier("ActivityTableViewController") as! ActivityTableViewController
        
        nextViewController.singleReport = true
        nextViewController.reports = [annotation.report]

        self.navigationController?.pushViewController(nextViewController, animated: true)
    }
    
    func mapView(mapView: MGLMapView, regionDidChangeAnimated animated: Bool) {
        self.loadAllReportsInRegion(mapView)
    }
    
    func mapView(mapView: MGLMapView, imageForAnnotation annotation: MGLAnnotation) -> MGLAnnotationImage? {
        // Try to reuse the existing ‘pisa’ annotation image, if it exists.
        var annotationImage = mapView.dequeueReusableAnnotationImageWithIdentifier("pisa")
        
        if annotationImage == nil {
            
            let report = JSON(annotation.report)
            
            print("report>properties \(report["properties"]["images"][0]["properties"]["icon"].string)")
            
            if let reportImageUrl = report["properties"]["images"][0]["properties"]["icon"].string {
                
                let image = NSURL(string: reportImageUrl)
                    .flatMap { NSData(contentsOfURL: $0) }
                    .flatMap { UIImage(data: $0) }
                
                annotationImage = MGLAnnotationImage(image: image!, reuseIdentifier: "pisa")
                
                
//                KingfisherManager.sharedManager.retrieveImageWithURL(reportImageUrl, optionsInfo: nil, progressBlock: nil, completionHandler: { (image, error, cacheType, imageURL) -> () in
//                    print(image)
//                    annotationImage = MGLAnnotationImage(image: image!, reuseIdentifier: report["properties"]["images"][0]["properties"]["thumbnail"].string!)
//                })
            } else {
                let image = UIImage(named: "Icon--ReportPin")
                
                annotationImage = MGLAnnotationImage(image: image!, reuseIdentifier: "pisa")
            }
            
        }
        
        return annotationImage
    }
    
}
