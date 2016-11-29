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
    func onSetCoordinatesComplete(isFinished: Bool)
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
        
        self.mapView = mapReportLocation
        
        self.navigationBarButtonCancel.target = self
        self.navigationBarButtonCancel.action = #selector(NewReportLocationSelector.dismissLocationSelector(_:))
        self.navigationBarButtonCancel.enabled = true

        self.navigationBarButtonSet.target = self
        self.navigationBarButtonSet.action = #selector(NewReportLocationSelector.setLocationSelector(_:))
        self.navigationBarButtonSet.enabled = false

    }
    
    func mapViewDidFinishLoadingMap(mapView: MGLMapView) {
        
        self.mapView.showsUserLocation = true
        self.mapView.setUserTrackingMode(MGLUserTrackingMode.Follow, animated: true)
        
    }
    
    func dismissLocationSelector(sender: UIBarButtonItem) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func setLocationSelector(sender: UIBarButtonItem) {
        self.dismissViewControllerAnimated(true, completion: {
            if let del = self.delegate {
                del.onSetCoordinatesComplete(true)
            }
        })
    }
    
    func mapView(mapView: MGLMapView, regionDidChangeAnimated animated: Bool) {
        print("CHILD:sendCoordinates see \(self.mapView.centerCoordinate)")

        self.userSelectedCoordinates = self.mapView.centerCoordinate
        
        if (self.userSelectedCoordinates.longitude != 0.0 && self.userSelectedCoordinates.latitude != 0.0) {
            self.navigationBarButtonSet.enabled = true
        }
        
        if let del = delegate {
            del.sendCoordinates(self.userSelectedCoordinates)
        }
    }
   
}
