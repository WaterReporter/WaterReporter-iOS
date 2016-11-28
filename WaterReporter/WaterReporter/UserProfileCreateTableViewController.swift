//
//  UserProfileCreateTableViewController.swift
//  Water-Reporter
//
//  Created by Viable Industries on 11/7/16.
//  Copyright © 2016 Viable Industries, L.L.C. All rights reserved.
//

import Alamofire
import Foundation
import SwiftyJSON
import UIKit

class UserProfileCreateTableViewController: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    
    //
    // MARK: @IBOutlet
    //
    @IBOutlet weak var navigationButtonBarItemSave: UIBarButtonItem!

    @IBOutlet weak var userProfileChangeImage: UIButton!
    @IBOutlet weak var userProfileImageView: UIImageView!

    @IBOutlet weak var textfieldFirstName: UITextField!
    @IBOutlet weak var textfieldLastName: UITextField!
    @IBOutlet weak var textfieldOrganizationName: UITextField!
    @IBOutlet weak var textfieldTelephone: UITextField!
    @IBOutlet weak var textfieldTitlePosition: UITextField!
    @IBOutlet weak var textfieldPublicEmail: UITextField!
    @IBOutlet weak var textfieldBio: UITextView!

    @IBOutlet var indicatorLoadingProfileView: UIView!
    

    //
    // MARK: Variables
    //
    var userProfile: JSON?
    var loadingView: UIView!
    let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
    
    
    //
    // MARK: Override
    //
    override func viewDidLoad() {
        super.viewDidLoad()

        // Show Loading Indicator While the View is being setup
        self.status("ready")
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    
    
    //
    // MARK: Statuses
    //
    func status(statusType: String = "loading") {
        
        switch statusType {
            
            case "ready":
                // Setup the bio field if there is no value
                textfieldBio.text = "Bio"
                textfieldBio.textColor = UIColor.lightGrayColor()
                break

            case "complete":
                // Remove loading view from viewport
                self.loadingView.removeFromSuperview()
                
                // Re-enable the Save bar button item
                self.navigationItem.rightBarButtonItem?.enabled = true
                break
            
            case "saving":
                // Create a view that covers the entire screen
                self.loadingView = self.indicatorLoadingProfileView
                self.loadingView.frame = CGRectMake(0, 0, self.view.frame.width, self.view.frame.height)
                
                self.view.addSubview(self.loadingView)
                self.view.bringSubviewToFront(self.loadingView)
                
                // Make sure that the Save button is disabled
                self.navigationItem.rightBarButtonItem?.enabled = false
                
                break
            
            default:
                break
        }
    }
    
    func presentUserProfileCreateGroupsTableViewController() {
        
        let nextViewController = self.storyBoard.instantiateViewControllerWithIdentifier("UserProfileCreateGroupsTableViewController") as! UserProfileCreateGroupsTableViewController
        
        let navigationViewController = UINavigationController(rootViewController: nextViewController)
        
        self.presentViewController(navigationViewController, animated:true, completion: nil)
    }
    
    
    //
    // MARK: TextField and TextView Functionality
    //
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        let nextTage = textField.tag + 1;
        let nextResponder=textField.superview?.superview?.superview?.viewWithTag(nextTage) as UIResponder!
        
        if (nextResponder != nil){
            nextResponder?.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
        }
        
        return false
    }
    
    func textViewDidBeginEditing(textView: UITextView) {
        if textView.textColor == UIColor.lightGrayColor() {
            textView.textColor = UIColor.blackColor()
            
            if textView.text == "Bio" {
                textView.text = nil
            }
        }
    }
    
    func textViewDidEndEditing(textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Bio"
            textView.textColor = UIColor.lightGrayColor()
        }
    }
    
    
    //
    // MARK: Request/Response Functionality
    //
    @IBAction func buttonSaveUserCreateProfileTableViewController(sender:UIBarButtonItem) {

        // Set status to saving
        self.status("saving")
        
        // Set headers
        let headers = self.buildRequestHeaders()

        // Execute request
        Alamofire.request(.GET, Endpoints.GET_USER_ME, headers: headers, encoding: .JSON)
            .responseJSON { response in
                
                switch response.result {
                    case .Success(let value):
                        print("Request Success: \(value)")

                        if let userId = value.valueForKey("id") as? NSNumber {
                            
                            NSUserDefaults.standardUserDefaults().setValue(userId, forKeyPath: "currentUserAccountUID")
                            
                            self.attemptUserProfileSave("\(userId)", headers: headers)
                        }
                    
                    case .Failure(let error):
                        print("Request Failure: \(error)")
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
    
    func attemptUserProfileSave(userId: String, headers: [String: String]) {
        
        // Create endpoint for request
        let _endpoint = Endpoints.POST_USER_PROFILE + userId;
        
        // Create parameters to send with request
        var parameters: [String: AnyObject] = [
            "first_name": self.textfieldFirstName.text!,
            "last_name": self.textfieldLastName.text!,
            "organization_name": self.textfieldOrganizationName.text!,
            "title": self.textfieldTitlePosition.text!,
            "public_email": self.textfieldPublicEmail.text!,
            "description": self.textfieldBio.text!
        ]
        
        if (self.textfieldTelephone.text != self.userProfile?["properties"]["telephone"][0]["properties"]["number"].string && self.textfieldTelephone.text != nil) {
            let telephoneNumber = [
                "number": self.textfieldTelephone.text!
            ]
            let telephone: [AnyObject] = [telephoneNumber]
            
            parameters["telephone"] = telephone
        }
        
        // Check for image existence before sending request
        if (self.userProfileImageView.image != nil) {
            print("image exists, let's try to upload it")
            
            Alamofire.upload(.POST, Endpoints.POST_IMAGE, headers: headers, multipartFormData: { multipartFormData in
                
                // import image to request
                if let imageData = UIImageJPEGRepresentation(self.userProfileImageView.image!, 1) {
                    multipartFormData.appendBodyPart(data: imageData, name: "image", fileName: "myImage.jpg", mimeType: "image/jpeg")
                }
                
                }, encodingCompletion: {
                    encodingResult in
                    switch encodingResult {
                    case .Success(let upload, _, _):
                        print("Request \(Endpoints.POST_IMAGE) Success \(upload)")

                        upload.responseJSON { response in
                            print("Image uploaded \(response)")
                            
                            if let value = response.result.value {
                                
                                // Handle image response and add it to the request
                                let imageResponse = JSON(value)
                                
                                let image = [
                                    "id": String(imageResponse["id"].rawValue)
                                ]
                                let images: [AnyObject] = [image]
                                
                                parameters["images"] = images
                                
                                // Make sure we're saving the profile image
                                if (images.count >= 1) {
                                    if let thumbnail: String = imageResponse["thumbnail"].string {
                                        parameters["picture"] = thumbnail
                                    }
                                }
                                
                                Alamofire.request(.PATCH, _endpoint, parameters: parameters, headers: headers, encoding: .JSON)
                                    .responseJSON { response in
                                        
                                        print("Response \(response)")
                                        
                                        switch response.result {
                                        case .Success(let value):
                                            print("Request \(_endpoint) Success \(value)")
                                            self.presentUserProfileCreateGroupsTableViewController()
                                        case .Failure(let error):
                                            print("Request \(_endpoint) Failure \(error)")
                                            break
                                        }
                                        
                                }
                            }
                        }
                    case .Failure(let encodingError):
                        print("Request \(Endpoints.POST_IMAGE) Failure \(encodingError)")
                    }
            })
            
        } else {
            print("no image exists >>> parameters \(parameters)")
            Alamofire.request(.PATCH, _endpoint, parameters: parameters, headers: headers, encoding: .JSON)
                .responseJSON { response in
                    
                    print("Response \(response)")
                    
                    switch response.result {
                    case .Success(let value):
                        print("Request \(_endpoint) Success \(value)")
                        self.presentUserProfileCreateGroupsTableViewController()
                    case .Failure(let error):
                        print("Request \(_endpoint) Failure \(error)")
                        break
                    }
                    
            }
        }
        
    }
    
    //
    // MARK: Image/Photo Functionality
    //
    @IBAction func attemptOpenPhotoTypeSelector(sender: AnyObject) {
        
        // Initialize the Action Sheet
        let thisActionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        
        // OPTION: Camera
        let cameraAction = UIAlertAction(title: "Camera", style: .Default, handler:self.cameraActionHandler)
        thisActionSheet.addAction(cameraAction)
        
        // OPTION: Photo Library
        let photoLibraryAction = UIAlertAction(title: "Photo Library", style: .Default, handler:self.photoLibraryActionHandler)
        thisActionSheet.addAction(photoLibraryAction)
        
        // OPTION: Cancel
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        thisActionSheet.addAction(cancelAction)
        
        // Show the Action Sheet
        presentViewController(thisActionSheet, animated: true, completion: nil)
        
    }

    func cameraActionHandler(action:UIAlertAction) -> Void {
        
        // Make sure Camera is available
        if (UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera)) {
            
            // Initialize the Image Picker Controller
            let imagePicker = UIImagePickerController()
            
            // Configure the Image Picker Controller
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerControllerSourceType.Camera
            imagePicker.allowsEditing = true
            
            // Show the Image Picker Controller
            self.presentViewController(imagePicker, animated: true, completion: nil)
        }
        
    }
    
    func photoLibraryActionHandler(action:UIAlertAction) -> Void {
        
        // Make sure PhotoLibrary is available
        if (UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.PhotoLibrary)) {

            // Initialize the Image Picker Controller
            let imagePicker = UIImagePickerController()
            
            // Configure the Image Picker Controller
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
            imagePicker.allowsEditing = true
            
            // Show the Image Picker Controller
            self.presentViewController(imagePicker, animated: true, completion: nil)

        }
        
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        userProfileImageView.image = image
        self.dismissViewControllerAnimated(true, completion: {
            self.tableView.reloadData()
        })
    }
    
    func attemptRemoveImageFromPreview(sender: AnyObject) {
        userProfileImageView.image = nil
        tableView.reloadData()
    }

}
