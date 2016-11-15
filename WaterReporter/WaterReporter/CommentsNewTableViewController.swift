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

class CommentsNewTableViewController: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextViewDelegate {
    
    var loadingView: UIView!

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
    
    var reportId: String!
    var reportState: String!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
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
        self.navigationBarButtonSave.action = #selector(CommentsNewTableViewController.attemptOpenSaveCommentTypeSelector(_:))

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
        
        let saveCommentWithCloseAction = UIAlertAction(title: "Save Comment & Close Report", style: .Default, handler: {
            UIAlertAction in
            self.attemptNewReportCommentSave("closed")
        })
        thisActionSheet.addAction(saveCommentWithCloseAction)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        thisActionSheet.addAction(cancelAction)
        
        presentViewController(thisActionSheet, animated: true, completion: nil)
        
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
                                            
                                            self.dismissViewControllerAnimated(true, completion: {
                                                self.commentImagePreview.image = nil
                                                self.textfieldCommentBody.text = nil
                                            })
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

                        self.dismissViewControllerAnimated(true, completion: {
                            self.commentImagePreview.image = nil
                            self.textfieldCommentBody.text = nil
                        })
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

}
