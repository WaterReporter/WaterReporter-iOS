//
//  CommentsTableViewController.swift
//  Water-Reporter
//
//  Created by Viable Industries on 10/29/16.
//  Copyright © 2016 Viable Industries, L.L.C. All rights reserved.
//

import Alamofire
import Foundation
import Kingfisher
import SwiftyJSON
import UIKit

class CommentsTableViewController: UITableViewController {
    
    var report:AnyObject!
    var reportId:String!
    var comments: JSON?
    var page: Int = 1

    override func viewDidLoad() {
        super.viewDidLoad()

        
        //
        // Enable scroll to top of UITableView when title
        // bar is tapped
        //
        self.tableView.scrollEnabled = true
        self.tableView.scrollsToTop = true

        //
        //
        //
        if let reportIdNumber = report?.objectForKey("id") as? NSNumber {
            reportId = "\(reportIdNumber)"
        }
        
        if reportId != "" {
            self.attemptGetReportComments(reportId)
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "reportCommentsToNewComment" {

            let nav = segue.destinationViewController as! UINavigationController
            let addReportcommentViewController = nav.topViewController as! CommentsNewTableViewController
            
            addReportcommentViewController.reportId = reportId
        }
    }

    
    //
    // MARK:
    //
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if self.comments == nil {
            return 1
        }
        
        return (self.comments?["features"].count)!
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("SingleReportComment", forIndexPath: indexPath) as! CommentTableViewCell
        
        
        //
        // Set data as a variable for a single comment (1 table view cell (a row))
        //
        if self.comments == nil {
            return cell
        }
        
        let _comment = self.comments!["features"][indexPath.row]
        
        print("comment \(_comment)")
        
        //
        // Comment Owner's Name + Image
        //
        let _commentOwner = _comment["properties"]["owner"]["properties"]
        if let _ownerFirstName = _commentOwner["first_name"].string,
            let _ownerLastName = _commentOwner["last_name"].string {
            cell.commentOwnerName.text = _ownerFirstName + " " + _ownerLastName
        }
        
        cell.commentOwnerImage.tag = indexPath.row
        cell.commentOwnerImageButton.tag = indexPath.row
        
        var commentOwnerImageURL:NSURL! = NSURL(string: "https://www.waterreporter.org/images/badget--MissingUser.png")
        
        if let thisCommentOwnerImageURL = _commentOwner["picture"].string {
            commentOwnerImageURL = NSURL(string: String(thisCommentOwnerImageURL))
        }
        
        cell.commentOwnerImage.kf_indicatorType = .Activity
        cell.commentOwnerImage.kf_showIndicatorWhenLoading = true
        
        cell.commentOwnerImage.kf_setImageWithURL(commentOwnerImageURL, placeholderImage: nil, optionsInfo: nil, progressBlock: nil, completionHandler: {
            (image, error, cacheType, imageUrl) in
            cell.commentOwnerImage.image = image
            cell.commentOwnerImage.layer.cornerRadius = cell.commentOwnerImage.frame.size.width / 2
            cell.commentOwnerImage.clipsToBounds = true
        })
        
        //
        // Comment Date
        //
        let dateString: String! = _comment["properties"]["created"].string

        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSS"
        
        let revisedDate: NSDate! = dateFormatter.dateFromString(dateString)
        dateFormatter.dateFormat = "MMM d, yyyy"
        
        let _commentDisplayDate = dateFormatter.stringFromDate(revisedDate)
        
        cell.commentDatePosted.text = _commentDisplayDate
        
        
        //
        // Comment Body
        //
        if let _commentBody = _comment["properties"]["body"].string {
            cell.commentDescription.text = _commentBody
        }
        
        //
        // Comment Image Body
        //
        let commentImages = _comment["properties"]["images"][0]["properties"]
        print("commentImages \(commentImages)")

        if let thisCommentImageURL = commentImages["square"].string {
            print("Comment needs to display an image \(thisCommentImageURL)")
            let commentImageURL = NSURL(string: String(thisCommentImageURL))

            cell.commentDescriptionImage.kf_indicatorType = .Activity
            cell.commentDescriptionImage.kf_showIndicatorWhenLoading = true
            
            cell.commentDescriptionImage.kf_setImageWithURL(commentImageURL, placeholderImage: nil, optionsInfo: nil, progressBlock: nil, completionHandler: {
                (image, error, cacheType, imageUrl) in
                cell.commentDescriptionImage.image = image
                cell.commentDescriptionImage.clipsToBounds = true
            })

        } else {
            print("Comment has no image")
            cell.commentDescriptionImage.image = nil
            cell.commentDescriptionImage.frame = CGRectMake(0, 0, 0, self.view.frame.size.width)
        }
        

        
        return cell
    }
    
    
    //
    // MARK:
    //
    func attemptGetReportComments(reportId: String) {
        
        // Define where we want to get our comments from
        let _endpoint: String = Endpoints.GET_MANY_REPORT_COMMENTS + "/" + reportId + "/comments"
        
        // Create necessary Authorization header for our request
        let accessToken = NSUserDefaults.standardUserDefaults().objectForKey("currentUserAccountAccessToken")
        let headers = [
            "Authorization": "Bearer " + (accessToken! as! String)
        ]
        
        let parameters = [
            "q": "{\"order_by\": [{\"field\":\"created\",\"direction\":\"asc\"},{\"field\":\"id\",\"direction\":\"desc\"}]}",
            "page": self.page
        ]

        Alamofire.request(.GET, _endpoint, parameters: parameters as! [String : AnyObject], headers: headers)
            .responseJSON { response in
                
                switch response.result {
                    case .Success(let value):
                        print("Success: \(value)")
                        
                        self.comments = JSON(value)
                        
                        self.tableView.reloadData()
                        
                        self.page += 1

                        break;
                    case .Failure(let error):
                        print("Failure: \(error)")
                        break;
                }
            }
        
    }
}
