//
//  TerritorySingleViewController.swift
//  Water-Reporter
//
//  Created by Joshua Powell on 7/11/17.
//  Copyright © 2017 Viable Industries, L.L.C. All rights reserved.
//

import Alamofire
import Dispatch
import Foundation
import Mapbox
import SwiftyJSON
import UIKit

class TerritorySingleViewController: UIViewController, MGLMapViewDelegate {
    
    
    //
    // MARK: View-Global Variable
    //
    let mapTesting: Bool = false
    let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
    
    var territory: String = ""
    var territoryId: String = ""
    var territoryHUC8Code: String = ""
    var territoryPage: Int = 1
    var territoryOutline : AnyObject!

    var territoryContent: JSON?
    var territoryContentRaw = [AnyObject]()
    
    var territorySelectedContentType: String! = "Posts"

    
    //
    //
    //
    @IBOutlet weak var mapViewWatershed: MGLMapView!

    
    //
    // MARK: Overrides
    //
    override func viewDidLoad() {
        super.viewDidLoad()

        // Display the Territory (Watershed) name
        //
        if self.territory != "" {
            
            print("Territory Name Available, update the self.labelTerritoryName.text label and the self.navigationItem.title with \(self.territory)")
            
            self.navigationItem.title = "\(self.territory)"
        }
        
        
        // Map View Overrides
        //
        self.mapViewWatershed.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        
        
        // Ensure territory outline was passed from parent view controller.
        // After verification attempt to draw outline.
        //
        if self.territoryOutline != nil {
            self.drawTerritoryOnMap(self.territoryOutline)
        }
        
        if self.territoryContentRaw.count != 0 {
            self.addReportsToMap(self.mapViewWatershed, reports:self.territoryContentRaw)
        }


    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
    }
    
    
    func drawTerritoryOnMap(geoJSONData: AnyObject) {
        
        var _json: JSON = JSON(geoJSONData)

        print("TerritorySingleViewController:drawTerritoryOnMap \(_json)")

        // We need to loop over multiple times here to ensure that multi-polygon
        // shapes are being read and displayed properly.
        //
        if _json["features"][0]["geometry"]["coordinates"].count == 1 {
            
            let territoryShape: MGLPolygon = self.deserializeGeoJSONToMGLPolygon(_json["features"][0]["geometry"]["coordinates"][0])
            
            self.mapViewWatershed.addAnnotation(territoryShape)
            
            self.mapViewWatershed.setVisibleCoordinateBounds(territoryShape.overlayBounds, animated: false)
            
            // Update zoom level because the .setVisibleCoordinateBounds method
            // has too tight of a crop and leaves no padding around the edges
            //
            let _updatedZoomLevel: Double = self.mapViewWatershed.zoomLevel*0.88
            self.mapViewWatershed.setZoomLevel(_updatedZoomLevel, animated: false)
            
        }
        else if _json["features"][0]["geometry"]["coordinates"].count > 1 {
            
            print("This watershed contains \(_json["features"][0]["geometry"]["coordinates"].count) polygons and should be handled differently \(_json["features"])")
            
            var polygons = [MGLPolygon]()
            
            for polygon in _json["features"][0]["geometry"]["coordinates"] {
                
                print("polygon has \(polygon.1.count) inside of it >>>>> \(polygon.1)")
                
                if polygon.1.count == 1 {
                    let _newPolygon: MGLPolygon = self.deserializeGeoJSONToMGLPolygon(_json["features"][0]["geometry"]["coordinates"][0], multiple: true)
                    
                    polygons.append(_newPolygon)
                }
                else if polygon.1.count > 1 {
                    
                    for _child in polygon.1 {
                        
                        print("_child \(_child)")
                        
                        let _newPolygon: MGLPolygon = self.deserializeGeoJSONToMGLPolygon(_child.1, multiple: false)
                        
                        polygons.append(_newPolygon)
                    }
                }
                
            }
            
            print("polygons \(polygons)")
            
            let territoryShape: MGLMultiPolygon = MGLMultiPolygon(polygons: polygons)
            
            for _displayPolygon in polygons {
                
                print("_displayPolygon \(_displayPolygon)")
                
                self.mapViewWatershed.addAnnotation(_displayPolygon)
                
            }
            
            print("territoryShape \(territoryShape.polygons)")
            
            //            self.mapViewWatershed.setVisibleCoordinateBounds(territoryShape.overlayBounds, animated: false)
            
            // Update zoom level because the .setVisibleCoordinateBounds method
            // has too tight of a crop and leaves no padding around the edges
            //
            //            let _updatedZoomLevel: Double = self.mapViewWatershed.zoomLevel*0.90
            //            self.mapViewWatershed.setZoomLevel(_updatedZoomLevel, animated: false)
            
        }
        
        
        ///
        ///
        ///
        ///
        //        var maxLat: Float = -200
        //        var maxLong: Float = -200
        //        var minLat: Float = MAXFLOAT
        //        var minLong: Float = MAXFLOAT
        //
        //        for coordinate in _json["features"][0]["geometry"]["coordinates"][0] {
        //
        //            let _latitude: CLLocationDegrees = CLLocationDegrees(floatLiteral: coordinate.1[1].double!)
        //            let _longitude: CLLocationDegrees = CLLocationDegrees(floatLiteral: coordinate.1[0].double!)
        //
        //            let _location = CLLocationCoordinate2D(latitude: _latitude, longitude: _longitude)
        //
        //            // Find the minLat
        //            //
        //            let _minimumLatitudeString: String = String(minLat)
        //            let _minimumLatitudeDouble: Double = Double(_minimumLatitudeString)!
        //
        //            if _location.latitude < CLLocationDegrees(floatLiteral: _minimumLatitudeDouble) {
        //                minLat = Float(_location.latitude);
        //            }
        //
        //            // Find the minLong
        //            //
        //            let _minimumLongitudeString: String = String(minLong)
        //            let _minimumLongitudeDouble: Double = Double(_minimumLongitudeString)!
        //
        //            if _location.longitude < CLLocationDegrees(floatLiteral: _minimumLongitudeDouble) {
        //                minLong = Float(_location.longitude);
        //            }
        //
        //            // Find the maxLat
        //            //
        //            let _maximumLatitudeString: String = String(maxLat)
        //            let _maximumLatitudeDouble: Double = Double(_maximumLatitudeString)!
        //
        //            if _location.latitude > CLLocationDegrees(floatLiteral: _maximumLatitudeDouble) {
        //                maxLat = Float(_location.latitude);
        //            }
        //
        //            // Find the maxLong
        //            //
        //            let _maximumLongitudeString: String = String(maxLong)
        //            let _maximumLongitudeDouble: Double = Double(_maximumLongitudeString)!
        //
        //            if _location.longitude > CLLocationDegrees(floatLiteral: _maximumLongitudeDouble) {
        //                maxLong = Float(_location.longitude);
        //            }
        //
        //
        //        }
        
        // Define Center Point
        //
        //        let center: CLLocationCoordinate2D = CLLocationCoordinate2DMake((Double(maxLat) + Double(minLat)) * 0.5, (Double(maxLong) + Double(minLong)) * 0.5);
        
        //        self.mapViewWatershed.setCenterCoordinate(center, animated: false)
        
        //        self.mapViewWatershed.setZoomLevel(6.5, animated: false)
        
    }

    func deserializeGeoJSONToMGLPolygon(polygonGeoJSONArray: JSON, multiple: Bool = false) -> MGLPolygon {
        
        var _coordinates = [CLLocationCoordinate2D]()
        
        for coordinate in polygonGeoJSONArray {
            
            if multiple == false {
                let _latitude: CLLocationDegrees = CLLocationDegrees(floatLiteral: coordinate.1[1].double!)
                let _longitude: CLLocationDegrees = CLLocationDegrees(floatLiteral: coordinate.1[0].double!)
                
                let _newVertice = CLLocationCoordinate2D(latitude: _latitude, longitude: _longitude)
                
                _coordinates.append(_newVertice)
            }
            else {
                let _latitude: CLLocationDegrees = CLLocationDegrees(floatLiteral: coordinate.1[0][1].double!)
                let _longitude: CLLocationDegrees = CLLocationDegrees(floatLiteral: coordinate.1[0][0].double!)
                
                let _newVertice = CLLocationCoordinate2D(latitude: _latitude, longitude: _longitude)
                print("coordinate \(coordinate)")
                _coordinates.append(_newVertice)
                
            }
            
        }
        
        let _polygon: MGLPolygon = MGLPolygon(coordinates: &_coordinates, count: UInt(_coordinates.count))
        
        return _polygon
    }

    
    //
    // MARK: Mapbox Overrides
    //
    func mapView(mapView: MGLMapView, alphaForShapeAnnotation annotation: MGLShape) -> CGFloat {
        return 0.25
    }
    
    func mapView(mapView: MGLMapView, lineWidthForPolylineAnnotation annotation: MGLPolyline) -> CGFloat {
        return 3.0
    }
    
    func mapView(mapView: MGLMapView, strokeColorForShapeAnnotation annotation: MGLShape) -> UIColor {
        return UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1)
    }
    
    func mapView(mapView: MGLMapView, fillColorForPolygonAnnotation annotation: MGLPolygon) -> UIColor {
        return UIColor(red: 153/255, green: 46/255, blue: 230/255, alpha: 1)
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
            annotationView!.frame = CGRectMake(0, 0, 5, 5)
            
            // Add a 2px stroke to the pin and color it white
            annotationView!.layer.borderColor = UIColor.whiteColor().CGColor
            annotationView!.layer.borderWidth = 1.0
            
            // Make sure the pin is circle
            annotationView!.layer.cornerRadius = 2.5
            annotationView!.clipsToBounds = true
            
            // Change the pin color
            annotationView?.backgroundColor = UIColor.colorBrand()
            
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
        
        print("Adding annotation to map \(thisAnnotation.title)")
        
        mapView.addAnnotation(thisAnnotation)
        
    }
    
    func addReportsToMap(mapView: AnyObject, reports: NSArray) {
        
        let _reportObject = self.territoryContent
        
        for _report in reports {
            
            let _thisReport = JSON(_report)
            
            if "\(_thisReport["id"])" != "\(_reportObject!["id"])" {
                let _geometry = _thisReport["geometry"]["geometries"][0]["coordinates"]
                
                let reportLongitude = _geometry[0].double
                let reportLatitude = _geometry[1].double
                
                self.addReportToMap(mapView, report: _report, latitude: reportLatitude!, longitude: reportLongitude!, center:false)
            }
            
        }
        
    }

}
