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
    var territoryOutline : AnyObject?

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
        
        // Display the Territory's (Watershed) related geographic ID (HUC 8
        // Code)
        //
        if self.territoryHUC8Code != "" {
            
            print("Territory Geographic ID Available, update the self.navigationItem.prompt label with \(self.territoryHUC8Code)")
            
            self.navigationItem.prompt = "\(self.territoryHUC8Code)"
        }
        
        //        self.drawTerritoryOnMap(self.territoryOutline!)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
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

}
