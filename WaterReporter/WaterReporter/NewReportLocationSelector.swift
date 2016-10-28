//
//  NewReportLocationSelector.swift
//  Water-Reporter
//
//  Created by Viable Industries on 10/28/16.
//  Copyright © 2016 Viable Industries, L.L.C. All rights reserved.
//

import Foundation
import Mapbox
import UIKit

protocol NewReportLocationSelectorDelegate {
    func sendCoordinates(coordinates : CLLocationCoordinate2D)
}

class NewReportLocationSelector: UIViewController, MGLMapViewDelegate, UINavigationControllerDelegate, CLLocationManagerDelegate {
    
    var delegate: NewReportLocationSelectorDelegate?
    
    @IBOutlet weak var mapReportLocation: MGLMapView!
    @IBOutlet weak var mapCenterPoint: UIImageView!
    
    var userSelectedCoordinates: CLLocationCoordinate2D!
    
    @IBOutlet weak var navigationBarButtonCancel: UIBarButtonItem!
    @IBOutlet weak var navigationBarButtonSet: UIBarButtonItem!
    
    var mapView: MGLMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupMap()
        
        self.navigationBarButtonCancel.target = self
        self.navigationBarButtonCancel.action = #selector(NewReportLocationSelector.dismissLocationSelector(_:))

        self.navigationBarButtonSet.target = self
        self.navigationBarButtonSet.action = #selector(NewReportLocationSelector.setLocationSelector(_:))
}
    
    func setupMap() {

        self.mapView = mapReportLocation

        self.mapView.styleURL = NSURL(string: "mapbox://styles/rdawes1/circfufio0013h4nlhibdw240")
        self.mapView.setUserTrackingMode(MGLUserTrackingMode.Follow, animated: true)
        
    }
    
    func dismissLocationSelector(sender: UIBarButtonItem) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func setLocationSelector(sender: UIBarButtonItem) {
        self.dismissViewControllerAnimated(true, completion: {
            // pass variables???
        })
    }
    
    func mapView(mapView: MGLMapView, regionDidChangeAnimated animated: Bool) {
        print("CHILD:sendCoordinates see \(self.mapView.centerCoordinate)")

        self.userSelectedCoordinates = self.mapView.centerCoordinate
        
        if let del = delegate {
            del.sendCoordinates(self.userSelectedCoordinates)
        }
    }
    
}
