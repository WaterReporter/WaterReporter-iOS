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

class CommentsTableViewController: UITableViewController, NewCommentReportUpdaterDelegate {
    
    
    //
    // MARK: @IBOutlets
    //
    @IBOutlet weak var indicatorLoadingCommentsLabel: UILabel!
    @IBOutlet var indicatorLoadingView: UIView!
    @IBOutlet weak var indicatorLoadingComments: UIActivityIndicatorView!
    @IBOutlet weak var actionTakenBanner: UIView!
    @IBOutlet weak var actionTakenBannerHeight: NSLayoutConstraint!
    
    
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

    
    //
    // MARK: Variables
    //
    let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
    
    var report:AnyObject!
    var reportId:String!
    var comments: JSON?
    var page: Int = 1
    
    
    //
    // MARK: Overrides
    //
    override func viewDidLoad() {
        super.viewDidLoad()

        //
        // Display loading indicator
        //
        self.loading()

        //
        // Enable scroll to top of UITableView when title
        // bar is tapped
        //
        self.tableView.scrollEnabled = true
        self.tableView.scrollsToTop = true

        self.tableView.rowHeight = UITableViewAutomaticDimension;
        self.tableView.estimatedRowHeight = 400.0;

        //
        // Setup pull to refresh functionality for our TableView
        //
        self.refreshControl?.addTarget(self, action: #selector(CommentsTableViewController.refreshTableView(_:)), forControlEvents: UIControlEvents.ValueChanged)

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

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "reportCommentsToNewComment" {

            let nav = segue.destinationViewController as! UINavigationController
            let addReportcommentViewController = nav.topViewController as! CommentsNewTableViewController
            
            addReportcommentViewController.reportId = reportId
            addReportcommentViewController.report = JSON(report)
            addReportcommentViewController.delegate = self
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

            var commentOwnerImageURL:NSURL! = NSURL(string: "https://www.waterreporter.org/images/badget--MissingUser.png")
            
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
                cell.commentDescription.text = _commentBody
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
                    
                    cell.commentDescriptionImageHeightConstraint.constant = 200.0
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
                            self.refreshControl?.endRefreshing()
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
                            
                            self.actionTakenBanner.hidden = false
                            self.actionTakenBanner.frame.size.height = 130.0
                            self.actionTakenBannerHeight.constant = 130.0
                        }
                        else {
                            
                            
                            self.actionTakenBanner.frame.size.height = 0.0
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
    // Delegate impmenetation
    //
    func sendReport(reportId: String, report: AnyObject) {
        print("CommentsTableViewController::sendReport")
        self.report = report
        self.reportId = reportId
    }
    func reportLoadingComplete(isFinished: Bool) {
        print("CommentsTableViewController::reportLoadingComplete")
    }

}
