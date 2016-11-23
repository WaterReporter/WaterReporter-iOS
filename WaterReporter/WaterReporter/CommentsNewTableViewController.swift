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

    
    //
    // MARK: Override
    //
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
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

        //
        //
        //
        self.navigationBarButtonCancel.target = self
        self.navigationBarButtonCancel.action = #selector(CommentsNewTableViewController.dimissNewCommentViewController(_:))
        
        self.navigationBarButtonSave.target = self
        
        //
        //
        //
        buttonCommentImageAdd.addTarget(self, action: #selector(CommentsNewTableViewController.attemptOpenPhotoTypeSelector(_:)), forControlEvents: .TouchUpInside)
        buttonCommentImageRemove.addTarget(self, action: #selector(CommentsNewTableViewController.attemptRemoveImageFromPreview(_:)), forControlEvents: .TouchUpInside)

        self.isReady()

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
    func dimissNewCommentViewController(sender: UIBarButtonItem) {
        self.dismissViewControllerAnimated(true, completion: {
            self.commentImagePreview.image = nil
            self.textfieldCommentBody.text = nil
        })
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
        if (self.report!["properties"]["state"] == "open") {
            let saveCommentWithCloseAction = UIAlertAction(title: "Save Comment & Close Report", style: .Default, handler: {
                UIAlertAction in
                self.attemptNewReportCommentSave("closed")
            })
            thisActionSheet.addAction(saveCommentWithCloseAction)
        }
        else if (self.report!["properties"]["state"] == "closed") {
            let saveCommentWithReopenAction = UIAlertAction(title: "Save Comment & Reopen Report", style: .Default, handler: {
                UIAlertAction in
                self.attemptNewReportCommentSave("open")
            })
            thisActionSheet.addAction(saveCommentWithReopenAction)
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

}
