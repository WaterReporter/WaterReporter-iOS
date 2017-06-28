//
//  TerritoryViewController.swift
//  Water-Reporter
//
//  Created by Joshua Powell on 6/28/17.
//  Copyright © 2017 Viable Industries, L.L.C. All rights reserved.
//

import Foundation
import Mapbox
import  UIKit

class TerritoryViewController: UIViewController, MGLMapViewDelegate {
    
    
    //
    // MARK: View-Global Variable
    //
    let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
    
    var territory: String = ""
    var territoryId: String = ""
    var territoryHUC8Code: String = ""
    var territoryPage: Int = 1
    
    var territorySelectedContentType: String! = "Posts"
    
    
    //
    // MARK: @IBOutlet
    //
    @IBOutlet weak var labelTerritoryName: UILabel!
    @IBOutlet weak var buttonViewWatershed: UIButton!

    @IBOutlet weak var buttonOverlay: UIButton!
    @IBOutlet weak var mapViewWatershed: MGLMapView!
    @IBOutlet weak var viewMapViewOverlay: UIView!
    
    
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
        self.mapViewWatershed.setCenterCoordinate(CLLocationCoordinate2D(latitude: 45.520486, longitude: -122.673541), animated: false)
        self.mapViewWatershed.setZoomLevel(11.0, animated: false)
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
        
        // Draw the Territory (Watershed) boundary
        //
        self.mapViewDrawBoundary(self.mapViewWatershed)
    }
    
    
    //
    //
    //
    func mapViewDrawBoundary(mapView: MGLMapView) {
        
        // Create a coordinates array to hold all of the coordinates for our shape.
        var coordinates = [
            CLLocationCoordinate2D(latitude: 45.522585, longitude: -122.685699),
            CLLocationCoordinate2D(latitude: 45.530883, longitude: -122.678833),
            CLLocationCoordinate2D(latitude: 45.530643, longitude: -122.660121),
            CLLocationCoordinate2D(latitude: 45.521743, longitude: -122.659091),
            CLLocationCoordinate2D(latitude: 45.515008, longitude: -122.664070),
            CLLocationCoordinate2D(latitude: 45.515369, longitude: -122.678489),
            CLLocationCoordinate2D(latitude: 45.522585, longitude: -122.685699)
        ]
        
        let shape = MGLPolygon(coordinates: &coordinates, count: UInt(coordinates.count))
        
        
        
        mapView.addAnnotation(shape)
    
    }

    
    //
    // MARK: Mapbox Overrides
    //  

    func mapView(mapView: MGLMapView, alphaForShapeAnnotation annotation: MGLShape) -> CGFloat {
        return 0.5
    }
    
    func mapView(mapView: MGLMapView, lineWidthForPolylineAnnotation annotation: MGLPolyline) -> CGFloat {
        return 3.0
    }
    
    func mapView(mapView: MGLMapView, strokeColorForShapeAnnotation annotation: MGLShape) -> UIColor {
        return UIColor.whiteColor()
    }
    
    func mapView(mapView: MGLMapView, fillColorForPolygonAnnotation annotation: MGLPolygon) -> UIColor {
        return UIColor(red: 59/255, green: 178/255, blue: 208/255, alpha: 1)
    }
}
