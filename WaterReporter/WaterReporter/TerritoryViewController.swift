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
    
    var territorySelectedContentType: String! = "Posts"
    
    @IBOutlet weak var territoryContentCollectionView: UICollectionView!
    var territoryContent: JSON?
    var territoryContentRaw = [AnyObject]()
    var territoryContentPage: Int = 1
    var territoryContentRefreshControl: UIRefreshControl = UIRefreshControl()

    
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
    
    @IBAction func openSingleReportView(sender: UIButton) {
        
        //
        // Load the activity controller from the storyboard
        //
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        
        let nextViewController = storyBoard.instantiateViewControllerWithIdentifier("ActivityTableViewController") as! ActivityTableViewController
        
        nextViewController.singleReport = true
        nextViewController.reports = [self.territoryContentRaw[sender.tag]]
        
        self.navigationController?.pushViewController(nextViewController, animated: true)

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
    
//    func mapView(mapView: MGLMapView, lineWidthForPolygonAnnotation annotation: MGLPolyline) -> CGFloat {
//        return 2.0
//    }
//
//    func mapView(mapView: MGLMapView, strokeWidthForShapeAnnotation annotation: MGLShape) -> CGFloat {
//        return 2.0
//    }
//
//    func mapView(mapView: MGLMapView, strokeWidthForPolygonAnnotation annotation: MGLShape) -> CGFloat {
//        return 2.0
//    }
//    
//    func mapView(mapView: MGLMapView, strokeColorForPolygonAnnotation annotation: MGLPolygon) -> UIColor {
//        return UIColor(red: 255/255, green: 0/255, blue: 0/255, alpha: 1)
//    }

    func mapView(mapView: MGLMapView, strokeColorForShapeAnnotation annotation: MGLShape) -> UIColor {
        return UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1)
    }
    
    func mapView(mapView: MGLMapView, fillColorForPolygonAnnotation annotation: MGLPolygon) -> UIColor {
        return UIColor(red: 153/255, green: 46/255, blue: 230/255, alpha: 1)
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

    func mapView(_ mapView: MGLMapView, didFinishLoading style: MGLStyle) {
    
        let source = MGLVectorSource(identifier: "drone-restrictions", configurationURL: URL(string: "mapbox://examples.0cd7imtl")!)
        style.addSource(source)
        
        let layer = MGLLineStyleLayer(identifier: "drone-restrictions-style", source: source)
        

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
            "page": "\(self.territoryContentPage)",
            "results_per_page": "100"
        ]
        
        print("_parameters \(_parameters)")
        
        Alamofire.request(.GET, Endpoints.GET_MANY_REPORTS, parameters: _parameters)
            .responseJSON { response in
                
                switch response.result {
                case .Success(let value):
                    print("attemptLoadTerritorySubmissions::Request Success \(Endpoints.GET_MANY_REPORTS) \(value)")
                    
                    // Assign response to groups variable
                    if (isRefreshingReportsList) {
                        self.territoryContent = JSON(value)
                        self.territoryContentRaw = value["features"] as! [AnyObject]
                        self.territoryContentRefreshControl.endRefreshing()
                    }
                    else {
                        self.territoryContent = JSON(value)
                        self.territoryContentRaw += value["features"] as! [AnyObject]
                    }
                    
                    self.addReportsToMap(self.mapViewWatershed, reports:self.territoryContentRaw)

                    // Set visible button count
//                    let _content_count = self.territorySubmissions!["properties"]["num_results"]
                    
//                    if (_submission_count != "") {
//                        self.territorySubmissionsCount.setTitle("\(_content_count)", forState: .Normal)
//                    }
                    
                    // Refresh the data in the table so the newest items appear
                    self.territoryContentCollectionView.reloadData()
                    
                    self.territoryContentPage += 1
                    
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
        return self.territoryContentRaw.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {

        print("UICollectionView::collectionView::cellForItemAt")

        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("CollectionActivityReportsCollectionViewCell", forIndexPath: indexPath) as! ReusableProfileCollectionViewCell
        
        let _report = JSON(self.territoryContentRaw[indexPath.row])
        let _owner = _report["properties"]["owner"]
        
        print("Processing _report \(_report)")
        
        // REPORT > USER > First and Last Name
        //
        cell.reportUserProfileName.text = "\(_owner["properties"]["first_name"]) \(_owner["properties"]["first_name"])"
        
        
        // REPORT > USER > Profile Image
        //
        // Display Group Image
        var userProfileImageURL:NSURL! = NSURL(string: "https://www.waterreporter.org/community/images/badget--MissingUser.png")
        
        if let userProfileImageString = _owner["properties"]["picture"].string {
            userProfileImageURL = NSURL(string: String(userProfileImageString))
        }
        
        cell.reportUserProfileImage.kf_indicatorType = .Activity
        cell.reportUserProfileImage.kf_showIndicatorWhenLoading = true
        
        cell.reportUserProfileImage.kf_setImageWithURL(userProfileImageURL, placeholderImage: nil, optionsInfo: nil, progressBlock: nil, completionHandler: {
            (image, error, cacheType, imageUrl) in
            if (image != nil) {
                cell.reportUserProfileImage.image = UIImage(CGImage: (image?.CGImage)!, scale: (image?.scale)!, orientation: UIImageOrientation.Up)
            }
        })
        
        cell.reportUserProfileImage.layer.cornerRadius = 8.0
        cell.reportUserProfileImage.clipsToBounds = true
        
        
        // REPORT > IMAGE
        //
        var reportImageURL:NSURL!
        
        if let thisReportImageURL = _report["properties"]["images"][0]["properties"]["square"].string {
            reportImageURL = NSURL(string: String(thisReportImageURL))
        }
        
        cell.reportImage.kf_indicatorType = .Activity
        cell.reportImage.kf_showIndicatorWhenLoading = true
        
        cell.reportImage.kf_setImageWithURL(reportImageURL, placeholderImage: nil, optionsInfo: nil, progressBlock: nil, completionHandler: {
            (image, error, cacheType, imageUrl) in
            
            if (image != nil) {
                cell.reportImage.image = UIImage(CGImage: (image?.CGImage)!, scale: (image?.scale)!, orientation: UIImageOrientation.Up)
            }
        })
        
        
        // REPORT > DATE
        //
        let reportDate = _report["properties"]["report_date"].string
        
        if (reportDate != nil) {
            let dateString: String = reportDate!
            
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
            
            let stringToFormat = dateFormatter.dateFromString(dateString)
            dateFormatter.dateFormat = "MMM d, yyyy"
            
            let displayDate = dateFormatter.stringFromDate(stringToFormat!)
            
            if let thisDisplayDate: String? = displayDate {
                cell.reportDate.text = thisDisplayDate
            }
        }
        else {
            cell.reportDate.text = ""
        }
        
        
        // REPORT > DESCRIPTION
        //
        let reportDescription = "\(_report["properties"]["report_description"])"
        
        if "\(reportDescription)" != "null" || "\(reportDescription)" != "" {
            cell.reportDescription.text = "\(reportDescription)"
        }
        else {
            cell.reportDescription.text = ""
        }
        
        
        // REPORT > Link
        //
        cell.reportLink.tag = indexPath.row
        
        cell.reportLink.addTarget(self, action: #selector(TerritoryViewController.openSingleReportView(_:)), forControlEvents: .TouchUpInside)

        if (indexPath.row == self.territoryContentRaw.count - 2 && self.territoryContentRaw.count < self.territoryContent!["properties"]["num_results"].int) {
            self.attemptLoadTerritorySubmissions()
        }

        return cell
    }

    
    //
    // MARK: Mapbox Map
    //
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
            
//            // Add Report > Image to the marker view
//            //
//            let reportImageURL: NSURL = NSURL(string: "\(report["properties"]["images"][0]["properties"]["icon"])")!
//            
//            let reportImageView = UIImageView()
//            var reportImageUpdate: Image?
//            reportImageView.frame = CGRect(x: 0, y: 0, width: 64, height: 64)
//            
//            
//            reportImageView.kf_indicatorType = .Activity
//            reportImageView.kf_showIndicatorWhenLoading = true
//            
//            reportImageView.kf_setImageWithURL(reportImageURL, placeholderImage: nil, optionsInfo: nil, progressBlock: nil, completionHandler: {
//                (image, error, cacheType, imageUrl) in
//                
//                reportImageUpdate = Image(CGImage: (image?.CGImage)!, scale: (image?.scale)!, orientation: UIImageOrientation.Up)
//                
//                reportImageView.image = reportImageUpdate
//                reportImageView.layer.cornerRadius = reportImageView.frame.size.width / 2
//                reportImageView.clipsToBounds = true
//                
//                reportImageView.layer.cornerRadius = reportImageView.frame.width / 2
//                reportImageView.layer.borderWidth = 4
//                reportImageView.layer.borderColor = UIColor.whiteColor().CGColor
//                
//            })
            
            //
            //
//            annotationView?.addSubview(reportImageView)
//            annotationView?.bringSubviewToFront(reportImageView)
            
            // If report is closed, at the action marker view
            //
//            if "\(report["properties"]["state"])" == "closed" {
//                print("show report view closed badge")
//                let reportBadgeImageView = UIImageView()
//                let reportBadgeImage = UIImage(named: "icon--Badge")!
//                reportBadgeImageView.contentMode = .ScaleAspectFill
//                
//                reportBadgeImageView.image = reportBadgeImage
//                
//                reportBadgeImageView.frame = CGRect(x: 0, y: 0, width: 24, height: 24)
//                
//                annotationView?.addSubview(reportBadgeImageView)
//                annotationView?.bringSubviewToFront(reportBadgeImageView)
//            }
//            else {
//                print("hide report closed badge")
//            }
            
        }
        
        return annotationView
    }
    
    func mapView(mapView: MGLMapView, annotationCanShowCallout annotation: MGLAnnotation) -> Bool {
        return false
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
                    
                    self.territoryContentRaw = returnValue // WE NEED TO FILTER DOWN SO THERE ARE NO DUPLICATE REPORTS LOADED ONTO THE MAP
                    self.addReportsToMap(mapView, reports:self.territoryContentRaw)
                    
                case .Failure(let error):
                    print(error)
                    break
                }
        }
        
        
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
    
    func getViewportBoundaryString(boundary: MGLCoordinateBounds) -> String {
        
        print("boundary")
        print(boundary)
        
        let topLeft: String = String(format:"%f %f", boundary.ne.longitude, boundary.sw.latitude)
        let topRight: String = String(format:"%f %f", boundary.ne.longitude, boundary.ne.latitude)
        let bottomRight: String = String(format:"%f %f", boundary.sw.longitude, boundary.ne.latitude)
        let bottomLeft: String = String(format:"%f %f", boundary.sw.longitude, boundary.sw.latitude)
        
        return [topLeft, topRight, bottomRight, bottomLeft, topLeft].joinWithSeparator(",")
    }

}



