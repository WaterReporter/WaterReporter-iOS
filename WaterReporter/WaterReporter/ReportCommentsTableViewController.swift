//
//  ReportCommentsTableViewController.swift
//  Water-Reporter
//
//  Created by Joshua Powell on 10/2/17.
//  Copyright © 2017 Viable Industries, L.L.C. All rights reserved.
//

import Alamofire
import Foundation
import OpenGraph
import SwiftyJSON
import UIKit

class ReportCommentsTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    
    //
    // MARK: Variables
    //
    let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
    
    var report:AnyObject!
    var reportId:String!
    var comments: JSON?
    var page: Int = 1
    
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

    
    //
    // MARK: @IBOutlets
    //
    @IBOutlet weak var viewBottomConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var viewNewComment: UIView!
    @IBOutlet weak var buttonNewCommentTextView: UITextView!
    @IBOutlet weak var buttonNewCommentImage: UIButton!
    @IBOutlet weak var buttonNewCommentSubmit: UIButton!
    @IBOutlet weak var viewActionTakenBanner: UIView!
    @IBOutlet weak var reportImageObject: UIImage!

    @IBOutlet weak var indicatorLoadingCommentsLabel: UILabel!
    @IBOutlet var indicatorLoadingView: UIView!
    @IBOutlet weak var indicatorLoadingComments: UIActivityIndicatorView!
    @IBOutlet weak var actionTakenBannerHeight: NSLayoutConstraint!

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

    //
    // MARK: @IBActions
    //
    @IBAction func loadCommentOwnerProfile(sender: UIButton) {
        
        let nextViewController = self.storyBoard.instantiateViewControllerWithIdentifier("ProfileTableViewController") as! ProfileTableViewController
        
        let _userId = self.comments!["features"][sender.tag]["properties"]["owner"]["id"]
        let _userObject = self.comments!["features"][sender.tag]["properties"]["owner"]
        
        nextViewController.userObject = _userObject
        nextViewController.userId = "\(_userId)"
        
        self.navigationController?.pushViewController(nextViewController, animated: true)
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

    
    //
    // MARK: View Overrides
    //
    override func viewDidLoad() {
        print("NewCommentTableViewController::viewDidLoad")
        
        //
        // Display loading indicator
        //
        self.loading()
        
        //
        // Setup keyboard show/hide functionality
        //
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
        
        //
        // Enable scroll to top of UITableView when title
        // bar is tapped
        //
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        self.tableView.scrollEnabled = true
        self.tableView.scrollsToTop = true
        
        self.tableView.rowHeight = UITableViewAutomaticDimension;
        self.tableView.estimatedRowHeight = 640.0;
        
        self.navigationController?.delegate = self
        
        //
        // Setup pull to refresh functionality for our TableView
        //
//        self.tableView.refreshControl?.addTarget(self, action: #selector(ReportCommentsTableViewController.refreshTableView(_:)), forControlEvents: UIControlEvents.ValueChanged)

    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
        
        //
        //
        //
        if let reportIdNumber = report?.objectForKey("id") as? NSNumber {
            reportId = "\(reportIdNumber)"
        }
        
        //
        // Display loading indicator
        //
        self.loading()
        
        //
        //
        //
        if reportId != "" {
            self.page = 1
            self.attemptGetReportComments(reportId)
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    //
    // MARK: TextView Overrides
    //
    func textViewDidBeginEditing(textView: UITextView) {
        
        print("NewCommentTableViewController::textViewDidBeginEditing with text = \(textView.text)")
        
        if textView.text == "Begin typing your comment" {
            textView.text = ""
        }
        
    }
    
    func textViewDidEndEditing(textView: UITextView) {
        
        print("NewCommentTableViewController::textViewDidEndEditing with text = \"\(textView.text)\"")
        
        if textView.text == "" {
            textView.text = "Begin typing your comment"
        }
        
    }

    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        
        print("NewCommentTableViewController::textView::shouldChangeTextInRange")
        
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
                            self.buttonNewCommentTextView.text = "\(self.og_title)\n \(self.og_description)"
                        } else if self.og_title != nil && self.og_description == nil {
                            self.buttonNewCommentTextView.text = "\(self.og_title)"
                        } else if self.og_title == nil && self.og_description != nil {
                            self.buttonNewCommentTextView.text = "\(self.og_description)"
                        }
                        else {
                            self.buttonNewCommentTextView.text = ""
                        }
                        
                        if self.og_image != nil {
                            print("Load og_image from url paste")
                            
                            let ogImageURL:NSURL = NSURL(string: "\(self.og_image)")!
                            
                            
                            self.buttonNewCommentImage.imageView!.kf_indicatorType = .Activity
                            self.buttonNewCommentImage.imageView!.kf_showIndicatorWhenLoading = true
                            
                            self.buttonNewCommentImage.imageView!.kf_setImageWithURL(ogImageURL, placeholderImage: nil, optionsInfo: nil, progressBlock: nil, completionHandler: {
                                (image, error, cacheType, imageUrl) in
                                self.reportImageObject = image
                                self.buttonNewCommentImage.setImage(self.reportImageObject, forState: .Normal)
                                
                            })
                            
                        }
                        
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
    

    func keyboardWillShow(notification:NSNotification) {
        print("NewCommentTableViewController::keyboardWillShow")
        
        self.adjustingHeight(true, notification: notification)
    }
    
    func keyboardWillHide(notification:NSNotification) {
        print("NewCommentTableViewController::keyboardWillHide")
        
        self.adjustingHeight(false, notification: notification)
    }
    
    func adjustingHeight(show:Bool, notification:NSNotification) {
        
        print("NewCommentTableViewController::adjustingHeight")
        
        var userInfo = notification.userInfo!
        
        let keyboardFrame: CGRect = (userInfo[UIKeyboardFrameBeginUserInfoKey] as! NSValue).CGRectValue()
        
        let animationDurarion = userInfo[UIKeyboardAnimationDurationUserInfoKey] as! NSTimeInterval
        
        let changeInHeight = (keyboardFrame.height-48) * (show ? 1 : -1)
        
        UIView.animateWithDuration(animationDurarion, animations: { () -> Void in
            self.viewBottomConstraint.constant += changeInHeight
        })
        
    }
    
    
    //
    // MARK: Table View Overrides
    //
    //
    // MARK:
    //
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if self.comments == nil {
            return 1
        }
        
        return (self.comments?["features"].count)!
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("SingleReportComment", forIndexPath: indexPath) as! CommentTableViewCell
        
        //
        // Set data as a variable for a single comment (1 table view cell (a row))
        //
        if self.comments == nil {
            return cell
        }
        
        let _comment = self.comments!["features"][indexPath.row]
        
        //
        // Comment Owner's Name + Image
        //
        let _commentOwner = _comment["properties"]["owner"]["properties"]
        var _commentOwnerName: String = ""
        if let _ownerFirstName = _commentOwner["first_name"].string,
            let _ownerLastName = _commentOwner["last_name"].string {
            _commentOwnerName = _ownerFirstName + " " + _ownerLastName
            cell.commentOwnerName.text = _commentOwnerName
        }
        
        //
        // Comment Date
        //
        let commentDate = _comment["properties"]["created"].string
        
        cell.commentDatePosted.text = ""
        
        if (commentDate != nil) {
            let dateString: String = commentDate!
            
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
            
            if let stringToFormat = dateFormatter.dateFromString(dateString) {
                dateFormatter.dateFormat = "MMM d, yyyy"
                
                let displayDate = dateFormatter.stringFromDate(stringToFormat)
                
                if let thisDisplayDate: String? = displayDate {
                    cell.commentDatePosted.text = thisDisplayDate
                }
            }
        }
        
        //
        //
        // DETERMINE HOW TO DISPLAY COMMENT
        //
        //
        if ((_comment["properties"]["body"].string == "" || _comment["properties"]["body"].string == nil) && _comment["properties"]["images"].count == 0 && _comment["properties"]["report_state"].string == "closed") {
            
            //
            // ACTION TAKEN IMAGE
            //
            cell.commentOwnerImage.image = UIImage(named: "badge--CertifiedActionClosed")
            
            //
            // HIDE THE EMPTY IMAGE VIEW
            //
            cell.commentDescriptionImageHeightConstraint.constant = 0.0
            cell.commentDescriptionImageBottomMarginConstraint.constant = 0.0
            
            //
            // ACTION TAKEN BODY
            //
            cell.commentDescription.text = "Action taken by \(_commentOwnerName)"
            
        } else {
            
            //
            //
            //
            cell.commentOwnerImage.tag = indexPath.row
            cell.commentOwnerImageButton.tag = indexPath.row
            
            cell.commentOwnerImageButton.addTarget(self, action: #selector(CommentsTableViewController.loadCommentOwnerProfile(_:)), forControlEvents: .TouchUpInside)
            
            var commentOwnerImageURL:NSURL! = NSURL(string: "https://www.waterreporter.org/community/images/badget--MissingUser.png")
            
            if let thisCommentOwnerImageURL = _commentOwner["picture"].string {
                commentOwnerImageURL = NSURL(string: String(thisCommentOwnerImageURL))
            }
            
            cell.commentOwnerImage.kf_indicatorType = .Activity
            cell.commentOwnerImage.kf_showIndicatorWhenLoading = true
            
            cell.commentOwnerImage.kf_setImageWithURL(commentOwnerImageURL, placeholderImage: nil, optionsInfo: nil, progressBlock: nil, completionHandler: {
                (image, error, cacheType, imageUrl) in
                if (image != nil) {
                    cell.commentOwnerImage.image = UIImage(CGImage: (image?.CGImage)!, scale: (image?.scale)!, orientation: UIImageOrientation.Up)
                }
                cell.commentOwnerImage.layer.cornerRadius = cell.commentOwnerImage.frame.size.width / 2
                cell.commentOwnerImage.clipsToBounds = true
            })
            
            
            //
            // Comment Body
            //
            if let _commentBody = _comment["properties"]["body"].string {
                
                if "\(_commentBody)" != "null" || "\(_commentBody)" != "" {
                    cell.commentDescription.text = "\(_commentBody)"
                    cell.commentDescription.enabledTypes = [.Hashtag]
                    cell.commentDescription.hashtagColor = UIColor.colorBrand()
                    cell.commentDescription.hashtagSelectedColor = UIColor.colorDarkGray()
                    
                    cell.commentDescription.handleHashtagTap { hashtag in
                        print("Success. You just tapped the \(hashtag) hashtag")
                        
                        let nextViewController = self.storyBoard.instantiateViewControllerWithIdentifier("HashtagTableViewController") as! HashtagTableViewController
                        
                        nextViewController.hashtag = hashtag
                        
                        self.navigationController?.pushViewController(nextViewController, animated: true)
                        
                    }
                    
                    cell.commentDescription.handleURLTap { url in
                        print("Success. You just tapped the \(url) url")
                        
                        UIApplication.sharedApplication().openURL(NSURL(string: "\(url)")!)
                    }
                    
                }
            }
            
            //
            // Comment Image Body
            //
            let commentImages = _comment["properties"]["images"][0]["properties"]
            
            if let thisCommentImageURL = commentImages["square"].string {
                print("Comment needs to display an image \(thisCommentImageURL)")
                let commentImageURL = NSURL(string: String(thisCommentImageURL))
                
                cell.commentDescriptionImage.kf_indicatorType = .Activity
                cell.commentDescriptionImage.kf_showIndicatorWhenLoading = true
                
                cell.commentDescriptionImage.kf_setImageWithURL(commentImageURL, placeholderImage: nil, optionsInfo: nil, progressBlock: nil, completionHandler: {
                    (image, error, cacheType, imageUrl) in
                    if (image != nil) {
                        cell.commentDescriptionImage.image = UIImage(CGImage: (image?.CGImage)!, scale: (image?.scale)!, orientation: UIImageOrientation.Up)
                    }
                    cell.commentDescriptionImage.clipsToBounds = true
                    
                    cell.commentDescriptionImageHeightConstraint.constant = 320.0
                })
                
            } else {
                cell.commentDescriptionImageHeightConstraint.constant = 0.0
                cell.commentDescriptionImageBottomMarginConstraint.constant = 0.0
            }
            
        }
        
        return cell
    }

    func refreshTableView(refreshControl: UIRefreshControl) {
        
        self.page = 1
        self.comments = []
        
        if reportId != "" {
            self.attemptGetReportComments(reportId, isRefreshingReportsList: true)
        }
        
    }

    
    //
    // MARK: Server Request/Response functionality
    //
    func attemptGetReportComments(reportId: String, isRefreshingReportsList: Bool = false) {
        
        // Create necessary Authorization header for our request
        //        let accessToken = NSUserDefaults.standardUserDefaults().objectForKey("currentUserAccountAccessToken")
        //        let headers = [
        //            "Authorization": "Bearer " + (accessToken! as! String)
        //        ]
        
        print("reportId \(reportId)")
        
        let parameters: [String: AnyObject] = [
            "q": "{\"filters\":[{\"name\":\"report_id\",\"op\":\"eq\",\"val\":" + reportId + "}],\"order_by\":[{\"field\":\"created\",\"direction\":\"desc\"}]}",
            "page": self.page
        ]
        
        Alamofire.request(.GET, Endpoints.GET_MANY_REPORT_COMMENTS, parameters: parameters)
            .responseJSON { response in
                
                switch response.result {
                case .Success(let value):
                    print("Success: \(value)")
                    
                    //
                    // Choose whether or not the reports should refresh or
                    // whether loaded reports should be appended to the existing
                    // list of reports
                    //
                    if (isRefreshingReportsList) {
                        self.comments = JSON(value)
//                        self.tableView.refreshControl?.endRefreshing()
                    }
                    else {
                        self.comments = JSON(value)
                    }
                    
                    print("self.comments \(self.comments)")
                    
                    
                    self.tableView.reloadData()
                    
                    self.page += 1
                    
                    //
                    //
                    //
                    //
                    // CHECK TO SEE IF WE NEED TO DISPLAY THE ACTION TAKEN BANNER
                    //
                    //
                    //
                    //
                    let _report = JSON(self.report)
                    
                    if ("\(_report["properties"]["state"])" == "closed") {
                        
                        self.viewActionTakenBanner.hidden = false
                        self.viewActionTakenBanner.frame.size.height = 130.0
                        self.actionTakenBannerHeight.constant = 130.0
                    }
                    else {
                        
                        
                        self.viewActionTakenBanner.frame.size.height = 0.0
                        self.actionTakenBannerHeight.constant = 0.0
                    }
                    
                    //
                    // Dismiss the loading indicator
                    //
                    self.loadingComplete()
                    
                    break;
                case .Failure(let error):
                    print("Failure: \(error)")
                    break;
                }
        }
        
    }
    

    //
    // MARK:
    //
    func loading() {
        
        //
        // Create a view that covers the entire screen
        //
        self.indicatorLoadingView.frame = CGRectMake(0, 0, self.view.frame.width, self.view.frame.height)
        self.indicatorLoadingView.backgroundColor = UIColor.whiteColor()
        
        self.view.addSubview(self.indicatorLoadingView)
        self.view.bringSubviewToFront(self.indicatorLoadingView)
        
        self.tableView.separatorStyle = UITableViewCellSeparatorStyle.None
        
    }
    
    func loadingComplete() {
        
        //
        // Remove loading screen
        //
        self.indicatorLoadingView.removeFromSuperview()
        
        if (self.comments?["features"].count >= 2) {
            self.tableView.separatorStyle = UITableViewCellSeparatorStyle.SingleLine
        }
        
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
        self.buttonNewCommentImage.setImage(self.reportImageObject, forState: .Normal)
        
        // Refresh the table view to display the updated image data
        //
        self.dismissViewControllerAnimated(true, completion: {
            self.tableView.reloadData()
        })
        
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
        
        print("Hashtag Selected, now we need to update the textview with selected \(value) and search text \(searchText) so that it makes sense with \(self.buttonNewCommentTextView.text)")
        
        let _temporaryCopy = self.buttonNewCommentTextView.text
        
        let _updatedDescription = _temporaryCopy.stringByReplacingOccurrencesOfString(searchText, withString: _selection, options: NSStringCompareOptions.LiteralSearch, range: nil)
        
        print("Updated Text \(_updatedDescription)")
        
        // Add the hashtag to the text
        //
        self.buttonNewCommentTextView.text = "\(_updatedDescription)"
        
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
}
