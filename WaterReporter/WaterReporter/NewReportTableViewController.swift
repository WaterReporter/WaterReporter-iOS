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
    var reportDescription: String = "Write a few words about the photo or paste a link..."
    
    var hashtagAutocomplete: [String] = [String]()
    var hashtagSearchEnabled: Bool = false
    var dataSource: HashtagTableView = HashtagTableView()
    var hashtagSearchTimer: NSTimer = NSTimer()
    
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

        //
        // Load default list of groups into the form
        //
        self.attemptLoadUserGroups()
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(true)
        
        if self.tabBarController?.selectedIndex != 2 {

            //
            // When navigating away from this tab the Commons team wants this
            // form to clear out.
            //
            
            // Reset all fields
            self.imageReportImagePreviewIsSet = false
            self.reportDescription = "Write a few words about the photo or paste a link..."
            self.reportImage = nil
            
            self.og_paste = ""
            self.og_active = false
            self.og_title = ""
            self.og_description = ""
            self.og_sitename = ""
            self.og_type = ""
            self.og_image = ""
            self.og_url = ""
            
            self.tempGroups = [String]()
            
            self.tableView.reloadData()
            
            self.userSelectedCoorindates = nil

        }
        
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
        
        self.dataSource.parent = self

        
        //
        // Setup Navigation Bar
        //
        navigationBarButtonSave.target = self
        navigationBarButtonSave.action = #selector(buttonSaveNewReportTableViewController(_:))
        
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
            
//        _pasteboard =  _pasteboard!.stringByRemovingPercentEncoding!.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!

        if let checkedUrl = NSURL(string: _pasteboard!) {

//            if self.verifyUrl(_pasteboard) && self.imageReportImagePreviewIsSet == false {
                //
                // Step 2: Check to see if the text being pasted is a link
                //
                OpenGraph.fetch(checkedUrl) { og, error in
                    print("Open Graph \(og)")
                    
                    self.og_paste = "\(checkedUrl)"
                    
                    if og?[.title] != nil {
                        let _og_title = og?[.title]!.stringByDecodingHTMLEntities
                        self.og_title = "\(_og_title!)"
                    }
                    else {
                        self.og_title = ""
                    }
                    
                    if og?[.description] != nil {
                        let _og_description_encoded = og?[.description]!
                        let _og_description = _og_description_encoded?.stringByDecodingHTMLEntities
                        self.og_description = "\(_og_description!)"
                        self.reportDescription = "\(_og_description!)"

                    }
                    else {
                        self.og_description = ""
                    }

                    if og?[.type] != nil {
                        let _og_type = og?[.type]!
                        self.og_type = "\(_og_type!)"
                    }
                    else {
                        self.og_type = ""
                    }
                    
                    
                    if og?[.image] != nil {
                        let _ogImage = og?[.image]!
                        print("_ogImage \(_ogImage!)")
                    
                        if let imageURL = NSURL(string: _ogImage!) {
                            self.og_image = "\(imageURL)"
                        }
                        else {
                            let _tmpImage = "\(_ogImage!)"
                            let _image = _tmpImage.characters.split{$0 == " "}.map(String.init)
                            
                            if _image.count >= 1 {
                                
                                var _imageUrl = _image[0]
                                
                                if let imageURLRange = _imageUrl.rangeOfString("?") {
                                    _imageUrl.removeRange(imageURLRange.startIndex..<_imageUrl.endIndex)
                                    self.og_image = "\(_imageUrl)"
                                }
                            }
                        }
                    }
                    else {
                        self.og_image = ""
                    }
                    
                    if og?[.url] != nil {
                        let _og_url = og?[.url]!
                        self.og_url = "\(_og_url!)"
                    }
                    else {
                        self.og_url = ""
                    }
                    
                    if self.og_url != "" && self.og_image != "" {
                        self.og_active = true
                    }
                    
                    // We need to wait for all other tasks to finish before
                    // executing the table reload
                    //
                    NSOperationQueue.mainQueue().addOperationWithBlock {
                        self.tableView.reloadData()
                    }
                    
                }
            }

            return true
        }
        
        return false
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

        if textView.text == "Write a few words about the photo or paste a link..." {
            textView.text = ""
        }
        
    }

    
    func textViewDidChange(textView: UITextView) {
        
        let _text: String = "\(textView.text)"
//        let _index = NSIndexPath.init(forRow: 0, inSection: 0)

        // Always make sure we are constantly copying what is entered into the
        // remote text field into this controller so that we can pass it along
        // to the report save methods.
        //
        self.reportDescription = _text
        
//        if _text != "" && _text.characters.last! == "#" {
//            self.hashtagSearchEnabled = true
//            
//            print("Hashtag Search: Found start of hashtag")
//        }
//        else if _text != "" && self.hashtagSearchEnabled == true && _text.characters.last! == " " {
//            self.hashtagSearchEnabled = false
//            self.dataSource.results = [String]()
//            
////            self.tableView.reloadRowsAtIndexPaths([_index], withRowAnimation: UITableViewRowAnimation.None)
//            
//            print("Hashtag Search: Disabling search because space was entered")
//            print("Hashtag Search: Timer reset to zero due to search termination (space entered)")
//            self.hashtagSearchTimer.invalidate()
//            
//        }
//        else if _text != "" && self.hashtagSearchEnabled == true {
//            
//            self.dataSource.results = [String]()
//
////            self.tableView.reloadRowsAtIndexPaths([_index], withRowAnimation: UITableViewRowAnimation.None)
//            
//            // Identify hashtag search
//            //
//            let _hashtag_identifier = _text.rangeOfString("#", options:NSStringCompareOptions.BackwardsSearch)
//            if ((_hashtag_identifier) != nil) {
//                let _hashtag_search: String! = _text.substringFromIndex((_hashtag_identifier?.endIndex)!)
//                
//                // Add what the user is typing to the top of the list
//                //
//                print("Hashtag Search: Performing search for \(_hashtag_search)")
//                
//                dataSource.results = ["\(_hashtag_search)"]
//                dataSource.search = "\(_hashtag_search)"
//                
//                dataSource.numberOfRowsInSection(dataSource.results.count)
//                
////                self.tableView.reloadRowsAtIndexPaths([_index], withRowAnimation: UITableViewRowAnimation.None)
//                
//                // Execute the serverside search BUT wait a few milliseconds between
//                // each character so we aren't returning inconsistent results to
//                // the user
//                //
//                print("Hashtag Search: Timer reset to zero")
//                self.hashtagSearchTimer.invalidate()
//                
//                print("Hashtag Search: Send this to search methods \(_hashtag_search) after delay expires")
////                self.hashtagSearchTimer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(self.searchHashtags(_:)), userInfo: _hashtag_search, repeats: false)
//                
//            }
//            
//        }
        
    }
    
    
    //
    // MARK: Custom TextView Functionality
    //
    func focusTextView() {
    }
    
    
    //
    // MARK: Table Overrides
    //
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(tableView:UITableView, numberOfRowsInSection section: Int) -> Int {
        
        var numberOfRows: Int = 2
        
        if section == 0 {
            numberOfRows = 2
//            if self.dataSource.results != nil {
//                let numberOfHashtags: Int = (self.dataSource.results.count)
//                numberOfRows = numberOfHashtags
//            }
        } else if section == 1 {
            if self.groups != nil {
                
                let numberOfGroups: Int = (self.groups?["features"].count)!
                
                numberOfRows = (numberOfGroups)
                
            }
        }
        
        return numberOfRows
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        self.view.endEditing(false)

        if indexPath.section == 0 {
            if indexPath.row == 0 {
                let cell = tableView.dequeueReusableCellWithIdentifier("newReportContentTableViewCell", forIndexPath: indexPath) as! NewReportContentTableViewCell
                
                // Report Image
                //
                cell.buttonReportAddImage.addTarget(self, action: #selector(NewReportTableViewController.attemptOpenPhotoTypeSelector(_:)), forControlEvents: .TouchUpInside)
                
                if (self.reportImage != nil) {
                    cell.imageReportImage.image = self.reportImage
                }
                else {
                    cell.imageReportImage.image = UIImage(named: "icon--camera")
                }
                
                // Report Description
                //
                if self.reportDescription != "" {
                    cell.textviewReportDescription.text = self.reportDescription
                }
                
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
                    cell.ogView.hidden = true
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
                else {
                    cell.labelLocation.text = "Confirm location"
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
        self.reportDescription = "Write a few words about the photo or paste a link..."
        self.reportImage = nil
        
        self.og_paste = ""
        self.og_active = false
        self.og_title = ""
        self.og_description = ""
        self.og_sitename = ""
        self.og_type = ""
        self.og_image = ""
        self.og_url = ""
        
        self.tempGroups = [String]()

        self.tableView.reloadData()

        self.userSelectedCoorindates = nil
        
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
                    
                    let _index = NSIndexPath.init(forRow: 0, inSection: 0)
                    
                    self.tableView.reloadRowsAtIndexPaths([_index], withRowAnimation: UITableViewRowAnimation.None)

                case .Failure(let error):
                    print(error)
                    break
                }
                
        }
    }
    
    
    func selectedValue(value: String, searchText: String) {
        
        let _index = NSIndexPath.init(forRow: 0, inSection: 0)
        
        let _selection = "\(value)"

        print("Hashtag Selected, now we need to update the textview with selected \(value) and search text \(searchText) so that it makes sense with \(self.reportDescription)")
        
        let _temporaryCopy = self.reportDescription
        
        let _updatedDescription = _temporaryCopy.stringByReplacingOccurrencesOfString(searchText, withString: _selection, options: NSStringCompareOptions.LiteralSearch, range: nil)
        
        print("Updated Text \(_updatedDescription)")

        // Add the hashtag to the text
        //
        self.reportDescription = "\(_updatedDescription)"
        
        // Reset the search
        //
        self.hashtagSearchEnabled = false
        self.dataSource.results = [String]()
        
        self.tableView.reloadRowsAtIndexPaths([_index], withRowAnimation: UITableViewRowAnimation.None)

        print("Hashtag Search: Timer reset to zero due to user selection")
        self.hashtagSearchTimer.invalidate()


    }

}


