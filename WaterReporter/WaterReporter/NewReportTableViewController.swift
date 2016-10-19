//
//  NewReportTableViewController.swift
//  WaterReporter
//
//  Created by Viable Industries on 7/24/16.
//  Copyright © 2016 Viable Industries, L.L.C. All rights reserved.
//

import CoreLocation
import Mapbox
import UIKit

class NewReportTableViewController: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, CLLocationManagerDelegate, MGLMapViewDelegate {

    var imageReportImagePreviewIsSet:Bool = false
    var imageReportLocationPreviewIsSet:Bool = false
    var mapView: MGLMapView = MGLMapView()
    var thisLocationManager: CLLocationManager = CLLocationManager()
    
    @IBOutlet weak var textareaReportComment: UITextView!

    @IBOutlet weak var buttonReportImageRemove: UIButton!
    @IBOutlet weak var buttonReportImageRemoveIcon: UIImageView!
    @IBOutlet weak var buttonReportImage: UIButton!
    @IBOutlet weak var buttonReportImageAddIcon: UIImageView!
    @IBOutlet weak var imageReportImagePreview: UIImageView!
    
    @IBOutlet weak var indicatorReportLocationUpdating: UIActivityIndicatorView!
    @IBOutlet var buttonReportLocationIcon: UIImageView!
    @IBOutlet weak var buttonReportLocation: UIButton!
    @IBOutlet var buttonReportLocationUpdate: UIButton!
    
    @IBOutlet weak var navigationBarButtonSave: UIBarButtonItem!
    @IBOutlet weak var mapReportLocation: UIView!
    
    @IBOutlet weak var tableViewCellReportImage: UITableViewCell!
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        
        tableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NSLog("SubmitViewController::viewDidLoad")

        self.navigationItem.title = "New Report"

        self.tableView.backgroundColor = UIColor.colorBackground(1.00)
        
        textareaReportComment.targetForAction(#selector(NewReportTableViewController.textFieldShouldReturn(_:)), withSender: self)
        buttonReportImage.addTarget(self, action: #selector(NewReportTableViewController.attemptOpenPhotoTypeSelector(_:)), forControlEvents: .TouchUpInside)
        buttonReportImageRemove.addTarget(self, action: #selector(NewReportTableViewController.attemptRemoveImageFromPreview(_:)), forControlEvents: .TouchUpInside)
        
        buttonReportLocation.addTarget(self, action: #selector(NewReportTableViewController.startLocationServices(_:)), forControlEvents: .TouchUpInside)
//        buttonReportLocationUpdate.addTarget(self, action: #selector(NewReportTableViewController.startLocationServices(_:)), forControlEvents: .TouchUpInside)
        
        //
        // Setup Navigation Bar
        //
        navigationBarButtonSave.target = self
        navigationBarButtonSave.action = #selector(buttonSaveNewReportTableViewController(_:))
        
        //
        //
        //
        mapView.frame = mapReportLocation.bounds
        mapView.delegate = self
        mapView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]

        //
        //
        //
        self.isReady()
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
    
    @IBAction func buttonSaveNewReportTableViewController(sender: UIBarButtonItem) {
        print("SAVE THE FORM")
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        var rowHeight:CGFloat = 44.0
        
        switch indexPath.section {
            case 0:
                if (indexPath.row == 0) {
                    rowHeight = 148.0
                }
            
            case 1:
                if (imageReportImagePreviewIsSet && indexPath.row == 0) {
                    rowHeight = 280.0
                }
                else {
                    rowHeight = 44.0
                }
            case 2:
                if (imageReportLocationPreviewIsSet && indexPath.row == 0) {
                    rowHeight = 280.0
                }
                else {
                    rowHeight = 44.0
                }
            default:
                rowHeight = 44.0
        }
        
        return rowHeight
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    //
    // MARK: Custom functionality
    //
    func isReady() {
        imageReportImagePreview.hidden = true;
        mapReportLocation.hidden = true;
        buttonReportImageRemove.hidden = true;
        buttonReportImageRemoveIcon.hidden = true;
    }
    
    func isReadyAfterRemove() {
        buttonReportImage.hidden = false;
        buttonReportImageAddIcon.hidden = false;
        
        imageReportImagePreview.hidden = true;
        buttonReportImageRemove.hidden = true;
        buttonReportImageRemoveIcon.hidden = true;
    }
    
    func isReadyWithLocation() {
        mapReportLocation.hidden = false;
        buttonReportLocation.hidden = true;
        buttonReportLocationIcon.hidden = true;
    }

    func isUpdatingReportLocation() {
        print("isUpdatingReportLocation")
        buttonReportLocation.hidden = true;
        buttonReportLocationIcon.hidden = true;
    }

    func isReadyWithImage() {
        
//        buttonReportImage.hidden = true;
//        buttonReportImageAddIcon.hidden = true;
//
//        imageReportImagePreview.hidden = false;
//        buttonReportImageRemove.hidden = false;
//        buttonReportImageRemoveIcon.hidden = false;
//
//        imageReportImagePreview.alpha = 0;
//        buttonReportImageRemove.alpha = 0;
//        buttonReportImageRemoveIcon.alpha = 0;
//        
//        UIView.animateWithDuration(8, animations: {
//            self.imageReportImagePreview.alpha = 1;
//            self.buttonReportImageRemove.alpha = 1;
//            self.buttonReportImageRemoveIcon.alpha = 1;
//        })
//        
        
        
        buttonReportImage.hidden = true;
        buttonReportImageAddIcon.hidden = true;
        
        imageReportImagePreview.hidden = false;
        buttonReportImageRemove.hidden = false;
        buttonReportImageRemoveIcon.hidden = false;
    }

//    func loadImageFromUrl(url: String, view: UIImageView){
//        
//        // Create Url from string
//        let url = NSURL(string: url)!
//        
//        print(url)
//                
//        // Download task:
//        // - sharedSession = global NSURLCache, NSHTTPCookieStorage and NSURLCredentialStorage objects.
//        let task = NSURLSession.sharedSession().dataTaskWithURL(url) { (responseData, responseUrl, error) -> Void in
//            // if responseData is not null...
//            if let data = responseData{
//                
//                // execute in UI thread
//                dispatch_async(dispatch_get_main_queue(), { () -> Void in
//                    view.image = UIImage(data: data)
//                })
//            }
//        }
//        
//        // Run task
//        task.resume()
//    }
    
    @IBAction func startLocationServices(sender: AnyObject) {

        thisLocationManager.requestWhenInUseAuthorization()
        thisLocationManager.startUpdatingLocation()

        if( CLLocationManager.authorizationStatus() == CLAuthorizationStatus.AuthorizedWhenInUse){
            
            
            mapView.setCenterCoordinate((thisLocationManager.location?.coordinate)!, animated:true)
            
//            mapView.setCenterCoordinate(CLLocationCoordinate2D(latitude: (thisLocationManager.location?.coordinate.latitude)!, longitude: (thisLocationManager.location?.coordinate.longitude)!), zoomLevel: 14, animated: true)
            
            self.imageReportLocationPreviewIsSet = true
            self.isReadyWithLocation()
            self.tableView.reloadData()
        }
    }
    
    func mapView(mapView: MGLMapView, didUpdateUserLocation userLocation: MGLUserLocation?) {
        print("location updated")
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
        imageReportImagePreview.image = image
        self.dismissViewControllerAnimated(true, completion: {
            self.isReadyWithImage()
            self.imageReportImagePreviewIsSet = true
            self.tableView.reloadData()
        })
    }
    
    func attemptRemoveImageFromPreview(sender: AnyObject) {
        imageReportImagePreview.image = nil
        imageReportImagePreviewIsSet = false
        
        self.isReadyAfterRemove()
        tableView.reloadData()
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


}

