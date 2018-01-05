//
//  LikesTableViewController.swift
//  Water-Reporter
//
//  Created by Joshua Powell on 7/25/17.
//  Copyright © 2017 Viable Industries, L.L.C. All rights reserved.
//

import Alamofire
import Foundation
import SwiftyJSON
import UIKit

class LikesTableViewController : UITableViewController, UINavigationControllerDelegate {
    
    //
    // MARK: Variables
    //
    let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
    
    var report:AnyObject!
    var reportId:String!
    var likes: JSON = []
    var page: Int = 1
    
    
    //
    // MARK: IBActions
    //
    @IBAction func openUserMemberView(sender: UIButton) {
        
        let nextViewController = self.storyBoard.instantiateViewControllerWithIdentifier("ProfileTableViewController") as! ProfileTableViewController
        
        let _owner = self.likes["features"][sender.tag]["properties"]["owner"]
        
        print("Loading profile for \(_owner)")
        
        nextViewController.userId = "\(_owner["id"])"
        nextViewController.userObject = _owner
        
        nextViewController.navigationItem.title = "\(_owner["properties"]["first_name"]) \(_owner["properties"]["last_name"])"
        
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        
        self.navigationController!.pushViewController(nextViewController, animated: true)
    }

    
    //
    // MARK: Overrides
    //
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        
        self.likes = JSON(self.report)["properties"]["likes"]
        
        print("self.likes \(self.likes)")
        
        print("self.likes \(self.likes.count)")
        
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
        //self.loading()
        
        //
        //
        //
        if reportId != "" {
            self.page = 1
            self.attemptGetReportLikes(reportId)
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    //
    // MARK: Table Overrides
    //
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 96.0
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
                
        var _count: Int = 0
        
        if (self.likes.count >= 1) {
            _count = self.likes["features"].count
        }
        
        return _count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        print("tableView::cellForRowAtIndexPath")
                
        let cell = tableView.dequeueReusableCellWithIdentifier("userLikesTableViewCell", forIndexPath: indexPath) as! BasicTableViewCell
        
        let resultJSON = self.likes["features"][indexPath.row]["properties"]["owner"]["properties"]
        
        print("resultJSON \(resultJSON)")
        
        //
        // PEOPLE > TITLE
        //
        let _first_name = "\(resultJSON["first_name"])"
        let _last_name = "\(resultJSON["last_name"])"
        
        cell.searchResultTitle.backgroundColor = UIColor.clearColor()
        
        if (_first_name != "" && _last_name != "") {
            cell.searchResultTitle.text = "\(_first_name) \(_last_name)"
        }
        else {
            cell.searchResultTitle.text = "Anonymous User"
        }
        
        //
        // PEOPLE > IMAGE
        //
        var resultImageURL:NSURL! = NSURL(string: "https://www.waterreporter.org/community/images/badget--MissingUser.png")
        
        cell.searchResultImage.backgroundColor = UIColor.colorBackground()
        
        if (resultJSON["picture"] != "") {
            resultImageURL = NSURL(string: String(resultJSON["picture"]))
        }
        
        cell.searchResultImage.kf_indicatorType = .Activity
        cell.searchResultImage.kf_showIndicatorWhenLoading = true
        
        cell.searchResultImage.layer.cornerRadius = cell.searchResultImage.frame.size.width / 2
        cell.searchResultImage.clipsToBounds = true
        
        cell.searchResultImageConstraintWidth.constant = 64.0
        cell.searchResultImageConstraintPaddingLeft.constant = 16.0
        
        cell.searchResultImage.kf_setImageWithURL(resultImageURL, placeholderImage: nil, optionsInfo: nil, progressBlock: nil, completionHandler: {
            (image, error, cacheType, imageUrl) in
            if (image != nil) {
                cell.searchResultImage.image = UIImage(CGImage: (image?.CGImage)!, scale: (image?.scale)!, orientation: UIImageOrientation.Up)
            }
        })
        
        // PEOPLE > BUTTON
        //
        cell.searchResultLink.tag = indexPath.row
        
        
        // CONTINUOUS SCROLL
        //
        let _total_number_results: Int = self.likes["properties"]["num_results"].intValue
        
        if (indexPath.row == self.likes.count - 2 && self.likes.count < _total_number_results) {
            
            if let reportIdNumber = report?.objectForKey("id") as? NSNumber {
                reportId = "\(reportIdNumber)"
            }
            
            //
            // Display loading indicator
            //
            //self.loading()
            
            //
            //
            //
            if reportId != "" {
                self.attemptGetReportLikes(reportId, isRefreshingReportsList: false)
            }
            
        }
        
        return cell
    }
    
    
    //
    //
    //
    func attemptGetReportLikes(reportId: String, isRefreshingReportsList: Bool = false) {
        
        print("reportId \(reportId)")
        
        let _endpoint = Endpoints.GET_MANY_REPORTS + "/\(reportId)/likes"
        
        print("_endpoint \(_endpoint)")
        
        Alamofire.request(.GET, _endpoint)
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
                            self.likes = JSON(value)
                            self.refreshControl?.endRefreshing()
                        }
                        else {
                            self.likes = JSON(value)
                        }
                        
                        print("self.comments \(self.likes)")
                        
                        self.tableView.reloadData()
                        
                        self.page += 1
                        
                        //
                        // Dismiss the loading indicator
                        //
                        //self.loadingComplete()
                        
                        break;
                    
                    case .Failure(let error):
                        
                        print("Failure: \(error)")
                        
                        break;
                    
                }
                
        }
        
    }

    

}
