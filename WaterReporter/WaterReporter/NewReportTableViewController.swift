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
import OpenGraph
import SwiftyJSON
import UIKit

class NewReportTableViewController: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, CLLocationManagerDelegate, MGLMapViewDelegate, NewReportLocationSelectorDelegate {
    
    
    //
    // MARK: @IBOutlets
    //
//    @IBOutlet weak var textareaReportComment: UITextView!
//    @IBOutlet weak var buttonReportImage: UIButton!
//    @IBOutlet weak var buttonReportImageAddIcon: UIImageView!
//    
    @IBOutlet weak var navigationBarButtonSave: UIBarButtonItem!
//
//    @IBOutlet weak var tableViewCellReportImage: UITableViewCell!
//    
//    @IBOutlet weak var addReportLocationButton: UIButton!
//    @IBOutlet weak var addReportLocationButtonImage: UIImageView!
//    
//    @IBOutlet weak var labelReportLocationLatitude: UILabel!
//    
    @IBOutlet var indicatorLoadingView: UIView!
//
//    @IBOutlet weak var hashtagTypeAhead: UITableView!
    
    //
    // MARK: @IBActions
    //
    @IBAction func launchNewReportLocationSelector(sender: UIButton) {
        self.performSegueWithIdentifier("setLocationForNewReport", sender: sender)
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

    @IBAction func buttonSaveNewReportTableViewController(sender: UIBarButtonItem) {
        
        let accessToken = NSUserDefaults.standardUserDefaults().objectForKey("currentUserAccountAccessToken")
        let headers = [
            "Authorization": "Bearer " + (accessToken! as! String)
        ]
        
        self.attemptNewReportSave(headers)
        
    }

    @IBAction func selectGroup(sender: UISwitch) {
        
        if sender.on {
            let _organization_id_number: String! = "\(self.groups!["features"][sender.tag]["properties"]["organization_id"])"
            self.tempGroups.append(_organization_id_number)
            print("addGroup::finished::tempGroups \(self.tempGroups)")
        } else {
            let _organization_id_number: String! = "\(self.groups!["features"][sender.tag]["properties"]["organization_id"])"
            self.tempGroups = self.tempGroups.filter() {$0 != _organization_id_number}
            print("removeGroup::finished::tempGroups \(self.tempGroups)")
        }
        
    }

    
    //
    // MARK: Variables
    //
    var loadingView: UIView!
    
    var userSelectedCoorindates: CLLocationCoordinate2D!
    var imageReportImagePreviewIsSet:Bool = false
    var thisLocationManager: CLLocationManager = CLLocationManager()
    var tempGroups: [String] = [String]()
    var groups: JSON?

    var reportImage: UIImage!
    
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
        
//        textareaReportComment.targetForAction(#selector(NewReportTableViewController.textFieldShouldReturn(_:)), withSender: self)
//
        
        //
        // Setup Navigation Bar
        //
        navigationBarButtonSave.target = self
        navigationBarButtonSave.action = #selector(buttonSaveNewReportTableViewController(_:))
        
        self.attemptLoadUserGroups()
        
    }
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        
        // [text isEqualToString:[UIPasteboard generalPasteboard].string]
        let _pasteboard = UIPasteboard.generalPasteboard().string
        
        if (text == _pasteboard) {
            //
            // Step 1: Get the information being pasted
            //
            print("Pasting text", _pasteboard)
            
            //
            // Step 2: Check to see if the text being pasted is a link
            //
//            if self.verifyUrl(_pasteboard) {
                print("Pasted text is a URL")
                print("Now check for Open Graph support")
                let _url = NSURL(string: _pasteboard!)
                OpenGraph.fetch(_url!) { og, error in
                    print("Open Graph \(og)") // => og:title of the web site
//                    print("Open Graph \(og?[.type])")  // => og:type of the web site
//                    print("Open Graph \(og?[.image])") // => og:image of the web site
//                    print("Open Graph \(og?[.url])")   // => og:url of the web site
                }
//            }
//            else {
//                print("Not a url")
//            }
        }
        
        return true
    }
    
    func verifyUrl (urlString: String?) -> Bool {
        //Check for nil
        if let urlString = urlString {
            // create NSURL instance
            if let url = NSURL(string: urlString) {
                // check if your application can open the NSURL instance
                return UIApplication.sharedApplication().canOpenURL(url)
            }
        }
        return false
    }
    
    
    //
    // MARK: Table Overrides
    //
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(tableView:UITableView, numberOfRowsInSection section: Int) -> Int {
        
        var numberOfRows: Int = 2
        
        if section == 1 {
            if self.groups != nil {
                
                let numberOfGroups: Int = (self.groups?["features"].count)!
                
                numberOfRows = (numberOfGroups)
                
            }
        }
        
        return numberOfRows
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        if indexPath.section == 0 {
            if indexPath.row == 0 {
                let cell = tableView.dequeueReusableCellWithIdentifier("newReportContentTableViewCell", forIndexPath: indexPath) as! NewReportContentTableViewCell
                
                // Report Image
                //
                cell.buttonReportAddImage.addTarget(self, action: #selector(NewReportTableViewController.attemptOpenPhotoTypeSelector(_:)), forControlEvents: .TouchUpInside)
                
                if (self.reportImage != nil) {
                    cell.imageReportImage.image = self.reportImage
                }
                
                // Report Description
                //
                
                return cell
            }
            else if indexPath.row == 1 {
                let cell = tableView.dequeueReusableCellWithIdentifier("newReportLocationTableViewCell", forIndexPath: indexPath) as! NewReportLocationTableViewCell
                
                print("Location Row")
                
                // Display location selection map when Confirm Location button is
                // tapped/touched
                //
                cell.buttonChangeLocation.addTarget(self, action: #selector(self.launchNewReportLocationSelector(_:)), forControlEvents: .TouchUpInside)
                
                
                // Update the text display for the user selected coordinates when
                // the self.userSelectedCoorindates variable is not empty
                //
                print("self.userSelectedCoorindates \(self.userSelectedCoorindates)")
                
                if self.userSelectedCoorindates != nil {
                    cell.labelLocation.text = String(self.userSelectedCoorindates.longitude) + " " + String(self.userSelectedCoorindates.latitude)
                }
                
                
                return cell
            }
        }
        else if indexPath.section == 1 {
            
            let cell = tableView.dequeueReusableCellWithIdentifier("newReportGroupTableViewCell", forIndexPath: indexPath) as! NewReportGroupTableViewCell
            
            guard (self.groups != nil) else { return cell }
            
            let _index = indexPath.row
            let group = self.groups?["features"][_index]
            
            if group != nil {
                
                // Organization Logo
                //
                cell.imageGroupLogo.tag = _index
                cell.imageGroupLogo.tag = indexPath.row

                let organizationImageUrl:NSURL = NSURL(string: "\(group!["properties"]["organization"]["properties"]["picture"])")!

                cell.imageGroupLogo.kf_indicatorType = .Activity
                cell.imageGroupLogo.kf_showIndicatorWhenLoading = true

                cell.imageGroupLogo.kf_setImageWithURL(organizationImageUrl, placeholderImage: nil, optionsInfo: nil, progressBlock: nil, completionHandler: {
                    (image, error, cacheType, imageUrl) in
                    cell.imageGroupLogo.image = image
                    cell.imageGroupLogo.layer.cornerRadius = cell.imageGroupLogo.frame.size.width / 2
                    cell.imageGroupLogo.clipsToBounds = true
                })
                

                // Organization Name
                //
                cell.labelGroupName.text = "\(group!["properties"]["organization"]["properties"]["name"])"
                
                
                // Organization Switch/Selection
                //
                cell.switchGroupSelect.tag = _index

                if let _organization_id_number = self.groups?["features"][indexPath.row]["properties"]["organization_id"] {
                    
                    if self.tempGroups.contains("\(_organization_id_number)") {
                        cell.switchGroupSelect.on = true
                    }
                    else {
                        cell.switchGroupSelect.on = false
                    }
                    
                }

            }
            
            return cell
        }
        
        return UITableViewCell()
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        var rowHeight: CGFloat = 44.0

//        if (indexPath.row == 1 && self.hashtagTypeAhead.hidden == false) {
//            rowHeight = 288.0
//        }
        
        if (indexPath.row == 0) {
            rowHeight = 124.0
        }
        else if indexPath.row >= 2 {
            rowHeight = 72.0
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
    
    func onSetCoordinatesComplete(isFinished: Bool) { return }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
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
//        self.textareaReportComment.resignFirstResponder()
        
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
//        self.textareaReportComment.resignFirstResponder()
        
        //
        // Make sure our view is scrolled to the top
        //
        self.tableView.setContentOffset(CGPointZero, animated: false)
        
        
        // Reset all fields
        self.imageReportImagePreviewIsSet = false

        self.userSelectedCoorindates = CLLocationCoordinate2D()
        
//        self.labelReportLocationLatitude.text = "Confirm location"
//        self.textareaReportComment.text = ""

    }
    
    func finishedSavingWithError() {
        self.navigationItem.rightBarButtonItem?.enabled = true
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
        
        // Change the default camera icon to a preview of the image the user
        // has selected to be their report image.
        //
        self.reportImage = image
        
        // Refresh the table view to display the updated image data
        //
        self.dismissViewControllerAnimated(true, completion: {
            self.tableView.reloadData()
        })
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
    
    //
    // MARK: Child Delegate
    //
    func sendCoordinates(coordinates: CLLocationCoordinate2D) {
        print("PARENT:sendCoordinates see \(coordinates)")

        // Pass off coorindates to the self.userSelectedCoordinates
        //
        self.userSelectedCoorindates = coordinates
        
        // Update the display of the returned coordinates in the "Confirm
        // Location" table view cell label
        //
        self.tableView.reloadData()
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
//            "report_description": self.textareaReportComment.text!,
            "report_description": "",
            "is_public": "true",
            "geometry": geometryCollection,
            "state": "open"
        ]
        

        //
        // GROUPS
        //
        var _temporary_groups: [AnyObject] = [AnyObject]()

//        for _organization_id in tempGroups {
//            print("group id \(_organization_id)")
//            
//            let _group = [
//                "id": "\(_organization_id)",
//            ]
//            
//            _temporary_groups.append(_group)
//            
//        }
        
        parameters["groups"] = _temporary_groups

        //
        // Make request
        //
//        if (self.buttonReportImageAddIcon.image != nil) {
//            
//            Alamofire.upload(.POST, Endpoints.POST_IMAGE, headers: headers, multipartFormData: { multipartFormData in
//                
//                // import image to request
//                if let imageData = UIImageJPEGRepresentation(self.buttonReportImageAddIcon.image!, 1) {
//                    multipartFormData.appendBodyPart(data: imageData, name: "image", fileName: "ReportImageFromiPhone.jpg", mimeType: "image/jpeg")
//                }
//                
//                }, encodingCompletion: {
//                    encodingResult in
//                    switch encodingResult {
//                    case .Success(let upload, _, _):
//                        upload.responseJSON { response in
//                            print("Image uploaded \(response)")
//                            
//                            if let value = response.result.value {
//                                let imageResponse = JSON(value)
//                                
//                                let image = [
//                                    "id": String(imageResponse["id"].rawValue)
//                                ]
//                                let images: [AnyObject] = [image]
//                                
//                                parameters["images"] = images
//                                
//                                print("parameters \(parameters)")
//                                
//                                Alamofire.request(.POST, Endpoints.POST_REPORT, parameters: parameters, headers: headers, encoding: .JSON)
//                                    .responseJSON { response in
//                                        
//                                        print("Response \(response)")
//                                        
//                                        switch response.result {
//                                        case .Success(let value):
//                                            
//                                            print("Response Sucess \(value)")
//                                            
//                                            // Hide the loading indicator
//                                            self.finishedSaving()
//                                            
//                                            // Send user to the Activty Feed
//                                            self.tabBarController?.selectedIndex = 0
//                                            
//                                        case .Failure(let error):
//                                            
//                                            print("Response Failure \(error)")
//                                            
//                                            break
//                                        }
//                                        
//                                }
//                            }
//                        }
//                    case .Failure(let encodingError):
//                        print(encodingError)
//                    }
//            })
//            
//        }
        
    }

    func displayErrorMessage(title: String, message: String) {
        
        let alertController = UIAlertController(title: title, message:message, preferredStyle: UIAlertControllerStyle.Alert)
        
        alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default, handler: nil))
        
        self.presentViewController(alertController, animated: true, completion: nil)
    }

    
    func buildRequestHeaders() -> [String: String] {
        
        let accessToken = NSUserDefaults.standardUserDefaults().objectForKey("currentUserAccountAccessToken")
        
        return [
            "Authorization": "Bearer " + (accessToken! as! String)
        ]
    }
    
    func attemptLoadUserGroups() {
        
        // Set headers
        let _headers = self.buildRequestHeaders()
        
        if let userId = NSUserDefaults.standardUserDefaults().objectForKey("currentUserAccountUID") as? NSNumber {
            
            let GET_GROUPS_ENDPOINT = Endpoints.GET_USER_PROFILE + "\(userId)" + "/groups"
            
            Alamofire.request(.GET, GET_GROUPS_ENDPOINT, headers: _headers, encoding: .JSON).responseJSON { response in
                
                print("response.result \(response.result)")
                
                switch response.result {
                case .Success(let value):
                    print("Request Success for Groups: \(value)")
                    
                    // Assign response to groups variable
                    self.groups = JSON(value)
                    
                    // Refresh the data in the table so the newest items appear
                    self.tableView.reloadData()
                    
                    break
                case .Failure(let error):
                    print("Request Failure: \(error)")
//                    
//                    // Stop showing the loading indicator
//                    self.status("doneLoadingWithError")
                    
                    break
                }
            }
            
        } else {
            self.attemptRetrieveUserID()
        }
        
    }
    
    func attemptRetrieveUserID() {
        
        // Set headers
        let _headers = self.buildRequestHeaders()
        
        Alamofire.request(.GET, Endpoints.GET_USER_ME, headers: _headers, encoding: .JSON)
            .responseJSON { response in
                
                switch response.result {
                case .Success(let value):
                    let json = JSON(value)
                    
                    if let data: AnyObject = json.rawValue {
                        NSUserDefaults.standardUserDefaults().setValue(data["id"], forKeyPath: "currentUserAccountUID")
                        
                        self.attemptLoadUserGroups()
                    }
                    
                case .Failure(let error):
                    print(error)
                }
        }
    }

}

