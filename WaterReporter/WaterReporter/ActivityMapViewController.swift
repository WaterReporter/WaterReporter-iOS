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

    var reportObject: AnyObject!
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
    
    func addReportToMap(mapView: AnyObject, report: AnyObject, latitude: Double, longitude: Double, center:Bool) {
        
        let _report = JSON(report)
        let thisAnnotation = MGLPointAnnotation()
        let _title = _report["properties"]["report_description"].string
        var _subtitle: String = "Reported on "
        let _date = "\(_report["properties"]["report_date"])"
        
        thisAnnotation.report = report
        
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
            "q": "{\"filters\":[{\"name\":\"geometry\",\"op\":\"intersects\",\"val\":\"" + polygon + "\"}],\"order_by\": [{\"field\":\"report_date\",\"direction\":\"desc\"},{\"field\":\"id\",\"direction\":\"desc\"}]}"
        ]
        
        print("polygon \(polygon)")
        print("parameters \(parameters)")

        Alamofire.request(.GET, Endpoints.GET_MANY_REPORTS, parameters: parameters)
            .responseJSON { response in
                
                switch response.result {
                case .Success(let value):
                    
                    print("value \(value)")
                    
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
        
        let _reportObject = JSON(self.reportObject)

        for _report in reports {
            
            let _thisReport = JSON(_report)
            
            if "\(_thisReport["id"])" != "\(_reportObject["id"])" {
                let _geometry = _thisReport["geometry"]["geometries"][0]["coordinates"]
                
                reportLongitude = _geometry[0].double
                reportLatitude = _geometry[1].double
                
                self.addReportToMap(mapView, report: _report, latitude: reportLatitude, longitude: reportLongitude, center:false)
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
        let _tempReport = JSON(self.reportObject)
        let reportCoordinates = _tempReport["geometry"]["geometries"][0]["coordinates"]
        
        reportLongitude = reportCoordinates[0].double
        reportLatitude = reportCoordinates[1].double
    }
    
    
    
    //
    // MARK: Mapbox Overrides
    //
    func mapView(mapView: MGLMapView, regionDidChangeAnimated animated: Bool) {
        self.loadAllReportsInRegion(mapView)
    }
    
    func mapView(mapView: MGLMapView, viewForAnnotation annotation: MGLAnnotation) -> MGLAnnotationView? {

        guard annotation is MGLPointAnnotation else {
            return nil
        }
        
        let report = JSON(annotation.report)
        let reuseIdentifier = "report_\(report["id"])"
        
        // For better performance, always try to reuse existing annotations.
        var annotationView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseIdentifier)
        
        if annotationView == nil {

            // Add outline to the Report marker view
            //
            annotationView = MGLAnnotationView(reuseIdentifier: reuseIdentifier)
            annotationView!.frame = CGRectMake(0, 0, 64, 64)
            annotationView?.backgroundColor = UIColor.clearColor()

            // Add Report > Image to the marker view
            //
            let reportImageURL: NSURL = NSURL(string: "\(report["properties"]["images"][0]["properties"]["icon"])")!
            
            let reportImageView = UIImageView()
            var reportImageUpdate: Image?
            reportImageView.frame = CGRect(x: 0, y: 0, width: 64, height: 64)
            
            
            reportImageView.kf_indicatorType = .Activity
            reportImageView.kf_showIndicatorWhenLoading = true
            
            reportImageView.kf_setImageWithURL(reportImageURL, placeholderImage: nil, optionsInfo: nil, progressBlock: nil, completionHandler: {
                (image, error, cacheType, imageUrl) in
                
                reportImageUpdate = Image(CGImage: (image?.CGImage)!, scale: (image?.scale)!, orientation: UIImageOrientation.Up)
                
                reportImageView.image = reportImageUpdate
                reportImageView.layer.cornerRadius = reportImageView.frame.size.width / 2
                reportImageView.clipsToBounds = true
                
                reportImageView.layer.cornerRadius = reportImageView.frame.width / 2
                reportImageView.layer.borderWidth = 4
                reportImageView.layer.borderColor = UIColor.whiteColor().CGColor

            })

            //
            //
            annotationView?.addSubview(reportImageView)
            annotationView?.bringSubviewToFront(reportImageView)

            // If report is closed, at the action marker view
            //
            if "\(report["properties"]["state"])" == "closed" {
                print("show report view closed badge")
                let reportBadgeImageView = UIImageView()
                let reportBadgeImage = UIImage(named: "icon--Badge")!
                reportBadgeImageView.contentMode = .ScaleAspectFill
                
                reportBadgeImageView.image = reportBadgeImage
                
                reportBadgeImageView.frame = CGRect(x: 0, y: 0, width: 24, height: 24)

                annotationView?.addSubview(reportBadgeImageView)
                annotationView?.bringSubviewToFront(reportBadgeImageView)
            }
            else {
                print("hide report closed badge")
            }
            
        }
        
        return annotationView
    }

    func mapView(mapView: MGLMapView, annotationCanShowCallout annotation: MGLAnnotation) -> Bool {
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

}
