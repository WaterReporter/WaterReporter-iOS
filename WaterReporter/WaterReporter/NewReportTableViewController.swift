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

class NewReportTableViewController: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, CLLocationManagerDelegate, MGLMapViewDelegate, NewReportLocationSelectorDelegate {
    
    var userSelectedCoorindates: CLLocationCoordinate2D!
    
    var imageReportImagePreviewIsSet:Bool = false
    var thisLocationManager: CLLocationManager = CLLocationManager()
    
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
    
    @IBOutlet weak var labelReportLocationLongitude: UILabel!
    @IBOutlet weak var labelReportLocationLatitude: UILabel!
    
    @IBAction func launchNewReportLocationSelector(sender: AnyObject) {
        self.performSegueWithIdentifier("setLocationForNewReport", sender: sender)
    }
    
    //
    //
    //
    @IBOutlet weak var textfieldReportDate: UITextField!

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
    
    func datePickerValueChanged(sender:UIDatePicker) {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = NSDateFormatterStyle.MediumStyle
        dateFormatter.timeStyle = NSDateFormatterStyle.NoStyle
        textfieldReportDate.text = dateFormatter.stringFromDate(sender.date)
    }
    
    func doneButton(sender:UIBarButtonItem) {
        self.textfieldReportDate.resignFirstResponder()
    }
    
    //
    //
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
                    rowHeight = 148.0
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
            default:
                break
        }

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    //
    // MARK: Custom functionality
    //
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
    
    func mapView(mapView: MGLMapView, didUpdateUserLocation userLocation: MGLUserLocation?) {
        print("location updated")
    }
    
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
        self.dismissViewControllerAnimated(true, completion: {
            self.isReadyWithImage()
            self.tableView.reloadData()
        })
    }
    
    func attemptRemoveImageFromPreview(sender: AnyObject) {
        imageReportImagePreview.image = nil
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
    
    func attemptNewReportSave(headers: [String: String]) {
        
        
        //
        // GEOMETRY
        //
        var geometryCollection: [String: AnyObject] = [
            "type": "GeometryCollection"
        ]

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
        
        
        //
        // PARAMETERS
        //
        var parameters: [String: AnyObject] = [
            "report_description": self.textareaReportComment.text!,
            "report_date": self.textfieldReportDate.text!,
            "geometry": geometryCollection
        ]
        

        //
        // GROUPS
        //
//        if (self.textfieldTelephone.text != self.userProfile?["properties"]["telephone"][0]["properties"]["number"].string && self.textfieldTelephone.text != nil) {
//            let telephoneNumber = [
//                "number": self.textfieldTelephone.text!
//            ]
//            let telephone: [AnyObject] = [telephoneNumber]
//            
//            parameters["telephone"] = telephone
//        }
        
        
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
                                            self.tabBarController?.selectedIndex = 1
                                        case .Failure(let error):
                                            print("attemptUserProfileSave::Failure")
                                            print(error)
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
    


}

