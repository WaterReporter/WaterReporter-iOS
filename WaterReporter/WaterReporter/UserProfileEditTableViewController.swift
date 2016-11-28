//
//  UserProfileEditTableViewController.swift
//  Water-Reporter
//
//  Created by Viable Industries on 9/22/16.
//  Copyright © 2016 Viable Industries, L.L.C. All rights reserved.
//

import Alamofire
import Foundation
import SwiftyJSON
import UIKit

class UserProfileEditTableViewController: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        
    @IBOutlet weak var navigationButtonBarItemCancel: UIBarButtonItem!
    @IBOutlet weak var navigationButtonBarItemSave: UIBarButtonItem!
    @IBOutlet weak var textfieldFirstName: UITextField!
    @IBOutlet weak var textfieldLastName: UITextField!
    
    @IBOutlet weak var textfieldOrganizationName: UITextField!
    @IBOutlet weak var textfieldTelephone: UITextField!
    @IBOutlet weak var textfieldTitlePosition: UITextField!
    @IBOutlet weak var textfieldPublicEmail: UITextField!
    
    @IBOutlet weak var textfieldBio: UITextView!

    @IBOutlet var indicatorLoadingProfileView: UIView!
    
    @IBOutlet weak var indicatorLoadingProfileLabel: UILabel!
    @IBOutlet weak var indicatorSavingProfileLabel: UILabel!
    
    @IBOutlet weak var userProfileChangeImage: UIButton!
    @IBOutlet weak var userProfileImageView: UIImageView!
    
    var userProfile: JSON?
    var loadingView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Hide the user profile until all elements are loaded
        self.loading()
        
        // Make sure we are getting 'auto layout' specific sizes
        // otherwise any math we do will be messed up
        self.view.setNeedsLayout()
        self.view.layoutIfNeeded()
        
        navigationButtonBarItemSave.target = self
        navigationButtonBarItemSave.action = #selector(buttonSaveUserProfileEditTableViewController(_:))
        
        navigationButtonBarItemCancel.target = self
        navigationButtonBarItemCancel.action = #selector(buttonDismissUserProfileEditTableViewController(_:))
        
        let _userId = NSUserDefaults.standardUserDefaults().objectForKey("currentUserAccountUID")
        
        if (_userId != nil) {
            print("viewDidLoad::_userId \(_userId)")
            self.attemptLoadUserProfile()
        } else {
            self.attemptRetrieveUserID()
        }
        
        userProfileChangeImage.addTarget(self, action: #selector(UserProfileEditTableViewController.attemptOpenPhotoTypeSelector(_:)), forControlEvents: .TouchUpInside)

    }
    
    func loading() {
        
        //
        // Create a view that covers the entire screen
        //
        self.loadingView = self.indicatorLoadingProfileView
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
        self.indicatorSavingProfileLabel.hidden = true
        self.indicatorLoadingProfileLabel.hidden = false
        
        //
        // Setup the bio field if there is no value
        //
        textfieldBio.text = "Bio"
        textfieldBio.textColor = UIColor.lightGrayColor()


    }
    
    func loadingComplete() {
        
        //
        // Remove loading screen
        //
        self.loadingView.removeFromSuperview()
        
        //
        // Re-enable the save button
        //
        self.navigationItem.rightBarButtonItem?.enabled = true
    }
    
    func saving() {
        
        //
        // Create a view that covers the entire screen
        //
        self.loadingView = self.indicatorLoadingProfileView
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
        self.indicatorSavingProfileLabel.hidden = false
        self.indicatorLoadingProfileLabel.hidden = true
    
    }
    
    func buttonDismissUserProfileEditTableViewController(sender:UIBarButtonItem) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    func buttonSaveUserProfileEditTableViewController(sender:UIBarButtonItem) {
        
        //
        // Hide the form during saving
        //
        self.saving()
        
        //
        // Construct the necessary headers and parameters to complete the request
        //
        let accessToken = NSUserDefaults.standardUserDefaults().objectForKey("currentUserAccountAccessToken")
        let headers = [
            "Authorization": "Bearer " + (accessToken! as! String)
        ]
        
        Alamofire.request(.GET, Endpoints.GET_USER_ME, headers: headers, encoding: .JSON)
            .responseJSON { response in
            
                switch response.result {
                case .Success(let value):
                    print("Request \(Endpoints.GET_USER_ME) Success \(value)")

                    if let userId = value.valueForKey("id") as? NSNumber {
                        self.attemptUserProfileSave("\(userId)", headers: headers)
                    }
                    
                case .Failure(let error):
                    print("Request \(Endpoints.GET_USER_ME) Failure \(error)")
                    break
                }
            
            }
        
    }
    
    func attemptUserProfileSave(userId: String, headers: [String: String]) {
        
        let _endpoint = Endpoints.POST_USER_PROFILE + userId;
        
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
                            upload.responseJSON { response in
                                print("Image uploaded \(response)")
                                
                                if let value = response.result.value {
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
                                                
                                                print("Response Success \(value)")

                                                self.dismissViewControllerAnimated(true, completion: {
                                                    self.dismissViewControllerAnimated(true, completion: nil)
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

        } else {
            print("no image exists >>> parameters \(parameters)")
            Alamofire.request(.PATCH, _endpoint, parameters: parameters, headers: headers, encoding: .JSON)
                .responseJSON { response in
                    
                    print("Response \(response)")
                    
                    switch response.result {
                        case .Success(let value):
                            
                            print("Response Success \(value)")
                            
                            self.dismissViewControllerAnimated(true, completion: {
                                self.dismissViewControllerAnimated(true, completion: nil)
                            })
                            
                        case .Failure(let error):
                            print("attemptUserProfileSave::Failure")
                            print(error)
                            break
                    }
                    
            }
        }

    }

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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        
        NSLog("LoginViewController::didReceiveMemoryWarning")
    }
    
    //
    // MARK: HTTP Request/Response functionality
    //
    func attemptLoadUserProfile() {
        
        let accessToken = NSUserDefaults.standardUserDefaults().objectForKey("currentUserAccountAccessToken")
        let headers = [
            "Authorization": "Bearer " + (accessToken! as! String)
        ]       
        
        if let userId = NSUserDefaults.standardUserDefaults().objectForKey("currentUserAccountUID") as? NSNumber {

            let revisedEndpoint = Endpoints.GET_USER_PROFILE + "\(userId)"
            
            Alamofire.request(.GET, revisedEndpoint, headers: headers, encoding: .JSON).responseJSON { response in
                
                print("response.result \(response.result)")
                
                switch response.result {
                    case .Success(let value):
                        let json = JSON(value)
                        
                        if (json != nil) {
                            self.userProfile = json
                            
                            self.updateUserProfileFields()
                            
                            self.loadingComplete()
                        }
                        
                    case .Failure(let error):
                        print(error)
                }
            }

        } else {
            self.attemptRetrieveUserID()
        }
        
    }

    func attemptRetrieveUserID() {
        
        let accessToken = NSUserDefaults.standardUserDefaults().objectForKey("currentUserAccountAccessToken")
        let headers = [
            "Authorization": "Bearer " + (accessToken! as! String)
        ]
        
        Alamofire.request(.GET, Endpoints.GET_USER_ME, headers: headers, encoding: .JSON)
            .responseJSON { response in
                
                switch response.result {
                case .Success(let value):
                    let json = JSON(value)
                    
                    if let data: AnyObject = json.rawValue {
                        NSUserDefaults.standardUserDefaults().setValue(data["id"], forKeyPath: "currentUserAccountUID")
                        
                        self.attemptLoadUserProfile()
                    }
                    
                case .Failure(let error):
                    print(error)
                }
        }
    }
    
    func updateUserProfileFields() {
        
        print("Update user profile with the following data \(self.userProfile)")
        
        if let userFirstName = self.userProfile?["properties"]["first_name"].string {
            self.textfieldFirstName.text = userFirstName
        }

        if let userLastName = self.userProfile?["properties"]["last_name"].string {
            self.textfieldLastName.text = userLastName
        }

        if let userTitle = self.userProfile?["properties"]["title"].string {
            self.textfieldTitlePosition.text = userTitle
        }

        if let userOrganizationName = self.userProfile?["properties"]["organization_name"].string {
            self.textfieldOrganizationName.text = userOrganizationName
        }

        if let userPublicEmail = self.userProfile?["properties"]["public_email"].string {
            self.textfieldPublicEmail.text = userPublicEmail
        }

        if let userDescription = self.userProfile?["properties"]["description"].string {
            self.textfieldBio.text = userDescription
            self.textfieldBio.textColor = UIColor.blackColor()
        }

        if let userTelephone = self.userProfile?["properties"]["telephone"][0]["properties"]["number"].string {
            self.textfieldTelephone.text = userTelephone
        }
        
        if let userProfileImageURLString = self.userProfile?["properties"]["picture"].string {
            if let imageUrl = NSURL(string: userProfileImageURLString),
                let data = NSData(contentsOfURL: imageUrl) {
                self.userProfileImageView.layer.cornerRadius = self.userProfileImageView.frame.size.width / 2;
                self.userProfileImageView.image = UIImage(data: data)
            }
        }

        
        self.tableView.reloadData()
        
    }
    
    //
    //
    //
    // MARK: Photo Functionality
    //
    //
    //
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
        userProfileImageView.image = image
        self.dismissViewControllerAnimated(true, completion: {
//            self.isReadyWithImage()
//            self.imageReportImagePreviewIsSet = true
            self.tableView.reloadData()
        })
    }
    
    func attemptRemoveImageFromPreview(sender: AnyObject) {
        userProfileImageView.image = nil
        
//        self.isReadyAfterRemove()
        tableView.reloadData()
    }


}
