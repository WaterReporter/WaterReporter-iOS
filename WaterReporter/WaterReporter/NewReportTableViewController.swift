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
    
    @IBOutlet weak var typeAheadHeight: NSLayoutConstraint!
    
    //
    // MARK: @IBOutlets
    //
    @IBOutlet weak var textareaReportComment: UITextView!
    @IBOutlet weak var buttonReportImage: UIButton!
    @IBOutlet weak var buttonReportImageAddIcon: UIImageView!
    
    @IBOutlet weak var navigationBarButtonSave: UIBarButtonItem!
    
    @IBOutlet weak var tableViewCellReportImage: UITableViewCell!
    
    @IBOutlet weak var addReportLocationButton: UIButton!
    @IBOutlet weak var addReportLocationButtonImage: UIImageView!
    
    @IBOutlet weak var labelReportLocationLatitude: UILabel!
    
    @IBOutlet var indicatorLoadingView: UIView!

    @IBOutlet weak var hashtagTypeAhead: UITableView!
    
    //
    // MARK: @IBActions
    //
    @IBAction func launchNewReportLocationSelector(sender: AnyObject) {
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

    
    //
    // MARK: Variables
    //
    var loadingView: UIView!
    
    var userSelectedCoorindates: CLLocationCoordinate2D!
    var imageReportImagePreviewIsSet:Bool = false
    var thisLocationManager: CLLocationManager = CLLocationManager()
    var tempGroups: [String] = [String]()
    var hashtagAutocomplete: [String] = [String]()
    var groups: JSON?

    var hashtagSearchEnabled: Bool = false
    
    var dataSource: HashtagTableView = HashtagTableView()
    
    var hashtagSearchTimer: NSTimer = NSTimer()
    
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
        
        self.addDoneButtonOnKeyboard()
        
        //
        // Make sure we are getting 'auto layout' specific sizes
        // otherwise any math we do will be messed up
        //
        self.view.setNeedsLayout()
        self.view.layoutIfNeeded()
        
        self.navigationItem.title = "New Report"
        
        self.hashtagTypeAhead.delegate = dataSource
        self.hashtagTypeAhead.dataSource = dataSource
        dataSource.parent = self

        self.tableView.backgroundColor = UIColor.colorBackground(1.00)
        
        textareaReportComment.targetForAction(#selector(NewReportTableViewController.textFieldShouldReturn(_:)), withSender: self)

        buttonReportImage.addTarget(self, action: #selector(NewReportTableViewController.attemptOpenPhotoTypeSelector(_:)), forControlEvents: .TouchUpInside)
        
        //
        // Make sure the Add and Change location buttons perform the same action as touching the map
        //
        addReportLocationButton.addTarget(self, action: #selector(NewReportTableViewController.launchNewReportLocationSelector(_:)), forControlEvents: .TouchUpInside)
        
        //
        // Setup Navigation Bar
        //
        navigationBarButtonSave.target = self
        navigationBarButtonSave.action = #selector(buttonSaveNewReportTableViewController(_:))
        
        
        print("Do something here to change the number of rows in the last section default is \(self.tableView.numberOfRowsInSection(2))")
        
        self.attemptLoadUserGroups()
        
        self.isReady()
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
            if self.verifyUrl(_pasteboard) {
                print("Pasted text is a URL")
            }
            else {
                print("Not a url")
            }
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
    
//    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
//        if text == "\n" {
//            textView.resignFirstResponder()
//        }
//        return true
//    }


    @IBAction func buttonSaveNewReportTableViewController(sender: UIBarButtonItem) {
        
        let accessToken = NSUserDefaults.standardUserDefaults().objectForKey("currentUserAccountAccessToken")
        let headers = [
            "Authorization": "Bearer " + (accessToken! as! String)
        ]
        
        self.attemptNewReportSave(headers)
        
    }
    
    //
    // MARK: Table Overrides
    //
    override func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        
        if (tableView.restorationIdentifier == "formTableView") {
            let header: UITableViewHeaderFooterView = view as! UITableViewHeaderFooterView
            
            header.textLabel!.font = UIFont.systemFontOfSize(12)
            header.textLabel!.textColor = UIColor.colorDarkGray(0.5)
            
            header.contentView.backgroundColor = UIColor.colorBackground(1.00)
        }
        
    }
    
//    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    
//        let cell = tableView.dequeueReusableCellWithIdentifier("reportGroupTableViewCell", forIndexPath: indexPath) as! ReportGroupTableViewCell
//        
//        //
//        // Assign the organization logo to the UIImageView
//        //
//        cell.imageViewGroupLogo.tag = indexPath.row
//        
//        var organizationImageUrl:NSURL!
//        
//        if let thisOrganizationImageUrl: String = self.groups?["features"][indexPath.row]["properties"]["organization"]["properties"]["picture"].string {
//            organizationImageUrl = NSURL(string: thisOrganizationImageUrl)
//        }
//        
//        cell.imageViewGroupLogo.kf_indicatorType = .Activity
//        cell.imageViewGroupLogo.kf_showIndicatorWhenLoading = true
//        
//        cell.imageViewGroupLogo.kf_setImageWithURL(organizationImageUrl, placeholderImage: nil, optionsInfo: nil, progressBlock: nil, completionHandler: {
//            (image, error, cacheType, imageUrl) in
//            cell.imageViewGroupLogo.image = image
//            cell.imageViewGroupLogo.layer.cornerRadius = cell.imageViewGroupLogo.frame.size.width / 2
//            cell.imageViewGroupLogo.clipsToBounds = true
//        })
//        
//        //
//        // Assign the organization name to the UILabel
//        //
//        if let thisOrganizationName: String = self.groups?["features"][indexPath.row]["properties"]["organization"]["properties"]["name"].string {
//            cell.labelGroupName.text = thisOrganizationName
//        }
//        
//        // Assign existing groups to the group field
//        cell.switchSelectGroup.tag = indexPath.row
//        
//        if let _organization_id_number = self.groups?["features"][indexPath.row]["properties"]["organization_id"] {
//            
//            if self.tempGroups.contains("\(_organization_id_number)") {
//                cell.switchSelectGroup.on = true
//            }
//            else {
//                cell.switchSelectGroup.on = false
//            }
//            
//        }
        
        
//        return cell
        
//        return UITableViewCell()
//    }
    
    override func tableView(tableView:UITableView, numberOfRowsInSection section: Int) -> Int {
        
        var numberOfRows: Int = 0;
        
        switch (section) {
        case 0:
            numberOfRows = 2;
        case 1:
            numberOfRows = 1;
        case 2:
            
//            if self.groups == nil {
                numberOfRows = 1;
//            }
//            else {
//                numberOfRows = (self.groups?.count)!;
//            }
            
        default:
            numberOfRows = 0;
        }
        
        print("tableView::numberOfRowsInSection section \(section); numberOfRows \(numberOfRows)")
        
        return numberOfRows
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        var rowHeight:CGFloat = 44.0

        if (tableView.restorationIdentifier == "formTableView") {
            switch indexPath.section {
                case 0:

                    if (indexPath.row == 1 && self.hashtagTypeAhead.hidden == false) {
                        rowHeight = 288.0
                    }
                    else if (indexPath.row == 1 && self.hashtagTypeAhead.hidden == true) {
                        rowHeight = 124.0
                    }
                
                default:
                    rowHeight = 44.0
            }
        }
        
        
        return rowHeight
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        print("row tapped \(indexPath)")
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
                
                destinationNewReportGroupSelectorViewController.tempGroups = self.tempGroups
                destinationNewReportGroupSelectorViewController.delegate = self
                break
            default:
                break
        }

    }
    
    func onSetCoordinatesComplete(isFinished: Bool) {
        
        print("onSetCoordinatesComplete")
        
//        let thisMapView: MGLMapView = self.mapReportLocation
//        let thisMapCenterCoordinates: CLLocationCoordinate2D = self.userSelectedCoorindates
//        let thisMapCenter: Bool = true
//        
//        switch isFinished {
//        case true:
//            
//            // Disable UserTrackingMode.Follow action
//            mapReportLocation.showsUserLocation = false
//            
//            // Add an annotation to the map using the new coordinates
//            self.addLocationToMap(thisMapView, latitude: thisMapCenterCoordinates.latitude, longitude: thisMapCenterCoordinates.longitude, center: thisMapCenter)
//            
//            break
//            
//        default:
//            break
//            
//        }
        
        return
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadGroups() {
        
    }
    
    //
    // MARK: Custom functionality
    //
    func addDoneButtonOnKeyboard() {
        let doneToolbar: UIToolbar = UIToolbar(frame: CGRectMake(0, 0, 320, 50))
        doneToolbar.barStyle = UIBarStyle.Default
        
        let flexSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil)
        let done: UIBarButtonItem = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.Done, target: self, action: #selector(self.doneButtonAction))
        
        var items: [UIBarButtonItem]? = [UIBarButtonItem]()
        
        items?.append(flexSpace)
        items?.append(done)
        
        doneToolbar.items = items
        
        doneToolbar.sizeToFit()
        
        self.textareaReportComment.inputAccessoryView = doneToolbar
    }
    
    func doneButtonAction() {
        self.textareaReportComment.resignFirstResponder()
        self.textareaReportComment.resignFirstResponder()
    }
    
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
        self.textareaReportComment.resignFirstResponder()
        
        //
        // Make sure our view is scrolled to the top
        //
        self.tableView.setContentOffset(CGPointZero, animated: false)
        
        
        // Reset all fields
        self.imageReportImagePreviewIsSet = false

        self.userSelectedCoorindates = CLLocationCoordinate2D()
        
        self.labelReportLocationLatitude.text = "Confirm location"
        self.textareaReportComment.text = ""

//        buttonReportImage.hidden = false
//        buttonReportImageAddIcon.hidden = false

    }
    
    func finishedSavingWithError() {
        self.navigationItem.rightBarButtonItem?.enabled = true
    }

    func isReady() {}
    
//    func isReadyAfterRemove() {
//        buttonReportImage.hidden = false;
//        buttonReportImageAddIcon.hidden = false;
//    }
    
    func isUpdatingReportLocation() {
        print("isUpdatingReportLocation")
    }

//    func isReadyWithImage() {
//        buttonReportImage.hidden = true;
//        buttonReportImageAddIcon.hidden = true;
//    }

    func startLocationServices(sender: AnyObject) {
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
        buttonReportImageAddIcon.image = image
        imageReportImagePreviewIsSet = true
        self.dismissViewControllerAnimated(true, completion: {
//            self.isReadyWithImage()
            self.tableView.reloadData()
        })
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

    func textViewDidChange(textView: UITextView) {
        
        let _text: String = "\(textView.text)"
        
        if _text != "" && _text.characters.last! == "#" {
            self.hashtagSearchEnabled = true
            self.textareaReportComment.becomeFirstResponder()

            print("Hashtag Search: Found start of hashtag")
        }
        else if _text != "" && self.hashtagSearchEnabled == true && _text.characters.last! == " " {
            self.hashtagTypeAhead.hidden = true
            self.hashtagSearchEnabled = false
            self.dataSource.results = [String]()

            self.typeAheadHeight.constant = 0.0
            self.tableView.reloadData()
            self.textareaReportComment.becomeFirstResponder()

            print("Hashtag Search: Disabling search because space was entered")
            print("Hashtag Search: Timer reset to zero due to search termination (space entered)")
            self.hashtagSearchTimer.invalidate()

        }
        else if _text != "" && self.hashtagSearchEnabled == true {
            
            self.hashtagTypeAhead.hidden = false
            self.dataSource.results = [String]()

            self.typeAheadHeight.constant = 128.0
            self.tableView.reloadData()
            self.textareaReportComment.becomeFirstResponder()

            // Identify hashtag search
            //
            let _hashtag_identifier = _text.rangeOfString("#", options:NSStringCompareOptions.BackwardsSearch)
            if ((_hashtag_identifier) != nil) {
                let _hashtag_search: String! = _text.substringFromIndex((_hashtag_identifier?.endIndex)!)

                // Add what the user is typing to the top of the list
                //
                print("Hashtag Search: Performing search for \(_hashtag_search)")
                
                dataSource.results = ["\(_hashtag_search)"]
                dataSource.search = "\(_hashtag_search)"
                
                dataSource.numberOfRowsInSection(dataSource.results.count)
                
                self.hashtagTypeAhead.reloadData()
                
                // Execute the serverside search BUT wait a few milliseconds between
                // each character so we aren't returning inconsistent results to
                // the user
                //
                print("Hashtag Search: Timer reset to zero")
                self.hashtagSearchTimer.invalidate()
                
                print("Hashtag Search: Send this to search methods \(_hashtag_search) after delay expires")
                self.hashtagSearchTimer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(NewReportTableViewController.searchHashtags(_:)), userInfo: _hashtag_search, repeats: false)
                
            }

        }
    }
    
    func selectedValue(value: String) {
        
        // Add the hashtag to the text
        //
        self.textareaReportComment.text = "\(self.textareaReportComment.text)\(value)"
        self.tableView.reloadData()
        
        self.textareaReportComment.becomeFirstResponder()


        // Reset the search
        //
        self.hashtagTypeAhead.hidden = true
        self.hashtagSearchEnabled = false
        self.dataSource.results = [String]()
        
        self.typeAheadHeight.constant = 0.0
        self.tableView.reloadData()
        self.textareaReportComment.becomeFirstResponder()
        
        print("Hashtag Search: Timer reset to zero due to user selection")
        self.hashtagSearchTimer.invalidate()


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
        self.labelReportLocationLatitude.text = String(self.userSelectedCoorindates.longitude) + " " + String(self.userSelectedCoorindates.latitude)
        
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
            "geometry": geometryCollection,
            "state": "open"
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
        if (self.buttonReportImageAddIcon.image != nil) {
            
            Alamofire.upload(.POST, Endpoints.POST_IMAGE, headers: headers, multipartFormData: { multipartFormData in
                
                // import image to request
                if let imageData = UIImageJPEGRepresentation(self.buttonReportImageAddIcon.image!, 1) {
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

    func searchHashtags(timer: NSTimer) {
        
        let queryText: String! = "\(timer.userInfo!)"
        
        print("searchHashtags fired with \(queryText)")
        
        //
        // Send a request to the defined endpoint with the given parameters
        //
        let parameters = [
            "q": "{\"filters\": [{\"name\":\"tag\",\"op\":\"like\",\"val\":\"\(queryText)%\"}]}"
        ]
        
        Alamofire.request(.GET, Endpoints.GET_MANY_HASHTAGS, parameters: parameters)
            .responseJSON { response in
                
                switch response.result {
                case .Success(let value):

                    let _results = JSON(value)
                    print("_results \(_results)")
                    
                    for _result in _results["features"] {
                        print("_result \(_result.1["properties"]["tag"])")
                        let _tag = "\(_result.1["properties"]["tag"])"
                        self.dataSource.results.append(_tag)
                    }
                    
                    self.dataSource.numberOfRowsInSection(_results["features"].count)
                    
                    self.hashtagTypeAhead.reloadData()

                case .Failure(let error):
                    print(error)
                    break
                }
                
        }
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
                    self.groups = JSON(value)["features"]
                    
                    // Tell the refresh control to stop spinning
//                    self.refreshControl?.endRefreshing()
                    
//                    // Set status to complete
//                    self.status("complete")
                    
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

