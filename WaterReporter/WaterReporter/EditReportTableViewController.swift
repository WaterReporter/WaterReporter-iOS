//
//  EditReportTableViewController.swift
//  WaterReporter
//
//  Created by Viable Industries on 7/24/16.
//  Copyright © 2016 Viable Industries, L.L.C. All rights reserved.
//

import Alamofire
import CoreLocation
import Mapbox
import SwiftyJSON
import UIKit

class EditReportTableViewController: UITableViewController, UINavigationControllerDelegate, CLLocationManagerDelegate, MGLMapViewDelegate, NewReportLocationSelectorDelegate, NewReportGroupSelectorDelegate {
    
    
    //
    // MARK: @IBOutlets
    //
    @IBOutlet weak var textareaReportComment: UITextView!
    
    @IBOutlet weak var navigationBarButtonSave: UIBarButtonItem!
    
    @IBOutlet weak var mapReportLocation: MGLMapView!
    
    @IBOutlet weak var mapReportLocationButton: UIButton!
    @IBOutlet weak var addReportLocationButton: UIButton!
    @IBOutlet weak var addReportLocationButtonImage: UIImageView!
    @IBOutlet weak var changeReportLocationButtonImage: UIImageView!
    @IBOutlet weak var changeReportLocationButton: UIButton!
    @IBOutlet weak var textfieldReportDate: UITextField!
    
    @IBOutlet weak var labelReportLocationLongitude: UILabel!
    @IBOutlet weak var labelReportLocationLatitude: UILabel!
    
    @IBOutlet var indicatorLoadingView: UIView!
    
    
    //
    // MARK: @IBActions
    //
    @IBAction func launchNewReportLocationSelector(sender: AnyObject) {
        self.performSegueWithIdentifier("setLocationForExistingReport", sender: sender)
    }
    
    @IBAction func textfieldDatePickerEditingDidEnd(sender: UITextField) {}
    
    @IBAction func textfieldDatePickerEditingDidBegin(sender: UITextField) {
        
        let datePickerView:UIDatePicker = UIDatePicker()
        datePickerView.datePickerMode = UIDatePickerMode.Date
        
        let toolBar = UIToolbar()
        toolBar.barStyle = UIBarStyle.Default
        toolBar.translucent = true
        toolBar.sizeToFit()
        
        let doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.Plain, target: self, action:#selector(EditReportTableViewController.doneButton(_:)))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil)
        
        toolBar.setItems([spaceButton, doneButton], animated: false)
        toolBar.userInteractionEnabled = true
        
        datePickerView.addTarget(self, action: #selector(EditReportTableViewController.datePickerValueChanged(_:)), forControlEvents: .ValueChanged)
        
        sender.inputView = datePickerView
        sender.inputAccessoryView = toolBar
    }

    
    //
    // MARK: Variables
    //
    var loadingView: UIView!
    
    var userSelectedCoorindates: CLLocationCoordinate2D!
    var thisLocationManager: CLLocationManager = CLLocationManager()
    var tempGroups: [String] = [String]()
    
    var reportId: String!
    var report: JSON!
    
    
    
    //
    // MARK: Overrides
    //
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        tableView.reloadData()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //
        // Make sure we are getting 'auto layout' specific sizes
        // otherwise any math we do will be messed up
        //
        self.view.setNeedsLayout()
        self.view.layoutIfNeeded()
        
        self.tableView.backgroundColor = UIColor.colorBackground(1.00)
        
        textareaReportComment.targetForAction(#selector(NewReportTableViewController.textFieldShouldReturn(_:)), withSender: self)
        textfieldReportDate.targetForAction(#selector(NewReportTableViewController.textFieldShouldReturn(_:)), withSender: self)
        
        //
        // Make sure the Add and Change location buttons perform the same action as touching the map
        //
        addReportLocationButton.addTarget(self, action: #selector(NewReportTableViewController.launchNewReportLocationSelector(_:)), forControlEvents: .TouchUpInside)
        changeReportLocationButton.addTarget(self, action: #selector(NewReportTableViewController.launchNewReportLocationSelector(_:)), forControlEvents: .TouchUpInside)
        
        //
        // Setup Navigation Bar
        //
        navigationBarButtonSave.target = self
        navigationBarButtonSave.action = #selector(buttonSaveExistingReportTableViewController(_:))
        
        self.isReady()
        
        //
        //
        //
        if (self.report != nil) {
            
            // Set existing date to date field
            //
            let reportDate = self.report["properties"]["report_date"]
            
            if (reportDate != nil) {
                let dateString: String = "\(reportDate)"
                
                let dateFormatter = NSDateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
                
                let stringToFormat = dateFormatter.dateFromString(dateString)
                dateFormatter.dateFormat = "MMM d, yyyy"
                
                let displayDate = dateFormatter.stringFromDate(stringToFormat!)
                
                if let thisDisplayDate: String? = displayDate {
                    self.textfieldReportDate.text = thisDisplayDate
                }
            }
            else {
                self.textfieldReportDate.text = ""
            }
            
            // Set existing comment to comment field
            //
            self.textareaReportComment.text = "\(self.report["properties"]["report_description"])"
            
            // Set existing groups to group fields
            //
            if (self.report["properties"]["groups"].count >= 1) {
                for _group in self.report["properties"]["groups"] {
                    let _organization_id_number: String! = "\(_group.1["properties"]["id"])"
                    self.tempGroups.append(_organization_id_number)
                }
            }
            
            // Set existing geometry to the geometry field
            //
            let _latitude: Double! = self.report["geometry"]["geometries"][0]["coordinates"][1].double
            let _longitude: Double! = self.report["geometry"]["geometries"][0]["coordinates"][0].double
            let _coordinates = CLLocationCoordinate2DMake(_latitude, _longitude)

            print("latitude: \(_latitude), longitude: \(_longitude)")
            print("_coordinates: \(_coordinates)")
            
            self.userSelectedCoorindates = _coordinates
            self.addLocationToMap(self.mapReportLocation, latitude: _latitude, longitude: _longitude, center: true)
            self.labelReportLocationLongitude.text = "\(_longitude)"
            self.labelReportLocationLatitude.text = "\(_latitude)"
            
            self.hasLocationSet()
        }
    }
    
    
    //
    // MARK: Table View Controller Customization
    //
    override func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        
        let header: UITableViewHeaderFooterView = view as! UITableViewHeaderFooterView
        
        header.textLabel!.font = UIFont.systemFontOfSize(12)
        header.textLabel!.textColor = UIColor.colorDarkGray(0.5)
        
        header.contentView.backgroundColor = UIColor.colorBackground(1.00)
    }
    
    @IBAction func buttonSaveExistingReportTableViewController(sender: UIBarButtonItem) {
        
        let accessToken = NSUserDefaults.standardUserDefaults().objectForKey("currentUserAccountAccessToken")
        let headers = [
            "Authorization": "Bearer " + (accessToken! as! String)
        ]
        
        self.attemptExistingReportSave(headers)
        
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        var rowHeight:CGFloat = 44.0
        
        switch indexPath.section {
            case 1:
                if (indexPath.row == 0) {
                    rowHeight = 232.0
                }
                break
            case 2:
                if (indexPath.row == 0) {
                    rowHeight = 232.0
                }
                break
        default:
            rowHeight = 44.0
            break
        }
        
        return rowHeight
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        guard let segueId = segue.identifier else { return }
        
        switch segueId {
            
        case "setLocationForExistingReport":
            
            let destinationNavigationViewController = segue.destinationViewController as! UINavigationController
            let destinationNewReportLocationSelectorViewController = destinationNavigationViewController.topViewController as! NewReportLocationSelector
            
            destinationNewReportLocationSelectorViewController.delegate = self
            destinationNewReportLocationSelectorViewController.userSelectedCoordinates = self.userSelectedCoorindates
            break
        case "setGroupsForExistingReport":
            
            let destinationNavigationViewController = segue.destinationViewController as! UINavigationController
            let destinationNewReportGroupSelectorViewController = destinationNavigationViewController.topViewController as! NewReportGroupsTableViewController
            
            destinationNewReportGroupSelectorViewController.tempGroups = self.tempGroups
            destinationNewReportGroupSelectorViewController.delegate = self
            break
        default:
            break
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func datePickerValueChanged(sender:UIDatePicker) {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = NSDateFormatterStyle.MediumStyle
        dateFormatter.timeStyle = NSDateFormatterStyle.NoStyle
        textfieldReportDate.text = dateFormatter.stringFromDate(sender.date)
    }
    
    func doneButton(sender:UIBarButtonItem) {
        self.textfieldReportDate.resignFirstResponder()
    }
    
    func loadGroups() {
        
    }
    
    //
    // MARK: Custom functionality
    //
    func saving() {
        
        //
        // Create a view that covers the entire screen
        //
        self.loadingView = self.indicatorLoadingView
        self.loadingView.frame = CGRectMake(0, 0, self.view.frame.width, self.view.frame.height)
        
        self.view.addSubview(self.loadingView)
        self.view.bringSubviewToFront(self.loadingView)
        
        //
        // Make sure that the Done/Save button is disabled
        //
        self.navigationItem.rightBarButtonItem?.enabled = false
        
        //
        // Make doubly sure the keyboard is closed
        //
        self.textfieldReportDate.resignFirstResponder()
        self.textareaReportComment.resignFirstResponder()
        
        //
        // Make sure our view is scrolled to the top
        //
        self.tableView.setContentOffset(CGPointZero, animated: false)
        
    }
    
    func finishedSaving() {
        
        //
        // Create a view that covers the entire screen
        //
        self.loadingView.removeFromSuperview()
        
        //
        // Make sure that the Done/Save button is disabled
        //
        self.navigationItem.rightBarButtonItem?.enabled = true
        
        //
        // Make doubly sure the keyboard is closed
        //
        self.textfieldReportDate.resignFirstResponder()
        self.textareaReportComment.resignFirstResponder()
        
        //
        // Make sure our view is scrolled to the top
        //
        self.tableView.setContentOffset(CGPointZero, animated: false)
        
        self.userSelectedCoorindates = CLLocationCoordinate2D()
        self.resetLocationOnMap(self.mapReportLocation)
        
        self.labelReportLocationLatitude.text = "Latitude: Unknown"
        self.labelReportLocationLongitude.text = "Longitude Unknown"
        self.textareaReportComment.text = ""
        
        // Reset date field
        let dateFormatter = NSDateFormatter()
        let date = NSDate()
        dateFormatter.dateStyle = NSDateFormatterStyle.MediumStyle
        dateFormatter.timeStyle = NSDateFormatterStyle.NoStyle
        textfieldReportDate.text = dateFormatter.stringFromDate(date)
        
    }
    
    func finishedSavingWithError() {
        self.navigationItem.rightBarButtonItem?.enabled = true
    }
    
    func isReady() {
        self.hasNoLocationSet()
    }
    
    func hasLocationSet() {
        self.addReportLocationButton.hidden = true
        self.addReportLocationButtonImage.hidden = true
        
        self.changeReportLocationButton.hidden = false
        self.changeReportLocationButtonImage.hidden = false
    }
    
    func hasNoLocationSet() {
        self.addReportLocationButton.hidden = false
        self.addReportLocationButtonImage.hidden = false
        
        self.changeReportLocationButton.hidden = true
        self.changeReportLocationButtonImage.hidden = true
    }
    
    func isReadyWithLocation() {
        mapReportLocation.hidden = false;
    }
    
    func isUpdatingReportLocation() {
        print("isUpdatingReportLocation")
    }
    
    func startLocationServices(sender: AnyObject) {
        self.isReadyWithLocation()
        self.tableView.reloadData()
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        let nextTag = textField.tag + 1;
        let nextResponder=textField.superview?.superview?.superview?.viewWithTag(nextTag) as UIResponder!
        
        if (nextResponder != nil){
            nextResponder?.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
        }
        
        return false
    }
    
    // Child Delegate
    func sendCoordinates(coordinates: CLLocationCoordinate2D) {
        print("PARENT:sendCoordinates see \(coordinates)")
        
        // Pass off coorindates to the self.userSelectedCoordinates
        self.userSelectedCoorindates = coordinates
        
        // Fill the display fields
        self.labelReportLocationLatitude.text = "Lat: " + String(self.userSelectedCoorindates.latitude)
        self.labelReportLocationLongitude.text = "Lng: " + String(self.userSelectedCoorindates.longitude)
        
        // Hide the "Add Button" and show the "Choose different" button
        self.hasLocationSet()
        
    }
    
    func onSetCoordinatesComplete(isFinished: Bool) {
        
        print("onSetCoordinatesComplete")
        
        let thisMapView: MGLMapView = self.mapReportLocation
        let thisMapCenterCoordinates: CLLocationCoordinate2D = self.userSelectedCoorindates
        let thisMapCenter: Bool = true
        
        switch isFinished {
        case true:
            
            // Disable UserTrackingMode.Follow action
            mapReportLocation.showsUserLocation = false
            
            // Add an annotation to the map using the new coordinates
            self.addLocationToMap(thisMapView, latitude: thisMapCenterCoordinates.latitude, longitude: thisMapCenterCoordinates.longitude, center: thisMapCenter)
            
            break
            
        default:
            break
            
        }
        
        return
    }
    
    // Child Delegate
    func sendGroups(groups: [String]) {
        self.tempGroups = groups
    }
    
    func addLocationToMap(mapView: AnyObject, latitude: Double, longitude: Double, center:Bool) {
        
        let thisAnnotation = MGLPointAnnotation()
        
        
        thisAnnotation.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        
        mapView.addAnnotation(thisAnnotation)
        
        if center {
            // Center the map on the annotation.
            mapView.setCenterCoordinate(thisAnnotation.coordinate, zoomLevel: 15, animated: false)
            
            // Pop-up the callout view.
            mapView.selectAnnotation(thisAnnotation, animated: true)
        }
    }
    
    func resetLocationOnMap(mapView: MGLMapView) {
        
        let _coordinates = CLLocationCoordinate2DMake(39.5, -98.35)
        
        mapView.setCenterCoordinate(_coordinates, zoomLevel: 15, animated: false)
        
        if (mapView.annotations?.count >= 1) {
            mapView.removeAnnotations(mapView.annotations!)
        }
    }
    
    
    //
    // MARK: Server Request/Response functionality
    //
    func attemptExistingReportSave(headers: [String: String]) {
        
        let _endpoint = Endpoints.POST_REPORT + "/\(self.reportId)"
        
        //
        // Error Check for Geometry
        //
        var geometryCollection: [String: AnyObject] = [
            "type": "GeometryCollection"
        ]
        
        if (self.userSelectedCoorindates != nil) {
            
            var geometry: [String: AnyObject] = [
                "type": "Point"
            ]
            
            let coordinates: Array = [
                self.userSelectedCoorindates.longitude,
                self.userSelectedCoorindates.latitude
            ]
            
            geometry["coordinates"] = coordinates
            
            let geometries: [AnyObject] = [geometry]
            geometryCollection["geometries"] = geometries
        }
        else {
            self.displayErrorMessage("Location Field Empty", message: "Please add a location to your report before saving")
            
            self.finishedSavingWithError()
            
            return
        }
        
        // Before starting the saving process, hide the form
        // and show the user the saving indicator
        self.saving()
        
        //
        // PARAMETERS
        //
        var parameters: [String: AnyObject] = [
            "report_description": self.textareaReportComment.text!,
            "report_date": self.textfieldReportDate.text!,
            "geometry": geometryCollection,
            "state": "\(self.report["properties"]["state"])"
        ]
        
        
        //
        // GROUPS
        //
        var _temporary_groups: [AnyObject] = [AnyObject]()
        
        for _organization_id in tempGroups {
            print("group id \(_organization_id)")
            
            let _group = [
                "id": "\(_organization_id)",
            ]
            
            _temporary_groups.append(_group)
            
        }
        
        parameters["groups"] = _temporary_groups
        
        //
        // Make request
        //
        Alamofire.request(.PATCH, _endpoint, parameters: parameters, headers: headers, encoding: .JSON)
            .responseJSON { response in
                
                print("Response \(response)")
                
                switch response.result {
                case .Success(let value):
                    
                    print("Response Sucess \(value)")
                    
                    // Hide the loading indicator
                    self.finishedSaving()
                    
                    self.navigationController?.popViewControllerAnimated(true)
                    
                case .Failure(let error):
                    
                    print("Response Failure \(error)")
                    
                    break
                }
                
        }

        
    }
    
    func displayErrorMessage(title: String, message: String) {
        
        let alertController = UIAlertController(title: title, message:message, preferredStyle: UIAlertControllerStyle.Alert)
        
        alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default, handler: nil))
        
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            textView.resignFirstResponder()
        }
        return true
    }
    
    
}

