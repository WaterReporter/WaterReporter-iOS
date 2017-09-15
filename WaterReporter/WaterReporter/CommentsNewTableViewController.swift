//
//  CommentsNewTableViewController.swift
//  Water-Reporter
//
//  Created by Viable Industries on 10/29/16.
//  Copyright © 2016 Viable Industries, L.L.C. All rights reserved.
//

import Alamofire
import Foundation
import SwiftyJSON
import UIKit

protocol NewCommentReportUpdaterDelegate {
    func sendReport(reportId: String, report: AnyObject)
    func reportLoadingComplete(isFinished: Bool)
}

class CommentsNewTableViewController: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextViewDelegate {
    
    //
    // MARK: @IBOutlets
    //
    @IBOutlet var indicatorSavingNewComment: UIView!
    @IBOutlet weak var indicatorSavingNewCommentLabel: UILabel!
    
    @IBOutlet weak var navigationBarButtonSave: UIBarButtonItem!
    @IBOutlet weak var navigationBarButtonCancel: UIBarButtonItem!
    
    @IBOutlet weak var commentImagePreview: UIImageView!

    @IBOutlet weak var buttonCommentImageAdd: UIButton!
    @IBOutlet weak var buttonCommentImageAddIcon: UIImageView!

    @IBOutlet weak var buttonCommentImageRemove: UIButton!
    @IBOutlet weak var buttonCommentImageRemoveIcon: UIImageView!

    @IBOutlet weak var textfieldCommentBody: UITextView!
    
    @IBOutlet weak var hashtagTypeAhead: UITableView!
    @IBOutlet weak var typeAheadHeight: NSLayoutConstraint!

    //
    // MARK: Variables
    //

    var delegate: NewCommentReportUpdaterDelegate?

    var reportId: String!
    var report: JSON?
    var reportState: String!
    var userId: String!
    var userObject: JSON?
    var userProfile: JSON?
    var loadingView: UIView!

    var hashtagAutocomplete: [String] = [String]()
    var hashtagSearchEnabled: Bool = false
    var dataSource: CommentHashtagTableView = CommentHashtagTableView()
    
    var hashtagSearchTimer: NSTimer = NSTimer()

    
    //
    // MARK: Override
    //
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.addDoneButtonOnKeyboard()
        
        // Check to see if a user id was passed to this view from
        // another view. If no user id was passed, then we know that
        // we should be displaying the acting user's profile
        
        if (self.userId == nil) {
            if let userIdNumber = NSUserDefaults.standardUserDefaults().objectForKey("currentUserAccountUID") as? NSNumber {
                self.userId = "\(userIdNumber)"
                self.attemptLoadUserProfile()
            } else {
                self.attemptRetrieveUserID()
            }
        }

        
        //
        // Make sure we are getting 'auto layout' specific sizes
        // otherwise any math we do will be messed up
        //
        self.view.setNeedsLayout()
        self.view.layoutIfNeeded()
                
        self.tableView.backgroundColor = UIColor.colorBackground(1.00)

        // HASHTAG TYPE AHEAD
        //
        self.hashtagTypeAhead.delegate = dataSource
        self.hashtagTypeAhead.dataSource = dataSource
        dataSource.parent = self

        
        //
        //
        //
        self.navigationBarButtonCancel.target = self
        self.navigationBarButtonCancel.action = #selector(CommentsNewTableViewController.dimissNewCommentViewController(_:))
        
        self.navigationBarButtonSave.target = self
        
        self.navigationBarButtonSave.enabled = false
        
        //
        //
        //
        buttonCommentImageAdd.addTarget(self, action: #selector(CommentsNewTableViewController.attemptOpenPhotoTypeSelector(_:)), forControlEvents: .TouchUpInside)
        buttonCommentImageRemove.addTarget(self, action: #selector(CommentsNewTableViewController.attemptRemoveImageFromPreview(_:)), forControlEvents: .TouchUpInside)
        textfieldCommentBody.targetForAction(#selector(CommentsNewTableViewController.textFieldShouldReturn(_:)), withSender: self)

        self.isReady()

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

    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
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
        
        self.textfieldCommentBody.inputAccessoryView = doneToolbar
    }
    
    func doneButtonAction() {
        self.textfieldCommentBody.resignFirstResponder()
        self.textfieldCommentBody.resignFirstResponder()
    }
    
    func dimissNewCommentViewController(sender: UIBarButtonItem) {
        self.dismissViewControllerAnimated(true, completion: {
            self.commentImagePreview.image = nil
            self.textfieldCommentBody.text = nil
        })
    }
    
    func textViewDidChange(textView: UITextView) {
        
        let _text: String = "\(textView.text)"
        
        if _text != "" && _text.characters.last! == "#" {
            self.hashtagSearchEnabled = true
            self.textfieldCommentBody.becomeFirstResponder()
            
            print("Hashtag Search: Found start of hashtag")
        }
        else if _text != "" && self.hashtagSearchEnabled == true && _text.characters.last! == " " {
            self.hashtagTypeAhead.hidden = true
            self.hashtagSearchEnabled = false
            self.dataSource.results = [String]()
            
            self.tableView.reloadData()
            self.textfieldCommentBody.becomeFirstResponder()
            
            print("Hashtag Search: Disabling search because space was entered")
            print("Hashtag Search: Timer reset to zero due to search termination (space entered)")
            self.hashtagSearchTimer.invalidate()
        }
        else if _text != "" && self.hashtagSearchEnabled == true {
            
            self.hashtagTypeAhead.hidden = false
            self.dataSource.results = [String]()
            
            self.tableView.reloadData()
            self.textfieldCommentBody.becomeFirstResponder()
            
            // Identify hashtag search
            //
            let _hashtag_identifier = _text.rangeOfString("#", options:NSStringCompareOptions.BackwardsSearch)
            if ((_hashtag_identifier) != nil) {
                let _hashtag_search = _text.substringFromIndex((_hashtag_identifier?.endIndex)!)
                
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
                self.hashtagSearchTimer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(CommentsNewTableViewController.searchHashtags(_:)), userInfo: _hashtag_search, repeats: false)
            }
        }
    }
    
    func selectedValue(value: String) {
        
        // Add the hashtag to the text
        //
        self.textfieldCommentBody.text = "\(self.textfieldCommentBody.text)\(value)"
        self.tableView.reloadData()
        
        self.textfieldCommentBody.becomeFirstResponder()
        
        
        // Reset the search
        //
        self.hashtagTypeAhead.hidden = true
        self.hashtagSearchEnabled = false
        self.dataSource.results = [String]()
        
//        self.typeAheadHeight.constant = 0.0
        self.tableView.reloadData()
        self.textfieldCommentBody.becomeFirstResponder()
        
        print("Hashtag Search: Timer reset to zero due to user selection")
        self.hashtagSearchTimer.invalidate()

    }


    //
    // MARK: Custom functionality
    //
    func isReady() {
        buttonCommentImageRemove.hidden = true;
        buttonCommentImageRemoveIcon.hidden = true;
    }
    
    func isReadyAfterRemove() {
        buttonCommentImageAdd.hidden = false;
        buttonCommentImageAddIcon.hidden = false;
        
        buttonCommentImageRemove.hidden = true;
        buttonCommentImageRemoveIcon.hidden = true;
    }
    
    func isReadyWithImage() {
        buttonCommentImageAdd.hidden = true;
        buttonCommentImageAddIcon.hidden = true;
        
        buttonCommentImageRemove.hidden = false;
        buttonCommentImageRemoveIcon.hidden = false;
    }
    
    func saving() {
        
        //
        // Create a view that covers the entire screen
        //
        self.loadingView = self.indicatorSavingNewComment
        self.loadingView.frame = CGRectMake(0, 0, self.view.frame.width, self.view.frame.height)
        
        self.view.addSubview(self.loadingView)
        self.view.bringSubviewToFront(self.loadingView)
        
        //
        // Make sure that the Done/Save button is disabled
        //
        self.navigationItem.rightBarButtonItem?.enabled = false
        self.navigationItem.leftBarButtonItem?.enabled = true
        
        //
        // Display the right label for the right action
        //
        self.indicatorSavingNewCommentLabel.hidden = false
        self.indicatorSavingNewCommentLabel.hidden = true
        
        //
        //
        //
        self.navigationBarButtonSave.enabled = false
        
        
        //
        // Make doubly sure the keyboard is closed
        //
        self.textfieldCommentBody.resignFirstResponder()
        
        //
        // Make sure our view is scrolled to the top
        //
        self.tableView.setContentOffset(CGPointZero, animated: false)
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
        commentImagePreview.image = image
        self.dismissViewControllerAnimated(true, completion: {
            self.isReadyWithImage()
            self.tableView.reloadData()
        })
    }
    
    func attemptRemoveImageFromPreview(sender: AnyObject) {
        commentImagePreview.image = nil
        self.isReadyAfterRemove()
        tableView.reloadData()
    }
    
    @IBAction func attemptOpenSaveCommentTypeSelector(sender: UIBarButtonItem) {
        
        let thisActionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        
        let saveCommentAction = UIAlertAction(title: "Save Comment", style: .Default, handler: {
            UIAlertAction in
                self.attemptNewReportCommentSave()
        })
        thisActionSheet.addAction(saveCommentAction)
        
        //
        // Determine if the Close Report or Reopen Report button should be visible
        //
        if (self.report!["properties"]["state"] == "closed") {
            let saveCommentWithReopenAction = UIAlertAction(title: "Save Comment & Reopen Report", style: .Default, handler: {
                UIAlertAction in
                self.attemptNewReportCommentSave("open")
            })
            thisActionSheet.addAction(saveCommentWithReopenAction)
        }
        else {
            let saveCommentWithCloseAction = UIAlertAction(title: "Save Comment & Close Report", style: .Default, handler: {
                UIAlertAction in
                self.attemptNewReportCommentSave("closed")
            })
            thisActionSheet.addAction(saveCommentWithCloseAction)
        }

        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        thisActionSheet.addAction(cancelAction)
        
        presentViewController(thisActionSheet, animated: true, completion: nil)
        
    }
    
    func attemptNewReportCommentSaveNonAdmin(sender: UIBarButtonItem) {
        self.attemptNewReportCommentSave()
    }

    func attemptNewReportCommentSave(reportStatus: String = "") {
        
        //
        // Hide the form during saving
        //
        self.saving()

        // Create necessary Authorization header for our request
        let accessToken = NSUserDefaults.standardUserDefaults().objectForKey("currentUserAccountAccessToken")
        let headers = [
            "Authorization": "Bearer " + (accessToken! as! String)
        ]
        
        //
        // PARAMETERS
        //
        var parameters: [String: AnyObject] = [
            "body": self.textfieldCommentBody.text!,
            "status": "public",
            "report_id": reportId
        ]
        
        if (reportStatus != "") {
            parameters["report_state"] = reportStatus
        }
        
        print("parameters \(parameters)")
        
        if (self.commentImagePreview.image != nil) {
            
            Alamofire.upload(.POST, Endpoints.POST_IMAGE, headers: headers, multipartFormData: { multipartFormData in
                
                // import image to request
                if let imageData = UIImageJPEGRepresentation(self.commentImagePreview.image!, 1) {
                    multipartFormData.appendBodyPart(data: imageData, name: "image", fileName: "ReportCommentImageFromiPhone.jpg", mimeType: "image/jpeg")
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
                                
                                Alamofire.request(.POST, Endpoints.POST_COMMENT, parameters: parameters, headers: headers, encoding: .JSON)
                                    .responseJSON { response in
                                        
                                        print("Response \(response)")
                                        
                                        switch response.result {
                                        case .Success(let value):
                                            
                                            print("Response Success \(value)")
                                            
                                            
                                            if (reportStatus != "") {
                                                print("Preparing to close report")
                                                
                                                let _report_parameters = [
                                                    "state": reportStatus
                                                ]

                                                Alamofire.request(.PATCH, Endpoints.POST_REPORT + "/\(self.reportId)", parameters: _report_parameters, headers: headers, encoding: .JSON)
                                                    .responseJSON { response in
                                                        
                                                        print("Response \(response)")
                                                        
                                                        switch response.result {
                                                        case .Success(let value):
                                                            
                                                            print("Response Sucess \(value)")
                                                            
                                                            let json = JSON(value)

                                                            if let _delegate = self.delegate {
                                                                _delegate.sendReport("\(json["id"])", report: value)
                                                            }

                                                            self.dismissViewControllerAnimated(true, completion: {
                                                                
                                                                if let _delegate = self.delegate {
                                                                    _delegate.reportLoadingComplete(true)
                                                                }

                                                                self.commentImagePreview.image = nil
                                                                self.textfieldCommentBody.text = nil
                                                            })

                                                        case .Failure(let error):
                                                            
                                                            print("Response Failure \(error)")
                                                            
                                                            break
                                                        }
                                                        
                                                }

                                            } else {
                                                self.dismissViewControllerAnimated(true, completion: {
                                                    self.commentImagePreview.image = nil
                                                    self.textfieldCommentBody.text = nil
                                                })
                                            }
                                            
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
        else {
            Alamofire.request(.POST, Endpoints.POST_COMMENT, parameters: parameters, headers: headers, encoding: .JSON)
                .responseJSON { response in
                    
                    print("Response \(response)")
                    
                    switch response.result {
                    case .Success(let value):
                        
                        print("Response Success \(value)")

                        if (reportStatus != "") {
                            print("Preparing to close report")
                            
                            let _report_parameters = [
                                "state": reportStatus
                            ]
                            
                            Alamofire.request(.PATCH, Endpoints.POST_REPORT + "/\(self.reportId)", parameters: _report_parameters, headers: headers, encoding: .JSON)
                                .responseJSON { response in
                                    
                                    print("Response \(response)")
                                    
                                    switch response.result {
                                    case .Success(let value):
                                        
                                        print("Response Sucess \(value)")
                                        
                                        let json = JSON(value)
                                        
                                        if let _delegate = self.delegate {
                                            print("DELEGATE CLOSING \(json["id"]) value: \(value)")
                                            _delegate.sendReport("\(json["id"])", report: value)
                                        }
                                        
                                        self.dismissViewControllerAnimated(true, completion: {
                                            
                                            if let _delegate = self.delegate {
                                                _delegate.reportLoadingComplete(true)
                                            }

                                            self.commentImagePreview.image = nil
                                            self.textfieldCommentBody.text = nil
                                        })
                                        
                                    case .Failure(let error):
                                        
                                        print("Response Failure \(error)")
                                        
                                        break
                                    }
                                    
                            }
                            
                        } else {
                            self.dismissViewControllerAnimated(true, completion: {
                                self.commentImagePreview.image = nil
                                self.textfieldCommentBody.text = nil
                            })
                        }
                    case .Failure(let error):

                        print("Response Failure \(error)")

                        break
                    }
                    
            }
        }
        
    }
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            textView.resignFirstResponder()
        }
        return true
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
    
    func attemptLoadUserProfile() {
        
        let _headers = buildRequestHeaders()
        
        let revisedEndpoint = Endpoints.GET_USER_PROFILE + "\(userId)"
        
        print("revisedEndpoint \(revisedEndpoint)")
        
        Alamofire.request(.GET, revisedEndpoint, headers: _headers, encoding: .JSON).responseJSON { response in
            
            print("response.result \(response.result)")
            
            switch response.result {
            case .Success(let value):
                let json = JSON(value)
                
                self.navigationBarButtonSave.enabled = true

                if (json != nil) {
                    
                    // Retain the returned data
                    self.userProfile = json
                    
                    print("self.userProfile \(self.userProfile)")
                    
                    if (self.userProfile!["properties"]["roles"].count >= 1) {
                        if (self.userProfile!["properties"]["roles"][0]["properties"]["name"] == "admin") {
                            // USER IS ADMIN
                            self.navigationBarButtonSave.action = #selector(CommentsNewTableViewController.attemptOpenSaveCommentTypeSelector(_:))
                        }
                        else {
                            self.navigationBarButtonSave.action = #selector(CommentsNewTableViewController.attemptNewReportCommentSaveNonAdmin(_:))
                        }
                    }
                    
                }
                
            case .Failure(let error):
                print("Response Failure \(error)")
            }
        }
        
    }
    
    func attemptRetrieveUserID() {
        
        let _headers = buildRequestHeaders()
        
        Alamofire.request(.GET, Endpoints.GET_USER_ME, headers: _headers, encoding: .JSON)
            .responseJSON { response in
                
                switch response.result {
                case .Success(let value):
                    let json = JSON(value)
                    
                    if let data: AnyObject = json.rawValue {
                        
                        // Set the user id as a number and save it to the application cache
                        //
                        let _user_id = data["id"] as! NSNumber
                        NSUserDefaults.standardUserDefaults().setValue(_user_id, forKeyPath: "currentUserAccountUID")
                        
                        // Set user id to view variable
                        //
                        self.userId = "\(_user_id)"
                        
                        // Continue loading the user profile
                        //
                        self.attemptLoadUserProfile()
                        
                    }
                    
                case .Failure(let error):
                    print(error)
                }
        }
    }

    
    //
    // MARK: TABLE VIEW OVERRIDES
    //
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        var rowHeight:CGFloat = 44.0
        
        switch indexPath.section {
            case 0:
                if indexPath.row == 0 {
                    rowHeight = 218.0
                }
                else {
                    rowHeight = 44.0
                }
            case 1:
                rowHeight = 680.0
            default:
                rowHeight = 44.0
        }
        
        
        return rowHeight
    }

    
    //
    //
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

}
