//
//  NewPostTableViewController.swift
//  Water-Reporter
//
//  Created by Joshua Powell on 9/26/17.
//  Copyright © 2017 Viable Industries, L.L.C. All rights reserved.
//

import Alamofire
import CoreLocation
import Foundation
import OpenGraph
import SwiftyJSON
import UIKit

class NewPostTableViewController: UITableViewController, UITextViewDelegate, UIImagePickerControllerDelegate, NewReportLocationSelectorDelegate, UINavigationControllerDelegate {
    
    
    //
    // MARK: Variables
    //
    var loadingView: UIView!
    
    var groups: JSON?
    var tempGroups = [String]()
    var retainValues: Bool = false

    var hashtags: JSON?
    var hashtagSearchModeEnabled: Bool = false
    var hashtagSearchModeTypeDelay: NSTimer = NSTimer()
    var hashtagSearchModeResults: [String]! = [String]()
    var hashtagSearchModeSearch: String = ""
    
    var og_paste: String!
    var og_active: Bool = false
    var og_title: String!
    var og_description: String!
    var og_sitename: String!
    var og_type: String!
    var og_image: String!
    var og_url: String!
    
    var imageReportImagePreviewIsSet: Bool = false
    var userSelectedCoordinates: CLLocationCoordinate2D!

    
    var reportId: String!
    var report: JSON!



    //
    // MARK: IBOutlets
    //
    @IBOutlet weak var reportImage: UIButton!
    @IBOutlet weak var reportImageObject: UIImage!
    @IBOutlet weak var reportDescription: UITextView!
    
    @IBOutlet weak var reportHashtags: UIScrollView!
    
    @IBOutlet weak var hashtagSearchModeActivity: UIActivityIndicatorView!
    @IBOutlet weak var hashtagSearchModeLabel: UILabel!

    @IBOutlet weak var hashtagSearchModeResult_1: UIButton!
    @IBOutlet weak var hashtagSearchModeResult_2: UIButton!
    @IBOutlet weak var hashtagSearchModeResult_3: UIButton!
    @IBOutlet weak var hashtagSearchModeResult_4: UIButton!
    @IBOutlet weak var hashtagSearchModeResult_5: UIButton!
    @IBOutlet weak var hashtagSearchModeResult_6: UIButton!
    @IBOutlet weak var hashtagSearchModeResult_7: UIButton!
    @IBOutlet weak var hashtagSearchModeResult_8: UIButton!
    @IBOutlet weak var hashtagSearchModeResult_9: UIButton!
    @IBOutlet weak var hashtagSearchModeResult_10: UIButton!
    
    @IBOutlet var indicatorLoadingView: UIView!
    
    //
    // MARK: IBActions
    //
    @IBAction func hashtagSearchModeSetSelected(sender: UIButton) {
        
        print("NewPostTableViewController::hashtagSearchModeSetSelected \(sender.tag)")
        
        //
        // Before we execute the text replacement, make sure that the index is
        // not out of range
        //
        if ((self.hashtagSearchModeResults.count-1) >= sender.tag) {
            let _value = self.hashtagSearchModeResults[sender.tag]
            let _searchText = self.hashtagSearchModeSearch
            
            self.hashtagSearchModeSetSelected(_value, searchText: _searchText)
        }
        
    }

    @IBAction func launchNewReportLocationSelector(sender: UIButton) {
        
        self.retainValues = true;
        
        self.performSegueWithIdentifier("setLocationForNewReport", sender: sender)
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
    // MARK: Overrides
    //
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.attemptLoadUserGroups()
        
        self.addDoneButtonOnKeyboard()

        
        //
        // Make sure we are getting 'auto layout' specific sizes
        // otherwise any math we do will be messed up
        //
        self.view.setNeedsLayout()
        self.view.layoutIfNeeded()
        
        self.navigationItem.title = "New Report"
        self.navigationController?.delegate = self
        
        //
        //
        //
        if (self.report != nil) {
            
            self.navigationItem.title = "Edit Report"
            
            // Set existing comment to comment field
            //
            self.reportDescription.text = "\(self.report["properties"]["report_description"])"
            
            // Set existing image
            //
            print("IMAGES \(self.report["properties"]["images"])")

            if self.report["properties"]["images"].count >= 1 {

                let ogImageURL:NSURL = NSURL(string: "\(self.report["properties"]["images"][0]["properties"]["square"])")!
    
    
                self.reportImage.imageView!.kf_indicatorType = .Activity
                self.reportImage.imageView!.kf_showIndicatorWhenLoading = true
    
                self.reportImage.imageView!.kf_setImageWithURL(ogImageURL, placeholderImage: nil, optionsInfo: nil, progressBlock: nil, completionHandler: {
                    (image, error, cacheType, imageUrl) in
                    self.reportImageObject = image
                    self.reportImage.setImage(self.reportImageObject, forState: .Normal)
                    self.imageReportImagePreviewIsSet = true
                    
                    self.tableView.reloadData()
                })

                
            }
            
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
            
            self.userSelectedCoordinates = _coordinates

            if self.report["properties"]["social"].count >= 1 {
                
                print("OG \(self.report["properties"]["social"])")
                
                self.og_active = true
                
                self.og_title = "\(self.report["properties"]["social"][0]["properties"]["og_title"])"
                self.og_description = "\(self.report["properties"]["social"][0]["properties"]["og_description"])"
                self.og_image = "\(self.report["properties"]["social"][0]["properties"]["og_image_url"])"
                self.og_url = "\(self.report["properties"]["social"][0]["properties"]["og_url"])"
                
                self.imageReportImagePreviewIsSet = true
                
                self.tableView.reloadData()
                
            }
            
        }
        else {

            self.reportImage.addTarget(self, action: #selector(self.attemptOpenPhotoTypeSelector(_:)), forControlEvents: .TouchUpInside)
            
            if (self.reportImageObject != nil) {
                self.reportImage.imageView!.image = self.reportImageObject
            }
            else {
                self.reportImage.imageView!.image = UIImage(named: "icon--camera")
            }

        }

    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(true)
        
        if self.tabBarController?.selectedIndex != 2 && self.retainValues == false {
            
            //
            // When navigating away from this tab the Commons team wants this
            // form to clear out.
            //
            
            // Reset all fields
            self.imageReportImagePreviewIsSet = false
            self.reportDescription.text = "To get started, tap on the camera to add a photo, add comments, or link to content you'd like to share."

            self.reportImageObject = nil
            self.reportImage.setImage(UIImage(named: "icon--camera"), forState: .Normal)
            
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
            
            self.userSelectedCoordinates = nil
            
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        guard let segueId = segue.identifier else { return }
        
        switch segueId {
            
        case "setLocationForNewReport":
            
            let destinationNavigationViewController = segue.destinationViewController as! UINavigationController
            let destinationNewReportLocationSelectorViewController = destinationNavigationViewController.topViewController as! NewReportLocationSelector
            
            destinationNewReportLocationSelectorViewController.delegate = self
            destinationNewReportLocationSelectorViewController.userSelectedCoordinates = self.userSelectedCoordinates
            break
            
        default:
            break
        }
        
    }

    
    
    //
    // MARK: TextView Overrides
    //
    func textViewDidBeginEditing(textView: UITextView) {
        
        print("NewPostTableViewController::textViewDidBeginEditing with text = \(textView.text)")
        
        if textView.text == "To get started, tap on the camera to add a photo, add comments, or link to content you'd like to share." {
            textView.text = ""
        }
        
    }
    
    func textViewDidEndEditing(textView: UITextView) {

        print("NewPostTableViewController::textViewDidEndEditing with text = \"\(textView.text)\"")
        
        if textView.text == "" {
            textView.text = "To get started, tap on the camera to add a photo, add comments, or link to content you'd like to share."
        }

    }
    
    //
    // MARK
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
        
        self.reportDescription.inputAccessoryView = doneToolbar
    }
    
    func doneButtonAction() {
        self.reportDescription.resignFirstResponder()
        self.reportDescription.resignFirstResponder()
    }

    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {

        print("NewPostTableViewController::textView::shouldChangeTextInRange")
        
        let _searchText: String = "\(textView.text)"
        let _pasteboard = UIPasteboard.generalPasteboard().string
        
        if text == "\n" {
            
            textView.resignFirstResponder()
            
            return false
        }
        else if (text == _pasteboard) {
            
            if let checkedUrl = NSURL(string: _pasteboard!) {
                
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

                        if self.og_title != nil && self.og_description != nil {
                            self.reportDescription.text = "\(self.og_title)\n \(self.og_description)"
                        } else if self.og_title != nil && self.og_description == nil {
                            self.reportDescription.text = "\(self.og_title)"
                        } else if self.og_title == nil && self.og_description != nil {
                            self.reportDescription.text = "\(self.og_description)"
                        }
                        else {
                            self.reportDescription.text = ""
                        }
                        
                        if self.og_image != nil {
                            print("Load og_image from url paste")
                            
                            let ogImageURL:NSURL = NSURL(string: "\(self.og_image)")!
                            
                            
                            self.reportImage.imageView!.kf_indicatorType = .Activity
                            self.reportImage.imageView!.kf_showIndicatorWhenLoading = true

                            self.reportImage.imageView!.kf_setImageWithURL(ogImageURL, placeholderImage: nil, optionsInfo: nil, progressBlock: nil, completionHandler: {
                                (image, error, cacheType, imageUrl) in
                                self.reportImageObject = image
                                self.reportImage.setImage(self.reportImageObject, forState: .Normal)
                                self.imageReportImagePreviewIsSet = true
                                
                                self.tableView.reloadData()
                            })
                            
                        }
                        
                        self.tableView.reloadData()
                    }

                }
            }
            
        }
        else if _searchText != "" && _searchText.characters.last! == "#" {

            print("NewPostTableViewController::textView::shouldChangeTextInRange >>>> Hashtag start detected, activating hashtag search mode")

            self.hashtagSearchModeEnabled = true

            self.reportHashtags.hidden = false
            
            self.hashtagSearchModeActivity.hidden = false
            self.hashtagSearchModeLabel.hidden = false

        }
        else if _searchText != "" && self.hashtagSearchModeEnabled == true {

            if _searchText.characters.last! == " " {
                print("NewPostTableViewController::textView::shouldChangeTextInRange >>>> Hashtag end detected, disabling hashtag search mode and reset hashtag search")
                
                //
                // User entered a space, disable hashtag search mode, and
                // reset the hashtag search functionality.
                //
                self.hashtagSearchModeEnabled = true
                
                self.reportHashtags.hidden = true
                
                self.hashtagSearchModeActivity.hidden = true
                self.hashtagSearchModeLabel.hidden = true

                self.hashtagSearchModeTypeDelay.invalidate()
                self.hashtagSearchModeResults = [String]()
                
                self.reportHashtags.setContentOffset(CGPointZero, animated: false)
            }
            else {
                
                print("NewPostTableViewController::textView::shouldChangeTextInRange >>>> Hashtag active, searching remote hashtag dataset >>>> \(_searchText)")

                //
                // Hashtag Search Mode enabled and actively searching for
                // hashtags that match user input.
                //
                self.hashtagSearchModeResults = [String]()

                let _hashtag_identifier = _searchText.rangeOfString("#", options:NSStringCompareOptions.BackwardsSearch)

                if ((_hashtag_identifier) != nil) {
                    let _hashtag_search: String! = _searchText.substringFromIndex((_hashtag_identifier?.endIndex)!)
                    let _hashtag_search_with_replacement: String! = "\(_hashtag_search)\(text)"
                    
                    self.hashtagSearchModeLabel.text = "Searching for \"\(_hashtag_search_with_replacement)\""
                    self.hashtagSearchModeSearch = "#\(_hashtag_search_with_replacement)"

                    self.hashtagSearchModeTypeDelay.invalidate()

                    self.hashtagSearchModeTypeDelay = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(self.searchHashtags(_:)), userInfo: _hashtag_search_with_replacement, repeats: false)
                }
            }
        }

        return true
    }
    

    //
    // MARK: Table Overrides
    //
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 3
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {

        var _headerTitle = ""
        
        switch section {
            case 2:
                _headerTitle = "Share with your groups"
                break
            default:
                _headerTitle = "" // No change
                break
        }
        
        return _headerTitle
    }
    
    override func tableView(tableView:UITableView, numberOfRowsInSection section: Int) -> Int {
        
        var numberOfRows: Int = 1
        
        switch section {
            case 0:
                
                if self.og_active == true {
                    numberOfRows = 1
                }
                else {
                    numberOfRows = 0
                }
                
                break
            case 1:
                numberOfRows = 1
                break
            case 2:
                if self.groups != nil {
                    
                    let _numberOfAvailableFeatures: Int = (self.groups?["features"].count)!
                    
                    numberOfRows = (_numberOfAvailableFeatures)
                    
                }
                break
            default:
                numberOfRows = 1
                break
        }
        
        return numberOfRows
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        let _section: Int = indexPath.section
        let _row: Int = indexPath.row
        
        if _section == 0 && _row == 0 {
            if (self.og_active == true) {
                return 287.0
            }
            return 0.0
        }
        else if _section == 1 && _row == 0 {
            return 44.0
        }
        else if _section == 2 {
            return 72.0
        }

        return 44.0
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let _section: Int = indexPath.section
        let _row: Int = indexPath.row
        
        if (self.reportImageObject != nil) {
            self.reportImage.imageView!.image = self.reportImageObject
        }
        else {
            self.reportImage.imageView!.image = UIImage(named: "icon--camera")
        }

        
        if _section == 0 && _row == 0 {
            let cell = tableView.dequeueReusableCellWithIdentifier("newReportContentTableViewCell", forIndexPath: indexPath) as! NewReportContentTableViewCell
            
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
                            self.reportImageObject = image
                            self.reportImage.imageView?.image = self.reportImageObject
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
        else if _section == 1 && _row == 0 {
            let cell = tableView.dequeueReusableCellWithIdentifier("newReportLocationTableViewCell", forIndexPath: indexPath) as! NewReportLocationTableViewCell
            
            print("Location Row")
            
            // Display location selection map when Confirm Location button is
            // tapped/touched
            //
            cell.buttonChangeLocation.addTarget(self, action: #selector(self.launchNewReportLocationSelector(_:)), forControlEvents: .TouchUpInside)
            
            
            // Update the text display for the user selected coordinates when
            // the self.userSelectedCoordinates variable is not empty
            //
            if self.userSelectedCoordinates != nil {
                cell.labelLocation.text = String(self.userSelectedCoordinates.longitude) + " " + String(self.userSelectedCoordinates.latitude)
            }
            else {
                cell.labelLocation.text = "Confirm location"
            }
            
            return cell
        }
        else if _section == 2 {
            
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
        
        //
        // TEMPORARY
        //
        print("returning empty section \(_section) and row \(_row)")
        return UITableViewCell()
    }
    

    //
    // MARK: Hashtag Functionality
    //
    func searchHashtags(timer: NSTimer) {
        
        let queryText: String! = "\(timer.userInfo!)"
        
        print("searchHashtags fired with \(queryText)")
        
        //
        // Send a request to the defined endpoint with the given parameters
        //
        let parameters = [
            "q": "{\"filters\": [{\"name\":\"tag\",\"op\":\"ilike\",\"val\":\"\(queryText)%\"}], \"order_by\":[{\"field\":\"tag\",\"direction\":\"asc\"}]}"
        ]
        
        Alamofire.request(.GET, Endpoints.GET_MANY_HASHTAGS, parameters: parameters)
            .responseJSON { response in
                
                switch response.result {
                    case .Success(let value):
                        
                        print("NewPostTableViewController::searchHashtags results = \(value)")

                        let _results = JSON(value)
                        
                        for _result in _results["features"] {
                            print("_result \(_result.1["properties"]["tag"])")
                            let _tag = "#\(_result.1["properties"]["tag"])"
                            self.hashtagSearchModeResults.append(_tag)
                        }
                        
                        self.hashtagSearchModeActivity.hidden = true
                        self.hashtagSearchModeLabel.hidden = true
                        
                        self.hashtagSearchModePopulateButtons(self.hashtagSearchModeResults)

                    case .Failure(let error):
                        print(error)
                        break
                }
                
        }
    }
    
    
    //
    // MARK: Hashtag Functionality
    //
    func hashtagSearchModePopulateButtons(results: [String]) {
        
        print("NewPostTableViewController::hashtagSearchModePopulateButtons \(results), \(results.count)")
        
        if results.count >= 10 {
            self.hashtagSearchModeResult_10.setTitle("\(self.hashtagSearchModeResults[9])", forState: .Normal)
        }

        if results.count >= 9 {
            self.hashtagSearchModeResult_9.setTitle("\(self.hashtagSearchModeResults[8])", forState: .Normal)
        }

        if results.count >= 8 {
            self.hashtagSearchModeResult_8.setTitle("\(self.hashtagSearchModeResults[7])", forState: .Normal)
        }

        if results.count >= 7 {
            self.hashtagSearchModeResult_7.setTitle("\(self.hashtagSearchModeResults[6])", forState: .Normal)
        }
        
        if results.count >= 6 {
            self.hashtagSearchModeResult_6.setTitle("\(self.hashtagSearchModeResults[5])", forState: .Normal)
        }

        if results.count >= 5 {
            self.hashtagSearchModeResult_5.setTitle("\(self.hashtagSearchModeResults[4])", forState: .Normal)
        }
        
        if results.count >= 4 {
            self.hashtagSearchModeResult_4.setTitle("\(self.hashtagSearchModeResults[3])", forState: .Normal)
        }
        
        if results.count >= 3 {
            self.hashtagSearchModeResult_3.setTitle("\(self.hashtagSearchModeResults[2])", forState: .Normal)
        }
        
        if results.count >= 2 {
            self.hashtagSearchModeResult_2.setTitle("\(self.hashtagSearchModeResults[1])", forState: .Normal)
        }
        
        if results.count >= 1 {
            self.hashtagSearchModeResult_1.setTitle("\(self.hashtagSearchModeResults[0])", forState: .Normal)
        }

    }
    
    func hashtagSearchModeSetSelected(value: String, searchText: String) {

        let _selection = "\(value)"

        print("Hashtag Selected, now we need to update the textview with selected \(value) and search text \(searchText) so that it makes sense with \(self.reportDescription.text)")

        let _temporaryCopy = self.reportDescription.text

        let _updatedDescription = _temporaryCopy.stringByReplacingOccurrencesOfString(searchText, withString: _selection, options: NSStringCompareOptions.LiteralSearch, range: nil)

        print("Updated Text \(_updatedDescription)")

        // Add the hashtag to the text
        //
        self.reportDescription.text = "\(_updatedDescription)"

        // Reset the search
        //
        self.hashtagSearchModeEnabled = false

        self.reportHashtags.hidden = true
        self.hashtagSearchModeTypeDelay.invalidate()
        self.hashtagSearchModeResults = [String]()

        self.reportHashtags.setContentOffset(CGPointZero, animated: false)

        self.hashtagSearchModeResult_1.setTitle("", forState: .Normal)
        self.hashtagSearchModeResult_2.setTitle("", forState: .Normal)
        self.hashtagSearchModeResult_3.setTitle("", forState: .Normal)
        self.hashtagSearchModeResult_4.setTitle("", forState: .Normal)
        self.hashtagSearchModeResult_5.setTitle("", forState: .Normal)
        self.hashtagSearchModeResult_6.setTitle("", forState: .Normal)
        self.hashtagSearchModeResult_7.setTitle("", forState: .Normal)
        self.hashtagSearchModeResult_8.setTitle("", forState: .Normal)
        self.hashtagSearchModeResult_9.setTitle("", forState: .Normal)
        self.hashtagSearchModeResult_10.setTitle("", forState: .Normal)
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

    @IBAction func attemptNewReportSave(sender: UIBarButtonItem) {
        
        let headers = self.buildRequestHeaders()

        //
        // Error Check for Geometry
        //
        var geometryCollection: [String: AnyObject] = [
            "type": "GeometryCollection"
        ]
        
        if (self.userSelectedCoordinates != nil) {
            
            var geometry: [String: AnyObject] = [
                "type": "Point"
            ]
            
            let coordinates: Array = [
                self.userSelectedCoordinates.longitude,
                self.userSelectedCoordinates.latitude
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
        if self.reportDescription == "To get started, tap on the camera to add a photo, add comments, or link to content you'd like to share." {
            self.reportDescription.text = ""
        }
        
        var parameters: [String: AnyObject] = [
            "report_description": self.reportDescription.text,
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
        if (self.report != nil) {
            
            let _endpoint = Endpoints.POST_REPORT + "/\(self.reportId)"

            print("WE ARE EDITING ... SAVE")
            
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

        } else if (self.reportImageObject != nil) {
            
            Alamofire.upload(.POST, Endpoints.POST_IMAGE, headers: headers, multipartFormData: { multipartFormData in
                
                // import image to request
                if let imageData = UIImageJPEGRepresentation(self.reportImageObject!, 1) {
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
    // MARK: Location Child Delegate
    //
    func sendCoordinates(coordinates: CLLocationCoordinate2D) {
        print("PARENT:sendCoordinates see \(coordinates)")
        
        // Pass off coorindates to the self.userSelectedCoordinates
        //
        self.userSelectedCoordinates = coordinates
        
        // Update the display of the returned coordinates in the "Confirm
        // Location" table view cell label
        //
        self.tableView.reloadData()
    }
    
    func onSetCoordinatesComplete(isFinished: Bool) {
        self.retainValues = false
        return
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
        
        print("NewPostTableViewController::imagePickerController::didFinishPickingImage")
        
        // Change the default camera icon to a preview of the image the user
        // has selected to be their report image.
        //
        self.reportImageObject = image
        self.reportImage.setImage(self.reportImageObject, forState: .Normal)
        self.imageReportImagePreviewIsSet = true
        
        // Refresh the table view to display the updated image data
        //
        self.dismissViewControllerAnimated(true, completion: {
            self.tableView.reloadData()
        })
        
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
        self.reportDescription.text = "To get started, tap on the camera to add a photo, add comments, or link to content you'd like to share."
        self.reportImageObject = nil
        self.reportImage.imageView?.image = UIImage(named: "icon--camera")
        self.reportImage.setImage(UIImage(named: "icon--camera"), forState: .Normal)

        
        self.og_paste = ""
        self.og_active = false
        self.og_title = ""
        self.og_description = ""
        self.og_sitename = ""
        self.og_type = ""
        self.og_image = ""
        self.og_url = ""
        
        self.retainValues = false
        
        self.tempGroups = [String]()
        
        self.tableView.reloadData()
        
        self.userSelectedCoordinates = nil
        
    }

    func finishedSavingWithError() {
        self.navigationItem.rightBarButtonItem?.enabled = true
    }

}






