//
//  NewReportTableViewController.swift
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

class NewReportTableViewController: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, CLLocationManagerDelegate, MGLMapViewDelegate, NewReportLocationSelectorDelegate, NewReportGroupSelectorDelegate {
    
    
    //
    // MARK: @IBOutlets
    //
    @IBOutlet weak var textareaReportComment: UITextView!

    @IBOutlet weak var buttonReportImageRemove: UIButton!
    @IBOutlet weak var buttonReportImageRemoveIcon: UIImageView!
    @IBOutlet weak var buttonReportImage: UIButton!
    @IBOutlet weak var buttonReportImageAddIcon: UIImageView!
    @IBOutlet weak var imageReportImagePreview: UIImageView!
    
    @IBOutlet weak var navigationBarButtonSave: UIBarButtonItem!
    
    @IBOutlet weak var tableViewCellReportImage: UITableViewCell!
    
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
        self.performSegueWithIdentifier("setLocationForNewReport", sender: sender)
    }
    
    @IBAction func textfieldDatePickerEditingDidBegin(sender: UITextField) {

        let datePickerView:UIDatePicker = UIDatePicker()
        datePickerView.datePickerMode = UIDatePickerMode.Date

        let toolBar = UIToolbar()
        toolBar.barStyle = UIBarStyle.Default
        toolBar.translucent = true
        toolBar.sizeToFit()
        
        let doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.Plain, target: self, action:#selector(NewReportTableViewController.doneButton(_:)))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil)
        
        toolBar.setItems([spaceButton, doneButton], animated: false)
        toolBar.userInteractionEnabled = true
        
        datePickerView.addTarget(self, action: #selector(NewReportTableViewController.datePickerValueChanged(_:)), forControlEvents: .ValueChanged)

        sender.inputView = datePickerView
        sender.inputAccessoryView = toolBar
    }
    
    @IBAction func textfieldDatePickerEditingDidEnd(sender: UITextField) {}
    
    @IBAction func attemptOpenPhotoTypeSelector(sender: AnyObject) {
        
        let thisActionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        
        let cameraAction = UIAlertAction(title: "Camera", style: .Default, handler:self.cameraActionHandler)
        thisActionSheet.addAction(cameraAction)
        
        let photoLibraryAction = UIAlertAction(title: "Photo Library", style: .Default, handler:self.photoLibraryActionHandler)
        thisActionSheet.addAction(photoLibraryAction)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        thisActionSheet.addAction(cancelAction)
        
        presentViewController(thisActionSheet, animated: true, completion: nil)
        
    }

    
    //
    // MARK: Variables
    //
    var loadingView: UIView!
    
    var userSelectedCoorindates: CLLocationCoordinate2D!
    var imageReportImagePreviewIsSet:Bool = false
    var thisLocationManager: CLLocationManager = CLLocationManager()
    var tempGroups: [String] = [String]()

    
    
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
        
        self.navigationItem.title = "New Report"

        self.tableView.backgroundColor = UIColor.colorBackground(1.00)
        
        textareaReportComment.targetForAction(#selector(NewReportTableViewController.textFieldShouldReturn(_:)), withSender: self)
        textfieldReportDate.targetForAction(#selector(NewReportTableViewController.textFieldShouldReturn(_:)), withSender: self)

        buttonReportImage.addTarget(self, action: #selector(NewReportTableViewController.attemptOpenPhotoTypeSelector(_:)), forControlEvents: .TouchUpInside)
        buttonReportImageRemove.addTarget(self, action: #selector(NewReportTableViewController.attemptRemoveImageFromPreview(_:)), forControlEvents: .TouchUpInside)
        
        //
        // Make sure the Add and Change location buttons perform the same action as touching the map
        //
        addReportLocationButton.addTarget(self, action: #selector(NewReportTableViewController.launchNewReportLocationSelector(_:)), forControlEvents: .TouchUpInside)
        changeReportLocationButton.addTarget(self, action: #selector(NewReportTableViewController.launchNewReportLocationSelector(_:)), forControlEvents: .TouchUpInside)
        
        //
        // Setup Navigation Bar
        //
        navigationBarButtonSave.target = self
        navigationBarButtonSave.action = #selector(buttonSaveNewReportTableViewController(_:))
        
        //
        // Set Default Date
        //
        let dateFormatter = NSDateFormatter()
        let date = NSDate()
        dateFormatter.dateStyle = NSDateFormatterStyle.MediumStyle
        dateFormatter.timeStyle = NSDateFormatterStyle.NoStyle
        textfieldReportDate.text = dateFormatter.stringFromDate(date)
        
        
        self.isReady()
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
    
    @IBAction func buttonSaveNewReportTableViewController(sender: UIBarButtonItem) {
        
        let accessToken = NSUserDefaults.standardUserDefaults().objectForKey("currentUserAccountAccessToken")
        let headers = [
            "Authorization": "Bearer " + (accessToken! as! String)
        ]
        
        self.attemptNewReportSave(headers)
        
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        var rowHeight:CGFloat = 44.0
        
        switch indexPath.section {
            case 2:
                if (indexPath.row == 0) {
                    rowHeight = 232.0
                }
            
            case 0:
                if indexPath.row == 0 {
                    rowHeight = 232.0
                }
                else {
                    rowHeight = 44.0
                }
            case 3:
                if (indexPath.row == 0) {
                    rowHeight = 232.0
                }
            default:
                rowHeight = 44.0
        }
        
        return rowHeight
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        guard let segueId = segue.identifier else { return }
        
        switch segueId {
            
            case "setLocationForNewReport":

                let destinationNavigationViewController = segue.destinationViewController as! UINavigationController
                let destinationNewReportLocationSelectorViewController = destinationNavigationViewController.topViewController as! NewReportLocationSelector

                destinationNewReportLocationSelectorViewController.delegate = self
                destinationNewReportLocationSelectorViewController.userSelectedCoordinates = self.userSelectedCoorindates
                break
            case "setGroupsForNewReport":
                
                let destinationNavigationViewController = segue.destinationViewController as! UINavigationController
                let destinationNewReportGroupSelectorViewController = destinationNavigationViewController.topViewController as! NewReportGroupsTableViewController
                
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
        
        
        // Reset all fields
        self.imageReportImagePreview.image = UIImage(named: "Icon--EmptyImage")
        self.imageReportImagePreview.alpha = 0.15
        self.imageReportImagePreviewIsSet = false

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

        //
        buttonReportImageRemove.hidden = true;
        buttonReportImageRemoveIcon.hidden = true;
        
        buttonReportImage.hidden = false
        buttonReportImageAddIcon.hidden = false

    }
    
    func finishedSavingWithError() {
        self.navigationItem.rightBarButtonItem?.enabled = true
    }

    func isReady() {
        buttonReportImageRemove.hidden = true;
        buttonReportImageRemoveIcon.hidden = true;
        
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
    
    func isReadyAfterRemove() {
        buttonReportImage.hidden = false;
        buttonReportImageAddIcon.hidden = false;
        
        buttonReportImageRemove.hidden = true;
        buttonReportImageRemoveIcon.hidden = true;
    }
    
    func isReadyWithLocation() {
        mapReportLocation.hidden = false;
    }

    func isUpdatingReportLocation() {
        print("isUpdatingReportLocation")
    }

    func isReadyWithImage() {
        buttonReportImage.hidden = true;
        buttonReportImageAddIcon.hidden = true;
        
        buttonReportImageRemove.hidden = false;
        buttonReportImageRemoveIcon.hidden = false;
    }

    func startLocationServices(sender: AnyObject) {
        self.isReadyWithLocation()
        self.tableView.reloadData()
    }
    
    func cameraActionHandler(action:UIAlertAction) -> Void {
        if (UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera)) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerControllerSourceType.Camera
            imagePicker.allowsEditing = true
            self.presentViewController(imagePicker, animated: true, completion: nil)
        }
    }
    
    func photoLibraryActionHandler(action:UIAlertAction) -> Void {
        if (UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.PhotoLibrary)) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
            imagePicker.allowsEditing = true
            self.presentViewController(imagePicker, animated: true, completion: nil)
        }
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        imageReportImagePreview.image = image
        imageReportImagePreviewIsSet = true
        imageReportImagePreview.alpha = 1.0
        self.dismissViewControllerAnimated(true, completion: {
            self.isReadyWithImage()
            self.tableView.reloadData()
        })
    }
    
    func attemptRemoveImageFromPreview(sender: AnyObject) {
        imageReportImagePreview.image = nil
        imageReportImagePreviewIsSet = false
        imageReportImagePreview.alpha = 0.15
        self.isReadyAfterRemove()
        tableView.reloadData()
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
    
    func textViewShouldReturn(textField: UITextView) -> Bool {
        
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
        let grr = CLLocationCoordinate2DMake(98.35, 39.5)

        mapView.setCenterCoordinate(grr, zoomLevel: 15, animated: false)
        
        if (mapView.annotations?.count >= 1) {
            mapView.removeAnnotations(mapView.annotations!)
        }
    }
    
    
    //
    // MARK: Server Request/Response functionality
    //
    func attemptNewReportSave(headers: [String: String]) {
        
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
        
        //
        // Check image value
        //
        if (!imageReportImagePreviewIsSet) {
            self.displayErrorMessage("Image Field Empty", message: "Please add an image to your report before saving")

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
            "is_public": "true",
            "report_date": self.textfieldReportDate.text!,
            "geometry": geometryCollection
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
        if (self.imageReportImagePreview.image != nil) {
            
            Alamofire.upload(.POST, Endpoints.POST_IMAGE, headers: headers, multipartFormData: { multipartFormData in
                
                // import image to request
                if let imageData = UIImageJPEGRepresentation(self.imageReportImagePreview.image!, 1) {
                    multipartFormData.appendBodyPart(data: imageData, name: "image", fileName: "ReportImageFromiPhone.jpg", mimeType: "image/jpeg")
                }
                
                }, encodingCompletion: {
                    encodingResult in
                    switch encodingResult {
                    case .Success(let upload, _, _):
                        upload.responseJSON { response in
                            print("Image uploaded \(response)")
                            
                            if let value = response.result.value {
                                let imageResponse = JSON(value)
                                
                                let image = [
                                    "id": String(imageResponse["id"].rawValue)
                                ]
                                let images: [AnyObject] = [image]
                                
                                parameters["images"] = images
                                
                                print("parameters \(parameters)")
                                
                                Alamofire.request(.POST, Endpoints.POST_REPORT, parameters: parameters, headers: headers, encoding: .JSON)
                                    .responseJSON { response in
                                        
                                        print("Response \(response)")
                                        
                                        switch response.result {
                                        case .Success(let value):
                                            
                                            print("Response Sucess \(value)")
                                            
                                            // Hide the loading indicator
                                            self.finishedSaving()
                                            
                                            // Send user to the Activty Feed
                                            self.tabBarController?.selectedIndex = 0
                                            
                                        case .Failure(let error):
                                            
                                            print("Response Failure \(error)")
                                            
                                            break
                                        }
                                        
                                }
                            }
                        }
                    case .Failure(let encodingError):
                        print(encodingError)
                    }
            })
            
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

