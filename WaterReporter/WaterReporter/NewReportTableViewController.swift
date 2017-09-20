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

class NewReportTableViewController: UITableViewController, UIImagePickerControllerDelegate, UITextViewDelegate, UINavigationControllerDelegate, CLLocationManagerDelegate, MGLMapViewDelegate, NewReportLocationSelectorDelegate {
    
    
    //
    // MARK: @IBOutlets
    //
    @IBOutlet weak var navigationBarButtonSave: UIBarButtonItem!
    @IBOutlet var indicatorLoadingView: UIView!

    
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
    var reportDescription: String = ""
    
    var dataSource: HashtagTableView = HashtagTableView()
    var hashtagAutocomplete: [String] = [String]()
    var hashtagSearchTimer: NSTimer = NSTimer()
    var hashtagSearchEnabled: Bool = false
    
    var og_paste: String!
    var og_active: Bool = false
    var og_title: String!
    var og_description: String!
    var og_sitename: String!
    var og_type: String!
    var og_image: String!
    var og_url: String!

    
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
        
        //
        // Setup Navigation Bar
        //
        navigationBarButtonSave.target = self
        navigationBarButtonSave.action = #selector(buttonSaveNewReportTableViewController(_:))
        
        //
        // Load default list of groups into the form
        //
        self.attemptLoadUserGroups()
        
    }
    
    
    //
    // MARK: Advanced TextView Interactions
    //
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        
        // [text isEqualToString:[UIPasteboard generalPasteboard].string]
        let _pasteboard = UIPasteboard.generalPasteboard().string
        
        if (text == _pasteboard) {
            
            //
            // Step 1: Get the information being pasted
            //
            print("Pasting text", _pasteboard)
            
            if self.verifyUrl(_pasteboard) {
                //
                // Step 2: Check to see if the text being pasted is a link
                //
                let _url = NSURL(string: _pasteboard!)
                OpenGraph.fetch(_url!) { og, error in
                    print("Open Graph \(og)")
                    
                    self.og_paste = "\(_pasteboard!)"
                    
                    let _og_title_encoded = og?[.title]!
                    let _og_title = _og_title_encoded?.stringByDecodingHTMLEntities
                    self.og_title = "\(_og_title!)"
                    
                    let _og_description_encoded = og?[.description]!
                    let _og_description = _og_description_encoded?.stringByDecodingHTMLEntities
                    self.og_description = "\(_og_description!)"
                    
                    let _og_type = og?[.type]!
                    self.og_type = "\(_og_type!)"
                    
                    let _og_site_name = og?[.site_name]!
                    self.og_sitename = "\(_og_site_name!)"
                    
                    let _ogImage = og?[.image]!
                    print("_ogImage \(_ogImage!)")
                    
                    let _tmpImage = "\(_ogImage!)"
                    let _image = _tmpImage.characters.split{$0 == " "}.map(String.init)
                    
                    if _image.count >= 1 {
                        
                        var _imageUrl = _image[0]
                        
                        if let imageURLRange = _imageUrl.rangeOfString("?") {
                            _imageUrl.removeRange(imageURLRange.startIndex..<_imageUrl.endIndex)
                            self.og_image = "\(_imageUrl)"
                        }
                    }
                    
                    let _og_url = og?[.url]!
                    self.og_url = "\(_og_url!)"
                    
                    self.og_active = true
                    
                    // We need to wait for all other tasks to finish before
                    // executing the table reload
                    //
                    NSOperationQueue.mainQueue().addOperationWithBlock {
                        self.tableView.reloadData()
                    }
                    
                }
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

    func textViewDidBeginEditing(textView: UITextView) {
        textView.text = ""
    }

    
    func textViewDidChange(textView: UITextView) {
        
        let _text: String = "\(textView.text)"
        
        // Always make sure we are constantly copying what is entered into the
        // remote text field into this controller so that we can pass it along
        // to the report save methods.
        //
        self.reportDescription = _text
        
        if _text != "" && _text.characters.last! == "#" {
            self.hashtagSearchEnabled = true
            
            print("Hashtag Search: Found start of hashtag")
        }
        else if _text != "" && self.hashtagSearchEnabled == true && _text.characters.last! == " " {
            self.hashtagSearchEnabled = false
            self.dataSource.results = [String]()
            
            self.tableView.reloadData()
            
            print("Hashtag Search: Disabling search because space was entered")
            print("Hashtag Search: Timer reset to zero due to search termination (space entered)")
            self.hashtagSearchTimer.invalidate()
            
        }
        else if _text != "" && self.hashtagSearchEnabled == true {
            
            self.dataSource.results = [String]()

            self.tableView.reloadData()
            self.view.endEditing(false)
//            self.tableViewPostComments.reloadSections(IndexSet(integersIn: 0...0), with: UITableViewRowAnimation.top)
            
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
                
                self.tableView.reloadData()
                self.view.endEditing(false)
                
                // Execute the serverside search BUT wait a few milliseconds between
                // each character so we aren't returning inconsistent results to
                // the user
                //
                print("Hashtag Search: Timer reset to zero")
                self.hashtagSearchTimer.invalidate()
                
                print("Hashtag Search: Send this to search methods \(_hashtag_search) after delay expires")
                self.hashtagSearchTimer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(self.searchHashtags(_:)), userInfo: _hashtag_search, repeats: false)
                
            }
            
        }
        
    }
    
    
    //
    // MARK: Table Overrides
    //
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 3
    }
    
    override func tableView(tableView:UITableView, numberOfRowsInSection section: Int) -> Int {
        
        var numberOfRows: Int = 2
        
        if section == 1 {
            if self.dataSource.results != nil {
                let numberOfHashtags: Int = (self.dataSource.results.count)
                numberOfRows = numberOfHashtags
            }
        } else if section == 2 {
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
                cell.textviewReportDescription.delegate = self
                cell.textviewReportDescription.targetForAction(#selector(self.textViewDidChange(_:)), withSender: self)
                
                // Report Description > Hashtag Type Ahead
                //
                cell.tableViewHashtag.delegate = self.dataSource
                cell.tableViewHashtag.dataSource = self.dataSource
                
                if self.hashtagSearchEnabled == true {
                    cell.tableViewHashtag.hidden = false
                    cell.typeAheadHeight.constant = 128.0
                }
                else {
                    cell.tableViewHashtag.hidden = true
                    cell.typeAheadHeight.constant = 0.0
                }
                
                
                // Report Description > Open Graph
                //
                if self.og_active {
                    
                    cell.ogView.hidden = false
                    cell.ogViewHeightConstraint.constant = 256.0
                    
                    // Open Graph > Title
                    //
                    cell.ogTitle.text = self.og_title

                    // Open Graph > Description
                    //
                    cell.ogDescription.text = self.og_description

                    // Open Graph > Image
                    //
                    if self.og_image != "" {
                        
                        let ogImageURL:NSURL = NSURL(string: "\(self.og_image)")!
                        
                        cell.ogImage.kf_indicatorType = .Activity
                        cell.ogImage.kf_showIndicatorWhenLoading = true
                        
                        cell.ogImage.kf_setImageWithURL(ogImageURL, placeholderImage: nil, optionsInfo: nil, progressBlock: nil, completionHandler: {
                            (image, error, cacheType, imageUrl) in
                            cell.ogImage.image = image
                            
                            if (self.imageReportImagePreviewIsSet == false) {
                                self.reportImage = image
                                self.imageReportImagePreviewIsSet = true
                                self.tableView.reloadData()
                            }
                        })

                    }
                }
                else {
                    cell.ogViewHeightConstraint.constant = 0.0
                }
                
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
            print("do something with hashtags here")
        }
        else if indexPath.section == 2 {
            
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

        if indexPath.section == 0 {
            // if (indexPath.row == 1 && self.hashtagTypeAhead.hidden == false) {
            if (indexPath.row == 0) {
                if (self.og_active == false) {
                    if (self.hashtagSearchEnabled == true) {
                        rowHeight = 288.0
                    }
                    else if (self.hashtagSearchEnabled == false) {
                        rowHeight = 128.0
                    }
                }
                else if (self.og_active == true) {
                    if (self.hashtagSearchEnabled == true) {
                        rowHeight = 527.0
                    }
                    else if (self.hashtagSearchEnabled == false) {
                        rowHeight = 384.0
                    }
                }
                else {
                    rowHeight = 128.0
                }
            }
        }
        else if indexPath.section == 1 {
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
    // MARK: Custom Statuses
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
        // Make sure our view is scrolled to the top
        //
        self.tableView.setContentOffset(CGPointZero, animated: false)
        
        
        // Reset all fields
        self.imageReportImagePreviewIsSet = false

        self.userSelectedCoorindates = CLLocationCoordinate2D()
        
    }
    
    func finishedSavingWithError() {
        self.navigationItem.rightBarButtonItem?.enabled = true
    }

    
    //
    // MARK: Camera Functionality
    //
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
        self.imageReportImagePreviewIsSet = true
        
        // Refresh the table view to display the updated image data
        //
        self.dismissViewControllerAnimated(true, completion: {
            self.tableView.reloadData()
        })
    }
    

    //
    // MARK: Location Child Delegate
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
            if (self.og_active == false) {
                self.displayErrorMessage("Location Field Empty", message: "Please add a location to your report before saving")
                
                self.finishedSavingWithError()
                
                return
            }
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
        // REPORT DATE
        //
        let dateFormatter = NSDateFormatter()
        let date = NSDate()
        dateFormatter.dateStyle = NSDateFormatterStyle.MediumStyle
        dateFormatter.timeStyle = NSDateFormatterStyle.NoStyle
        let report_date: String = dateFormatter.stringFromDate(date)
        
        print("report_date \(report_date)")
        

        //
        // PARAMETERS
        //
        if self.reportDescription == "Write a few words about the photo or paste a link..." {
            self.reportDescription = ""
        }

        var parameters: [String: AnyObject] = [
            "report_description": self.reportDescription,
            "report_date": report_date,
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
        // OPEN GRAPH
        //
        var open_graph: [AnyObject] = [AnyObject]()

        if self.og_active {
            let _social = [
                "og_title": self.og_title,
                "og_type": self.og_type,
                "og_url": self.og_url,
                "og_image_url": self.og_image,
                "og_description": self.og_description
            ]
            open_graph.append(_social)
        }
        
        parameters["social"] = open_graph

        //
        // Make request
        //
        if (self.reportImage != nil) {
            
            Alamofire.upload(.POST, Endpoints.POST_IMAGE, headers: headers, multipartFormData: { multipartFormData in
                
                // import image to request
                if let imageData = UIImageJPEGRepresentation(self.reportImage!, 1) {
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
    
    func attemptLoadUserGroups() {
        
        // Set headers
        let _headers = self.buildRequestHeaders()
        
        if let userId = NSUserDefaults.standardUserDefaults().objectForKey("currentUserAccountUID") as? NSNumber {
            
            let GET_GROUPS_ENDPOINT = Endpoints.GET_USER_PROFILE + "\(userId)" + "/groups"
            
            Alamofire.request(.GET, GET_GROUPS_ENDPOINT, headers: _headers, encoding: .JSON).responseJSON { response in
                
                print("response.result \(response.result)")
                
                switch response.result {
                case .Success(let value):
//                    print("Request Success for Groups: \(value)")
                    
                    // Assign response to groups variable
                    self.groups = JSON(value)
                    
                    // Refresh the data in the table so the newest items appear
                    self.tableView.reloadData()
                    
                    break
                case .Failure(let error):
                    print("Request Failure: \(error)")

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

    //
    // MARK: Hashtag
    //
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
//                    print("self.dataSource >>>> _results \(_results)")
                    
                    for _result in _results["features"] {
                        print("_result \(_result.1["properties"]["tag"])")
                        let _tag = "\(_result.1["properties"]["tag"])"
                        self.dataSource.results.append(_tag)
                    }
                    
                    self.dataSource.numberOfRowsInSection(_results["features"].count)
                    
                    //self.tableView.reloadData()
                    
                case .Failure(let error):
                    print(error)
                    break
                }
                
        }
    }

}


// Very slightly adapted from http://stackoverflow.com/a/30141700/106244
// 99.99% Credit to Martin R!

// Mapping from XML/HTML character entity reference to character
// From http://en.wikipedia.org/wiki/List_of_XML_and_HTML_character_entity_references
private let characterEntities : [String: Character] = [
    
    // XML predefined entities:
    "&quot;"     : "\"",
    "&amp;"      : "&",
    "&apos;"     : "'",
    "&lt;"       : "<",
    "&gt;"       : ">",
    
    // HTML character entity references:
    "&nbsp;"     : "\u{00A0}",
    "&iexcl;"    : "\u{00A1}",
    "&cent;"     : "\u{00A2}",
    "&pound;"    : "\u{00A3}",
    "&curren;"   : "\u{00A4}",
    "&yen;"      : "\u{00A5}",
    "&brvbar;"   : "\u{00A6}",
    "&sect;"     : "\u{00A7}",
    "&uml;"      : "\u{00A8}",
    "&copy;"     : "\u{00A9}",
    "&ordf;"     : "\u{00AA}",
    "&laquo;"    : "\u{00AB}",
    "&not;"      : "\u{00AC}",
    "&shy;"      : "\u{00AD}",
    "&reg;"      : "\u{00AE}",
    "&macr;"     : "\u{00AF}",
    "&deg;"      : "\u{00B0}",
    "&plusmn;"   : "\u{00B1}",
    "&sup2;"     : "\u{00B2}",
    "&sup3;"     : "\u{00B3}",
    "&acute;"    : "\u{00B4}",
    "&micro;"    : "\u{00B5}",
    "&para;"     : "\u{00B6}",
    "&middot;"   : "\u{00B7}",
    "&cedil;"    : "\u{00B8}",
    "&sup1;"     : "\u{00B9}",
    "&ordm;"     : "\u{00BA}",
    "&raquo;"    : "\u{00BB}",
    "&frac14;"   : "\u{00BC}",
    "&frac12;"   : "\u{00BD}",
    "&frac34;"   : "\u{00BE}",
    "&iquest;"   : "\u{00BF}",
    "&Agrave;"   : "\u{00C0}",
    "&Aacute;"   : "\u{00C1}",
    "&Acirc;"    : "\u{00C2}",
    "&Atilde;"   : "\u{00C3}",
    "&Auml;"     : "\u{00C4}",
    "&Aring;"    : "\u{00C5}",
    "&AElig;"    : "\u{00C6}",
    "&Ccedil;"   : "\u{00C7}",
    "&Egrave;"   : "\u{00C8}",
    "&Eacute;"   : "\u{00C9}",
    "&Ecirc;"    : "\u{00CA}",
    "&Euml;"     : "\u{00CB}",
    "&Igrave;"   : "\u{00CC}",
    "&Iacute;"   : "\u{00CD}",
    "&Icirc;"    : "\u{00CE}",
    "&Iuml;"     : "\u{00CF}",
    "&ETH;"      : "\u{00D0}",
    "&Ntilde;"   : "\u{00D1}",
    "&Ograve;"   : "\u{00D2}",
    "&Oacute;"   : "\u{00D3}",
    "&Ocirc;"    : "\u{00D4}",
    "&Otilde;"   : "\u{00D5}",
    "&Ouml;"     : "\u{00D6}",
    "&times;"    : "\u{00D7}",
    "&Oslash;"   : "\u{00D8}",
    "&Ugrave;"   : "\u{00D9}",
    "&Uacute;"   : "\u{00DA}",
    "&Ucirc;"    : "\u{00DB}",
    "&Uuml;"     : "\u{00DC}",
    "&Yacute;"   : "\u{00DD}",
    "&THORN;"    : "\u{00DE}",
    "&szlig;"    : "\u{00DF}",
    "&agrave;"   : "\u{00E0}",
    "&aacute;"   : "\u{00E1}",
    "&acirc;"    : "\u{00E2}",
    "&atilde;"   : "\u{00E3}",
    "&auml;"     : "\u{00E4}",
    "&aring;"    : "\u{00E5}",
    "&aelig;"    : "\u{00E6}",
    "&ccedil;"   : "\u{00E7}",
    "&egrave;"   : "\u{00E8}",
    "&eacute;"   : "\u{00E9}",
    "&ecirc;"    : "\u{00EA}",
    "&euml;"     : "\u{00EB}",
    "&igrave;"   : "\u{00EC}",
    "&iacute;"   : "\u{00ED}",
    "&icirc;"    : "\u{00EE}",
    "&iuml;"     : "\u{00EF}",
    "&eth;"      : "\u{00F0}",
    "&ntilde;"   : "\u{00F1}",
    "&ograve;"   : "\u{00F2}",
    "&oacute;"   : "\u{00F3}",
    "&ocirc;"    : "\u{00F4}",
    "&otilde;"   : "\u{00F5}",
    "&ouml;"     : "\u{00F6}",
    "&divide;"   : "\u{00F7}",
    "&oslash;"   : "\u{00F8}",
    "&ugrave;"   : "\u{00F9}",
    "&uacute;"   : "\u{00FA}",
    "&ucirc;"    : "\u{00FB}",
    "&uuml;"     : "\u{00FC}",
    "&yacute;"   : "\u{00FD}",
    "&thorn;"    : "\u{00FE}",
    "&yuml;"     : "\u{00FF}",
    "&OElig;"    : "\u{0152}",
    "&oelig;"    : "\u{0153}",
    "&Scaron;"   : "\u{0160}",
    "&scaron;"   : "\u{0161}",
    "&Yuml;"     : "\u{0178}",
    "&fnof;"     : "\u{0192}",
    "&circ;"     : "\u{02C6}",
    "&tilde;"    : "\u{02DC}",
    "&Alpha;"    : "\u{0391}",
    "&Beta;"     : "\u{0392}",
    "&Gamma;"    : "\u{0393}",
    "&Delta;"    : "\u{0394}",
    "&Epsilon;"  : "\u{0395}",
    "&Zeta;"     : "\u{0396}",
    "&Eta;"      : "\u{0397}",
    "&Theta;"    : "\u{0398}",
    "&Iota;"     : "\u{0399}",
    "&Kappa;"    : "\u{039A}",
    "&Lambda;"   : "\u{039B}",
    "&Mu;"       : "\u{039C}",
    "&Nu;"       : "\u{039D}",
    "&Xi;"       : "\u{039E}",
    "&Omicron;"  : "\u{039F}",
    "&Pi;"       : "\u{03A0}",
    "&Rho;"      : "\u{03A1}",
    "&Sigma;"    : "\u{03A3}",
    "&Tau;"      : "\u{03A4}",
    "&Upsilon;"  : "\u{03A5}",
    "&Phi;"      : "\u{03A6}",
    "&Chi;"      : "\u{03A7}",
    "&Psi;"      : "\u{03A8}",
    "&Omega;"    : "\u{03A9}",
    "&alpha;"    : "\u{03B1}",
    "&beta;"     : "\u{03B2}",
    "&gamma;"    : "\u{03B3}",
    "&delta;"    : "\u{03B4}",
    "&epsilon;"  : "\u{03B5}",
    "&zeta;"     : "\u{03B6}",
    "&eta;"      : "\u{03B7}",
    "&theta;"    : "\u{03B8}",
    "&iota;"     : "\u{03B9}",
    "&kappa;"    : "\u{03BA}",
    "&lambda;"   : "\u{03BB}",
    "&mu;"       : "\u{03BC}",
    "&nu;"       : "\u{03BD}",
    "&xi;"       : "\u{03BE}",
    "&omicron;"  : "\u{03BF}",
    "&pi;"       : "\u{03C0}",
    "&rho;"      : "\u{03C1}",
    "&sigmaf;"   : "\u{03C2}",
    "&sigma;"    : "\u{03C3}",
    "&tau;"      : "\u{03C4}",
    "&upsilon;"  : "\u{03C5}",
    "&phi;"      : "\u{03C6}",
    "&chi;"      : "\u{03C7}",
    "&psi;"      : "\u{03C8}",
    "&omega;"    : "\u{03C9}",
    "&thetasym;" : "\u{03D1}",
    "&upsih;"    : "\u{03D2}",
    "&piv;"      : "\u{03D6}",
    "&ensp;"     : "\u{2002}",
    "&emsp;"     : "\u{2003}",
    "&thinsp;"   : "\u{2009}",
    "&zwnj;"     : "\u{200C}",
    "&zwj;"      : "\u{200D}",
    "&lrm;"      : "\u{200E}",
    "&rlm;"      : "\u{200F}",
    "&ndash;"    : "\u{2013}",
    "&mdash;"    : "\u{2014}",
    "&lsquo;"    : "\u{2018}",
    "&rsquo;"    : "\u{2019}",
    "&sbquo;"    : "\u{201A}",
    "&ldquo;"    : "\u{201C}",
    "&rdquo;"    : "\u{201D}",
    "&bdquo;"    : "\u{201E}",
    "&dagger;"   : "\u{2020}",
    "&Dagger;"   : "\u{2021}",
    "&bull;"     : "\u{2022}",
    "&hellip;"   : "\u{2026}",
    "&permil;"   : "\u{2030}",
    "&prime;"    : "\u{2032}",
    "&Prime;"    : "\u{2033}",
    "&lsaquo;"   : "\u{2039}",
    "&rsaquo;"   : "\u{203A}",
    "&oline;"    : "\u{203E}",
    "&frasl;"    : "\u{2044}",
    "&euro;"     : "\u{20AC}",
    "&image;"    : "\u{2111}",
    "&weierp;"   : "\u{2118}",
    "&real;"     : "\u{211C}",
    "&trade;"    : "\u{2122}",
    "&alefsym;"  : "\u{2135}",
    "&larr;"     : "\u{2190}",
    "&uarr;"     : "\u{2191}",
    "&rarr;"     : "\u{2192}",
    "&darr;"     : "\u{2193}",
    "&harr;"     : "\u{2194}",
    "&crarr;"    : "\u{21B5}",
    "&lArr;"     : "\u{21D0}",
    "&uArr;"     : "\u{21D1}",
    "&rArr;"     : "\u{21D2}",
    "&dArr;"     : "\u{21D3}",
    "&hArr;"     : "\u{21D4}",
    "&forall;"   : "\u{2200}",
    "&part;"     : "\u{2202}",
    "&exist;"    : "\u{2203}",
    "&empty;"    : "\u{2205}",
    "&nabla;"    : "\u{2207}",
    "&isin;"     : "\u{2208}",
    "&notin;"    : "\u{2209}",
    "&ni;"       : "\u{220B}",
    "&prod;"     : "\u{220F}",
    "&sum;"      : "\u{2211}",
    "&minus;"    : "\u{2212}",
    "&lowast;"   : "\u{2217}",
    "&radic;"    : "\u{221A}",
    "&prop;"     : "\u{221D}",
    "&infin;"    : "\u{221E}",
    "&ang;"      : "\u{2220}",
    "&and;"      : "\u{2227}",
    "&or;"       : "\u{2228}",
    "&cap;"      : "\u{2229}",
    "&cup;"      : "\u{222A}",
    "&int;"      : "\u{222B}",
    "&there4;"   : "\u{2234}",
    "&sim;"      : "\u{223C}",
    "&cong;"     : "\u{2245}",
    "&asymp;"    : "\u{2248}",
    "&ne;"       : "\u{2260}",
    "&equiv;"    : "\u{2261}",
    "&le;"       : "\u{2264}",
    "&ge;"       : "\u{2265}",
    "&sub;"      : "\u{2282}",
    "&sup;"      : "\u{2283}",
    "&nsub;"     : "\u{2284}",
    "&sube;"     : "\u{2286}",
    "&supe;"     : "\u{2287}",
    "&oplus;"    : "\u{2295}",
    "&otimes;"   : "\u{2297}",
    "&perp;"     : "\u{22A5}",
    "&sdot;"     : "\u{22C5}",
    "&lceil;"    : "\u{2308}",
    "&rceil;"    : "\u{2309}",
    "&lfloor;"   : "\u{230A}",
    "&rfloor;"   : "\u{230B}",
    "&lang;"     : "\u{2329}",
    "&rang;"     : "\u{232A}",
    "&loz;"      : "\u{25CA}",
    "&spades;"   : "\u{2660}",
    "&clubs;"    : "\u{2663}",
    "&hearts;"   : "\u{2665}",
    "&diams;"    : "\u{2666}",
    
]

extension String {
    
    /// Returns a new string made by replacing in the `String`
    /// all HTML character entity references with the corresponding
    /// character.
    public var stringByDecodingHTMLEntities: String {
        return decodeHTMLEntities().decodedString
    }
    
    /// Returns a tuple containing the string made by relpacing in the
    /// `String` all HTML character entity references with the corresponding
    /// character. Also returned is an array of offset information describing
    /// the location and length offsets for each replacement. This allows
    /// for the correct adjust any attributes that may be associated with
    /// with substrings within the `String`
    func decodeHTMLEntities() -> (decodedString: String, replacementOffsets: [(index: String.Index, offset: String.Index.Distance)]) {
        
        // ===== Utility functions =====
        
        // Record the index offsets of each replacement
        // This allows anyone to correctly adjust any attributes that may be
        // associated with substrings within the string
        var replacementOffsets: [(index: String.Index, offset: String.Index.Distance)] = []
        
        // Convert the number in the string to the corresponding
        // Unicode character, e.g.
        //    decodeNumeric("64", 10)   --> "@"
        //    decodeNumeric("20ac", 16) --> "€"
        func decodeNumeric(string : String, base : Int32) -> Character? {
            let code = UInt32(strtoul(string, nil, base))
            return Character(UnicodeScalar(code))
        }
        
        // Decode the HTML character entity to the corresponding
        // Unicode character, return `nil` for invalid input.
        //     decode("&#64;")    --> "@"
        //     decode("&#x20ac;") --> "€"
        //     decode("&lt;")     --> "<"
        //     decode("&foo;")    --> nil
        func decode(entity : String) -> Character? {
            if entity.hasPrefix("&#x") || entity.hasPrefix("&#X"){
                return decodeNumeric(entity.substringFromIndex(entity.startIndex.advancedBy(3)), base: 16)
            } else if entity.hasPrefix("&#") {
                return decodeNumeric(entity.substringFromIndex(entity.startIndex.advancedBy(2)), base: 10)
            } else {
                return characterEntities[entity]
            }
        }
        
        // ===== Method starts here =====
        
        var result = ""
        var position = startIndex
        
        // Find the next '&' and copy the characters preceding it to `result`:
        while let ampRange = self.rangeOfString("&", range: position ..< endIndex) {
            result += self[position ..< ampRange.startIndex]
            position = ampRange.startIndex
            
            // Find the next ';' and copy everything from '&' to ';' into `entity`
            if let semiRange = self.rangeOfString(";", range: position ..< endIndex) {
                let entity = self[position ..< semiRange.endIndex]
                if let decoded = decode(entity) {
                    
                    // Replace by decoded character:
                    result.append(decoded)
                    
                    // Record offset
                    let offset = (index: semiRange.endIndex, offset: 1 - position.distanceTo(semiRange.endIndex))
                    replacementOffsets.append(offset)
                    
                } else {
                    
                    // Invalid entity, copy verbatim:
                    result += entity
                    
                }
                position = semiRange.endIndex
            } else {
                // No matching ';'.
                break
            }
        }
        
        // Copy remaining characters to `result`:
        result += self[position ..< endIndex]
        
        // Return results
        return (decodedString: result, replacementOffsets: replacementOffsets)
    }
    
}
