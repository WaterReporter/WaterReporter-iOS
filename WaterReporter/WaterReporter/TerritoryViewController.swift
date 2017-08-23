//
//  TerritoryViewController.swift
//  Water-Reporter
//
//  Created by Joshua Powell on 6/28/17.
//  Copyright © 2017 Viable Industries, L.L.C. All rights reserved.
//

import Alamofire
import Dispatch
import Foundation
import Mapbox
import SwiftyJSON
import UIKit

class TerritoryViewController: UIViewController, MGLMapViewDelegate, UICollectionViewDelegate, UICollectionViewDataSource {
    
    
    //
    // MARK: View-Global Variable
    //
    let mapTesting: Bool = false
    let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
    
    var territory: String = ""
    var territoryId: String = ""
    var territoryHUC8Code: String = ""
    var territoryPage: Int = 1
    var territorySubmissionsPage: Int = 1
    
    var territorySelectedContentType: String! = "Posts"
    
    
    //
    // MARK: @IBOutlet
    //
    @IBOutlet weak var labelTerritoryName: UILabel!
    @IBOutlet weak var buttonViewWatershed: UIButton!

    @IBOutlet weak var buttonOverlay: UIButton!
    @IBOutlet weak var mapViewWatershed: MGLMapView!
    @IBOutlet weak var viewMapViewOverlay: UIView!
    
    @IBOutlet weak var activityCollectionView: UICollectionView!
    
    //
    // MARK: @IBAction
    //
    @IBAction func openWatershedView(sender: UIButton) {
        
        let _territory = "\(self.territory)"
        
        print("openWatershedView \(_territory)")
    }
    
    
    //
    // MARK: Overrides
    //
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // TEMPORARY REMOVE!!!!
        //
        if mapTesting == true {
            self.buttonOverlay.hidden = true
            self.buttonOverlay.enabled = false
            
            self.viewMapViewOverlay.hidden = true
        }
        
        // Display the Territory (Watershed) name
        //
        if self.territory != "" {
            
            print("Territory Name Available, update the self.labelTerritoryName.text label and the self.navigationItem.title with \(self.territory)")
            
            self.labelTerritoryName.text = "\(self.territory)"
            self.navigationItem.title = "\(self.territory)"
        }
        
        // Display the Territory's (Watershed) related geographic ID (HUC 8 
        // Code)
        //
        if self.territoryHUC8Code != "" {

            print("Territory Geographic ID Available, update the self.navigationItem.prompt label with \(self.territoryHUC8Code)")

            self.navigationItem.prompt = "\(self.territoryHUC8Code)"
        }
        
        // Apply the background gradient to the viewMapViewOverlay
        //
        if (self.viewMapViewOverlay != nil) {
            
            let color : UIColor = UIColor.whiteColor()
            
            let gradient:CAGradientLayer = CAGradientLayer()
            gradient.frame.size = self.viewMapViewOverlay.frame.size
            gradient.colors = [color.colorWithAlphaComponent(0).CGColor, color.CGColor]

            self.viewMapViewOverlay.layer.addSublayer(gradient)

        }
        
        // Map View Overrides
        //
        self.mapViewWatershed.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        
        //
        //
        self.loadTerritoryData()
        self.attemptLoadTerritorySubmissions(true)
        
        //
        //
        self.activityCollectionView.dataSource = self
        self.activityCollectionView.delegate = self
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "showTerritorySingleViewFromMap" ||
           segue.identifier == "showTerritorySingleViewFromButton" {
            let destViewController = segue.destinationViewController as! TerritorySingleViewController
            
            destViewController.territory = self.territory
            destViewController.territoryId = self.territoryId
            destViewController.territoryPage = self.territoryPage
            destViewController.territoryHUC8Code = territoryHUC8Code
            destViewController.territorySelectedContentType = self.territorySelectedContentType
            
        }
    }

    
    
    //
    //
    //
//    func mapViewDrawBoundary(mapView: MGLMapView) {
//        
//        
//        
//        
//        mapView.addAnnotation(shape)
//    
//    }

    
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
        return UIColor.whiteColor()
    }
    
    func mapView(mapView: MGLMapView, fillColorForPolygonAnnotation annotation: MGLPolygon) -> UIColor {
        return UIColor(red: 153/255, green: 46/255, blue: 230/255, alpha: 1)
    }

    func mapView(mapView: MGLMapView, strokeColorForPolygonAnnotation annotation: MGLPolygon) -> UIColor {
        return UIColor(red: 255/255, green: 0/255, blue: 0/255, alpha: 1)
    }

    func mapViewDidFinishLoadingMap(mapView: MGLMapView) {
        print("mapView::mapViewDidFinishLoadingMap")
    }
    
    //
    //
    //
    func loadTerritoryData() {
        
        // Double check to make sure we have a HUC 8 Code
        //
        if self.territoryHUC8Code == "" {
            return;
        }

        if self.territoryHUC8Code.characters.count == 7 {
            self.territoryHUC8Code = "0\(self.territoryHUC8Code)"
        }

        let _endpoint = "\(Endpoints.TERRITORY)\(self.territoryHUC8Code).json"
        
        Alamofire.request(.GET, _endpoint)
            .responseJSON { response in
                
                switch response.result {
                    case .Success(let value):
                        print("loadTerritoryData::Request Success \(Endpoints.TERRITORY) \(value)")
                        
                        // Draw the Territory on the map
                        //
                        let territoryOutline : AnyObject = value
                        
                        self.drawTerritoryOnMap(territoryOutline)
                        
                        break
                    case .Failure(let error):
                        print("Request Failure: \(error)")
                        
                        // Stop showing the loading indicator
                        //self.status("doneLoadingWithError")
                        
                        break
                }
                
        }

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
    
    func drawTerritoryOnMap(geoJSONData: AnyObject) {

        print(":drawTerritoryOnMap \(geoJSONData)")
        
        var _json: JSON = JSON(geoJSONData)
        
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
            let _updatedZoomLevel: Double = self.mapViewWatershed.zoomLevel*0.90
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

    
    //
    // MARK: HTTP Request/Response functionality
    //
    func buildRequestHeaders() -> [String: String] {
        
        let accessToken = NSUserDefaults.standardUserDefaults().objectForKey("currentUserAccountAccessToken")
        
        return [
            "Authorization": "Bearer " + (accessToken! as! String)
        ]
    }
    
    func attemptLoadTerritorySubmissions(isRefreshingReportsList: Bool = false) {
        
        let _parameters = [
            "q": "{\"filters\":[{\"name\":\"territory\",\"op\":\"has\",\"val\": {\"name\":\"huc_8_code\",\"op\":\"eq\",\"val\":\"\(self.territoryHUC8Code)\"}}],\"order_by\": [{\"field\":\"report_date\",\"direction\":\"desc\"},{\"field\":\"id\",\"direction\":\"desc\"}]}",
            "page": "\(self.territorySubmissionsPage)"
        ]
        
        print("_parameters \(_parameters)")
        
        Alamofire.request(.GET, Endpoints.GET_MANY_REPORTS, parameters: _parameters)
            .responseJSON { response in
                
                switch response.result {
                case .Success(let value):
                    print("attemptLoadTerritorySubmissions::Request Success \(Endpoints.GET_MANY_REPORTS) \(value)")
                    
//                    // Assign response to groups variable
//                    if (isRefreshingReportsList) {
//                        self.territorySubmissions = JSON(value)
//                        self.territorySubmissionsObjects = value["features"] as! [AnyObject]
//                        self.territorySubmissionsRefreshControl.endRefreshing()
//                    }
//                    else {
//                        self.territorySubmissions = JSON(value)
//                        self.territorySubmissionsObjects += value["features"] as! [AnyObject]
//                    }
//                    
//                    // Set visible button count
//                    let _submission_count = self.territorySubmissions!["properties"]["num_results"]
//                    
//                    if (_submission_count != "") {
//                        self.territorySubmissionsCount.setTitle("\(_submission_count)", forState: .Normal)
//                    }
                    
                    // Refresh the data in the table so the newest items appear
//                    self.tableView.reloadData()
                    
//                    self.territorySubmissionsPage += 1
                    
                    break
                case .Failure(let error):
                    print("Request Failure: \(error)")
                    
                    // Stop showing the loading indicator
                    //self.status("doneLoadingWithError")
                    
                    break
                }
                
        }
        
    }

    
    //
    // MARK: UICollectionView Overrides
    //
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        print("UICollectionView::numberOfSections")
        return 1
    }

    func collectionView(collectionView: UICollectionView,
                                   numberOfItemsInSection section: Int) -> Int {
        print("UICollectionView::collectionView::numberOfItemsInSection")
        return 4
    }
    
    //3
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {

        print("UICollectionView::collectionView::cellForItemAt")

        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("CollectionActivityReportsCollectionViewCell", forIndexPath: indexPath)

        return cell
    }

}


