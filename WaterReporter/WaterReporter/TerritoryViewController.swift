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
    var territoryOutline : AnyObject?
    
    var territorySelectedContentType: String! = "Posts"
    
    @IBOutlet weak var territoryContentCollectionView: UICollectionView!

    var territoryContent: JSON?
    var territoryContentRaw = [AnyObject]()
    var territoryContentPage: Int = 1
    var territoryContentRefreshControl: UIRefreshControl = UIRefreshControl()

    var territoryActionContent: JSON?
    var territoryActionContentRaw = [AnyObject]()
    var territoryActionContentPage: Int = 1
    var territoryActionContentRefreshControl: UIRefreshControl = UIRefreshControl()

    var territoryGroupContent: JSON?
    var territoryGroupContentRaw = [AnyObject]()
    var territoryGroupContentPage: Int = 1
    var territoryGroupContentRefreshControl: UIRefreshControl = UIRefreshControl()

    var territoryNewsContent: JSON?
    var territoryNewsContentRaw = [AnyObject]()
    var territoryNewsContentPage: Int = 1
    var territoryNewsContentRefreshControl: UIRefreshControl = UIRefreshControl()

    
    //
    // MARK: @IBOutlet
    //
    @IBOutlet weak var labelTerritoryName: UILabel!
    @IBOutlet weak var buttonTerritoryContentType: UIButton!
    @IBOutlet weak var buttonViewWatershed: UIButton!

    @IBOutlet weak var buttonOverlay: UIButton!
    @IBOutlet weak var mapViewWatershed: MGLMapView!
    @IBOutlet weak var viewMapViewOverlay: UIView!
    
    @IBOutlet weak var activityCollectionView: UICollectionView!
    
    @IBOutlet weak var contentTypeView: UIView!
    @IBOutlet weak var buttonTerritoryActionsContentType: UIButton!
    @IBOutlet weak var buttonTerritoryPostsContentType: UIButton!
    @IBOutlet weak var buttonTerritoryGroupsContentType: UIButton!
    @IBOutlet weak var buttonTerritoryNewsContentType: UIButton!
    //
    // MARK: @IBAction
    //
    @IBAction func openWatershedView(sender: UIButton) {
        
        //
        // Load the activity controller from the storyboard
        //
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        
        let nextViewController = storyBoard.instantiateViewControllerWithIdentifier("TerritorySingleViewController") as! TerritorySingleViewController

        nextViewController.territory = self.territory

        print("openWatershedView \(self.territory)")

        nextViewController.territoryId = self.territoryId
        nextViewController.territoryHUC8Code = self.territoryHUC8Code
        nextViewController.territoryPage = self.territoryPage
        nextViewController.territoryOutline = self.territoryOutline

        nextViewController.territoryContent = self.territoryContent
        nextViewController.territoryContentRaw = self.territoryContentRaw

        self.navigationController?.pushViewController(nextViewController, animated: true)

    }
    
    @IBAction func openSingleReportView(sender: UIButton) {
        
        //
        // Load the activity controller from the storyboard
        //
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        
        let nextViewController = storyBoard.instantiateViewControllerWithIdentifier("ActivityTableViewController") as! ActivityTableViewController
        
        if self.territorySelectedContentType == "Posts" {
            let _report = self.territoryContentRaw[sender.tag]
            nextViewController.singleReport = true
            nextViewController.reports = [_report]
            self.navigationController?.pushViewController(nextViewController, animated: true)
        }
        else if self.territorySelectedContentType == "Actions" {
            let _report = self.territoryActionContentRaw[sender.tag]
            nextViewController.singleReport = true
            nextViewController.reports = [_report]
            self.navigationController?.pushViewController(nextViewController, animated: true)
        }
        else if self.territorySelectedContentType == "News" {
            let _report = self.territoryNewsContentRaw[sender.tag]
            nextViewController.singleReport = true
            nextViewController.reports = [_report]
            self.navigationController?.pushViewController(nextViewController, animated: true)
        }
        
    }

    @IBAction func openSingleGroupView(sender: UIButton) {
        
        let nextViewController = self.storyBoard.instantiateViewControllerWithIdentifier("OrganizationTableViewController") as! OrganizationTableViewController
        
        let _group = self.territoryGroupContent!["features"][sender.tag]

        print("sender.tag \(sender.tag) _group \(_group)")
        
        nextViewController.groupId = "\(_group["id"])"
        nextViewController.groupObject = _group
        
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

            //self.navigationItem.prompt = "\(self.territoryHUC8Code)"
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
        self.attemptLoadTerritoryActions(true)
        self.attemptLoadTerritoryGroups(true)
        
        //
        //
        self.activityCollectionView.dataSource = self
        self.activityCollectionView.delegate = self
        
        self.buttonTerritoryContentType.addTarget(self, action: #selector(TerritoryViewController.toggleMenu(_:)), forControlEvents: .TouchUpInside)
        self.buttonTerritoryPostsContentType.addTarget(self, action: #selector(TerritoryViewController.changeContentType(_:)), forControlEvents: .TouchUpInside)
        self.buttonTerritoryGroupsContentType.addTarget(self, action: #selector(TerritoryViewController.changeContentType(_:)), forControlEvents: .TouchUpInside)
        self.buttonTerritoryActionsContentType.addTarget(self, action: #selector(TerritoryViewController.changeContentType(_:)), forControlEvents: .TouchUpInside)
        
        self.buttonTerritoryContentType.contentHorizontalAlignment = UIControlContentHorizontalAlignment.Left
        
        self.buttonTerritoryPostsContentType.contentHorizontalAlignment = UIControlContentHorizontalAlignment.Left
        self.buttonTerritoryPostsContentType.setTitleColor(UIColor.colorBrand(), forState: .Normal)
        
        self.buttonTerritoryActionsContentType.contentHorizontalAlignment = UIControlContentHorizontalAlignment.Left
        self.buttonTerritoryGroupsContentType.contentHorizontalAlignment = UIControlContentHorizontalAlignment.Left
        self.buttonTerritoryNewsContentType.contentHorizontalAlignment = UIControlContentHorizontalAlignment.Left
        
        self.contentTypeView.layer.shadowColor = UIColor.blackColor().CGColor
        self.contentTypeView.layer.shadowOpacity = 0.25
        self.contentTypeView.layer.shadowOffset = CGSize.init(width: 4, height: 4)
        self.contentTypeView.layer.shadowRadius = 4.0

        self.contentTypeView.layer.cornerRadius = 3.0
        
        self.buttonViewWatershed.backgroundColor = UIColor.whiteColor()
        self.buttonViewWatershed.layer.borderWidth = 1.0
        self.buttonViewWatershed.layer.borderColor = UIColor.colorBrand().CGColor
        
    }
    
    func toggleMenu(sender: UIButton) {
        
        if self.contentTypeView.hidden {
            self.contentTypeView.hidden = false
        }
        else {
            self.contentTypeView.hidden = true
        }
        
    }
    
    func changeContentType(sender: UIButton) {
        print("changeContentType \(sender)")
        
        if sender.restorationIdentifier == "postsButton" {
            self.territorySelectedContentType = "Posts"

            self.buttonTerritoryActionsContentType.setTitleColor(UIColor.darkGrayColor(), forState: .Normal)
            self.buttonTerritoryGroupsContentType.setTitleColor(UIColor.darkGrayColor(), forState: .Normal)
            self.buttonTerritoryNewsContentType.setTitleColor(UIColor.darkGrayColor(), forState: .Normal)
            self.buttonTerritoryPostsContentType.setTitleColor(UIColor.colorBrand(), forState: .Normal)
            
            self.buttonTerritoryContentType.setTitle("\(self.territoryContent!["properties"]["num_results"]) posts in watershed", forState: .Normal)

            self.activityCollectionView.reloadData()
        }
        else if sender.restorationIdentifier == "groupsButton" {
            self.territorySelectedContentType = "Groups"

            self.buttonTerritoryPostsContentType.setTitleColor(UIColor.darkGrayColor(), forState: .Normal)
            self.buttonTerritoryActionsContentType.setTitleColor(UIColor.darkGrayColor(), forState: .Normal)
            self.buttonTerritoryNewsContentType.setTitleColor(UIColor.darkGrayColor(), forState: .Normal)
            self.buttonTerritoryGroupsContentType.setTitleColor(UIColor.colorBrand(), forState: .Normal)

            self.buttonTerritoryContentType.setTitle("\(self.territoryGroupContent!["properties"]["num_results"]) active groups", forState: .Normal)

            self.activityCollectionView.reloadData()
        }
        else if sender.restorationIdentifier == "actionsButton" {
            self.territorySelectedContentType = "Actions"

            self.buttonTerritoryPostsContentType.setTitleColor(UIColor.darkGrayColor(), forState: .Normal)
            self.buttonTerritoryGroupsContentType.setTitleColor(UIColor.darkGrayColor(), forState: .Normal)
            self.buttonTerritoryNewsContentType.setTitleColor(UIColor.darkGrayColor(), forState: .Normal)
            self.buttonTerritoryActionsContentType.setTitleColor(UIColor.colorBrand(), forState: .Normal)

            self.buttonTerritoryContentType.setTitle("\(self.territoryActionContent!["properties"]["num_results"]) posts with actions", forState: .Normal)

            self.activityCollectionView.reloadData()
        }
        else if sender.restorationIdentifier == "newsButton" {
            self.territorySelectedContentType = "News"

            self.buttonTerritoryPostsContentType.setTitleColor(UIColor.darkGrayColor(), forState: .Normal)
            self.buttonTerritoryActionsContentType.setTitleColor(UIColor.darkGrayColor(), forState: .Normal)
            self.buttonTerritoryGroupsContentType.setTitleColor(UIColor.darkGrayColor(), forState: .Normal)
            self.buttonTerritoryNewsContentType.setTitleColor(UIColor.colorBrand(), forState: .Normal)

            self.buttonTerritoryContentType.setTitle("\(self.territoryNewsContent!["properties"]["num_results"]) news stories", forState: .Normal)

            self.activityCollectionView.reloadData()
        }

        self.contentTypeView.hidden = true
        
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
                        
                        // Draw the Territory on the map
                        //
                        let territoryOutline : AnyObject = value
                        self.territoryOutline = territoryOutline
                        
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
        
        print("Polygon::deserializeGeoJSONToMGLPolygon contains \(polygonGeoJSONArray.count) objects and should be displayed as multiple? \(multiple)")
        
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

//        print(":drawTerritoryOnMap \(geoJSONData)")

        var _json: JSON = JSON(geoJSONData)

        // We need to loop over multiple times here to ensure that multi-polygon
        // shapes are being read and displayed properly.
        //
        if _json["features"][0]["geometry"]["coordinates"].count == 1 {

            print("Polygon::Contains \(_json["features"][0]["geometry"]["coordinates"].count) Polygon \(_json["features"][0]["geometry"]["coordinates"][0])")

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

            print("MultiPolygon::Contains \(_json["features"][0]["geometry"]["coordinates"].count) Additional Polygon >>>>> \(_json["features"][0]["geometry"]["coordinates"])")

//            print("This watershed contains \(_json["features"][0]["geometry"]["coordinates"].count) polygons and should be handled differently \(_json["features"])")

            var polygons = [MGLPolygon]()

            for polygon in _json["features"][0]["geometry"]["coordinates"] {
                
                print("Polygon::Contains \(polygon.1.count) Additional Polygon >>>>> \(polygon.1)")
                
                if polygon.1.count == 1 {

                    print("Polygon::Count is 1[\(polygon.1.count)] Appending Polygon \(polygon.1[0])")

                    let _newPolygon: MGLPolygon = self.deserializeGeoJSONToMGLPolygon(polygon.1[0], multiple: false)

                    polygons.append(_newPolygon)
                }
                else if polygon.1.count > 1 {
                    
                    print("Polygon::Count is >1 [\(polygon.1.count)] Recusive >>>>> Polygon")

                    for _child in polygon.1 {
                        
                        print("Polygon::Child is >1 [\(_child.1)] Recusive >>>>> Polygon")

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
            
            self.mapViewWatershed.setVisibleCoordinateBounds(territoryShape.overlayBounds, animated: false)

            // Update zoom level because the .setVisibleCoordinateBounds method
            // has too tight of a crop and leaves no padding around the edges
            //
            let _updatedZoomLevel: Double = self.mapViewWatershed.zoomLevel*0.90
            self.mapViewWatershed.setZoomLevel(_updatedZoomLevel, animated: false)

        }
        
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
                    let _content_count = self.territoryContent!["properties"]["num_results"]
                    
                    if (_content_count != "") {
                        self.buttonTerritoryContentType.hidden = false
                        self.buttonTerritoryContentType.setTitle("\(_content_count) posts in watershed", forState: .Normal)
                        self.buttonTerritoryPostsContentType.setTitle("\(_content_count) posts in watershed", forState: .Normal)
                    }
                    
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

    func attemptLoadTerritoryActions(isRefreshingReportsList: Bool = false) {
        
        let _parameters = [
            "q": "{\"filters\":[{\"name\":\"territory\",\"op\":\"has\",\"val\": {\"name\":\"huc_8_code\",\"op\":\"eq\",\"val\":\"\(self.territoryHUC8Code)\"}},{\"name\":\"state\", \"op\":\"eq\", \"val\":\"closed\"}],\"order_by\": [{\"field\":\"report_date\",\"direction\":\"desc\"},{\"field\":\"id\",\"direction\":\"desc\"}]}",
            "page": "\(self.territoryGroupContentPage)"
        ]
        
        Alamofire.request(.GET, Endpoints.GET_MANY_REPORTS, parameters: _parameters)
            .responseJSON { response in
                
                switch response.result {
                case .Success(let value):
                    print("attemptLoadTerritoryActions::Request Success \(Endpoints.GET_MANY_REPORTS) \(value)")
                    
                    // Assign response to groups variable
                    if (isRefreshingReportsList) {
                        self.territoryActionContent = JSON(value)
                        self.territoryActionContentRaw = value["features"] as! [AnyObject]
                        self.territoryActionContentRefreshControl.endRefreshing()
                    }
                    else {
                        self.territoryActionContent = JSON(value)
                        self.territoryActionContentRaw += value["features"] as! [AnyObject]
                    }
                    
                    // Set visible button count
                    let _action_count = self.territoryActionContent!["properties"]["num_results"]
                    
                    if (_action_count != "") {
                        self.buttonTerritoryActionsContentType.setTitle("\(_action_count) posts with actions", forState: .Normal)
                    }
                    
                    // Refresh the data in the table so the newest items appear
                    self.territoryContentCollectionView.reloadData()
                    
                    self.territoryActionContentPage += 1
                    
                    break
                case .Failure(let error):
                    print("Request Failure: \(error)")
                    
                    // Stop showing the loading indicator
                    //self.status("doneLoadingWithError")
                    
                    break
                }
                
        }
        
    }
    
    func attemptLoadTerritoryGroups(isRefreshingReportsList: Bool = false) {
        
        let _parameters = [
            "q": "{\"filters\":[{\"name\":\"reports\",\"op\":\"any\",\"val\":{\"name\":\"territory\",\"op\":\"has\",\"val\":{\"name\":\"huc_8_code\",\"op\":\"eq\",\"val\":\"\(self.territoryHUC8Code)\"}}}]}",
            "page": "\(self.territoryGroupContentPage)"
        ]
        
        Alamofire.request(.GET, Endpoints.GET_MANY_ORGANIZATIONS, parameters: _parameters)
            .responseJSON { response in
                
                switch response.result {
                case .Success(let value):
                    print("attemptLoadTerritoryGroups::Request Success \(Endpoints.GET_MANY_ORGANIZATIONS) \(value)")
                    
                    // Assign response to groups variable
                    if (isRefreshingReportsList) {
                        self.territoryGroupContent = JSON(value)
                        self.territoryGroupContentRaw = value["features"] as! [AnyObject]
                        self.territoryGroupContentRefreshControl.endRefreshing()
                    }
                    else {
                        self.territoryGroupContent = JSON(value)
                        self.territoryGroupContentRaw += value["features"] as! [AnyObject]
                    }
                    
                    // Set visible button count
                    let _group_count = self.territoryGroupContent!["properties"]["num_results"]
                    
                    if (_group_count >= 1) {
                        self.buttonTerritoryGroupsContentType.setTitle("\(_group_count) active groups", forState: .Normal)
                    }
                    
                    // Refresh the data in the table so the newest items appear
                    self.territoryContentCollectionView.reloadData()
                    
                    self.territoryGroupContentPage += 1
                    
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

        if (self.territorySelectedContentType == "Actions") {
            return self.territoryActionContentRaw.count
        }
        else if (self.territorySelectedContentType == "Groups") {
            return self.territoryGroupContentRaw.count
        }
        else {
            return self.territoryContentRaw.count
        }

    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {

        print("UICollectionView::collectionView::cellForItemAt")

        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("CollectionActivityReportsCollectionViewCell", forIndexPath: indexPath) as! ReusableProfileCollectionViewCell
        
        let _report: JSON!
        let _owner: JSON!
        
        if (self.territorySelectedContentType == "Actions") {
            _report = JSON(self.territoryActionContentRaw[indexPath.row])
            _owner = _report!["properties"]["owner"]
        }
        else if (self.territorySelectedContentType == "Groups") {
            _report = JSON(self.territoryGroupContentRaw[indexPath.row])
            _owner = _report!["properties"]["owner"]
        }
        else {
            _report = JSON(self.territoryContentRaw[indexPath.row])
            _owner = _report!["properties"]["owner"]
        }
        
        // REPORT > USER > First and Last Name
        //
        cell.reportUserProfileName.text = "\(_owner["properties"]["first_name"]) \(_owner["properties"]["last_name"])"
        
        
        // REPORT > USER > Profile Image
        //
        // Display Group Image
        if self.territorySelectedContentType != "Groups" {
            
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

        }
        else {
            cell.reportUserProfileName.text = ""
            cell.reportUserProfileImage.backgroundColor = UIColor.clearColor()
            cell.reportUserProfileImage.image = UIImage()
        }
        
        
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
        if self.territorySelectedContentType != "Groups" {

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
        }
        else {
            cell.reportDate.text = ""
        }
        
        // REPORT > DESCRIPTION
        //
        if self.territorySelectedContentType != "Groups" {

            let reportDescription = "\(_report["properties"]["report_description"])"
            
            if "\(reportDescription)" != "null" || "\(reportDescription)" != "" {
                cell.reportDescription.text = "\(reportDescription)"
            }
            else {
                cell.reportDescription.text = ""
            }
        }
        else if self.territorySelectedContentType == "Groups" {
            
            cell.reportDescription.text = "\(_report["properties"]["name"])"

        }
        else {
            cell.reportDescription.text = ""
        }
        
        
        // REPORT > Link
        //
        if self.territorySelectedContentType == "Groups" {
            
            cell.reportLink.tag = indexPath.row
            
            cell.reportLink.removeTarget(self, action: #selector(TerritoryViewController.openSingleReportView(_:)), forControlEvents: .TouchUpInside)
            cell.reportLink.addTarget(self, action: #selector(TerritoryViewController.openSingleGroupView(_:)), forControlEvents: .TouchUpInside)
            
        }
        else {
            cell.reportLink.tag = indexPath.row
            
            cell.reportLink.removeTarget(self, action: #selector(TerritoryViewController.openSingleGroupView(_:)), forControlEvents: .TouchUpInside)
            cell.reportLink.addTarget(self, action: #selector(TerritoryViewController.openSingleReportView(_:)), forControlEvents: .TouchUpInside)
        }

        
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



