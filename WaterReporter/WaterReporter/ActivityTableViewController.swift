//
//  ActivityTableViewController.swift
//  WaterReporter
//
//  Created by Viable Industries on 7/25/16.
//  Copyright © 2016 Viable Industries, L.L.C. All rights reserved.
//

import ActiveLabel
import Alamofire
import Foundation
import Kingfisher
import SwiftyJSON
import UIKit

class ActivityTableViewController: UITableViewController {
    
    
    //
    // MARK: @IBOutlets
    //
    @IBOutlet var indicatorLoadingView: UIView!
    @IBOutlet var titleImageView: UIImageView!
    
    
    //
    // MARK: @IBActions
    //
    @IBAction func shareButtonClicked(sender: UIButton) {
        
        print("sender.tag \(sender.tag)")
        
        let _thisReport = JSON(self.reports[(sender.tag)])
        let reportId: String = "\(_thisReport["id"])"
        var objectsToShare: [AnyObject] = [AnyObject]()
//        let reportText = "Check out this report on WaterReporter"
        let reportURL = NSURL(string: "https://www.waterreporter.org/community/reports/" + reportId)
        var reportImageURL:NSURL!
        let tmpImageView: UIImageView = UIImageView()
        
        // SHARE > REPORT > TITLE
        //
        objectsToShare.append("\(_thisReport["properties"]["report_description"])")

        // SHARE > REPORT > URL
        //
        objectsToShare.append(reportURL!)

        // SHARE > REPORT > IMAGE
        //
        let thisReportImageURL = _thisReport["properties"]["images"][0]["properties"]["square"]

        if thisReportImageURL != nil {
            reportImageURL = NSURL(string: String(thisReportImageURL))
        }
        
        tmpImageView.kf_setImageWithURL(reportImageURL, placeholderImage: nil, optionsInfo: nil, progressBlock: nil, completionHandler: {
            (image, error, cacheType, imageUrl) in
            
            if (image != nil) {
                objectsToShare.append(Image(CGImage: (image?.CGImage)!, scale: (image?.scale)!, orientation: UIImageOrientation.Up))
                
                let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
                
                activityVC.popoverPresentationController?.sourceView = sender

                self.presentViewController(activityVC, animated: true, completion: nil)
            }
            else {
                let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
                
                activityVC.popoverPresentationController?.sourceView = sender

                self.presentViewController(activityVC, animated: true, completion: nil)
            }
        })
        
    }

    @IBAction func loadCommentOwnerProfile(sender: UIButton) {
        
        let nextViewController = self.storyBoard.instantiateViewControllerWithIdentifier("ProfileTableViewController") as! ProfileTableViewController
        
        let _thisReport = JSON(self.reports[(sender.tag)])
        
        nextViewController.userId = "\(_thisReport["properties"]["owner"]["id"])"
        nextViewController.userObject = _thisReport["properties"]["owner"]
        
        self.navigationController?.pushViewController(nextViewController, animated: true)
    }

    @IBAction func loadTerritoryProfile(sender: UIButton) {
        
        let nextViewController = self.storyBoard.instantiateViewControllerWithIdentifier("TerritoryViewController") as! TerritoryViewController
        
        let _thisReport = JSON(self.reports[(sender.tag)])
        
        if "\(_thisReport["properties"]["territory_id"])" != "" && "\(_thisReport["properties"]["territory_id"])" != "null" {

            nextViewController.territory = "\(_thisReport["properties"]["territory"]["properties"]["huc_8_name"])"
            nextViewController.territoryId = "\(_thisReport["properties"]["territory_id"])"
            nextViewController.territoryHUC8Code = "\(_thisReport["properties"]["territory"]["properties"]["huc_8_code"])"
            
            self.navigationController?.pushViewController(nextViewController, animated: true)
        }
    }

    
    //
    // MARK: Variables
    //
    let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)

//    var reports = [AnyObject]()
    
    var reports: NSMutableArray = NSMutableArray()
    var singleReport: Bool = false
    var page: Int = 1
    
    var like: LikeController = LikeController.init()
    
    var likeDelay: NSTimer = NSTimer()
    var unlikeDelay: NSTimer = NSTimer()
    
    //
    // MARK: Overrides
    //
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //
        // Enable scroll to top of UITableView when title 
        // bar is tapped
        //
        self.tableView.scrollEnabled = true
        self.tableView.scrollsToTop = true
        
        //
        // Load 10 newest reports from API on Activity View load
        //
        if (!singleReport) {

            //
            // Display loading indicator
            //
            self.loading()
            
            if (self.refreshControl == nil) {
                self.refreshControl = UIRefreshControl()
            }
            
            self.reports = []
            self.page = 1
            self.tableView.reloadData()

            //
            // Set the Navigation Bar title
            //
            self.navigationItem.title = "Activity"
            self.navigationItem.titleView = titleImageView
            
            self.navigationItem.setHidesBackButton(true, animated:true);
            
            //
            // Setup pull to refresh functionality for our TableView
            //
            self.refreshControl?.addTarget(self, action: #selector(ActivityTableViewController.refreshTableView(_:)), forControlEvents: UIControlEvents.ValueChanged)

            self.loadReports()
        }
        
    }
    
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

        if (!singleReport) {
            self.tableView.separatorStyle = UITableViewCellSeparatorStyle.SingleLine
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        
        self.navigationController?.navigationBarHidden = false

        
        //
        // We need to execute the necessary code here to make
        // sure the Report Single view displays from the map view
        // and other views
        //
        self.tableView.rowHeight = UITableViewAutomaticDimension;
        self.tableView.estimatedRowHeight = 600.0;
        self.tableView.backgroundColor = UIColor.whiteColor()
        self.tableView.scrollsToTop = true
        
        //
        // Special directions for Single Report view
        //
        if (singleReport) {
            
            //
            // For single report view we need to disable pull-to-refresh
            //
            self.refreshControl = nil
            self.tableView.separatorStyle = UITableViewCellSeparatorStyle.None
            self.tableView.reloadData()
        }
        
    }

    
    func loadReports(isRefreshingReportsList: Bool = false) {
        
        //
        // Send a request to the defined endpoint with the given parameters
        //
        let parameters = [
            "q": "{\"order_by\": [{\"field\":\"report_date\",\"direction\":\"desc\"},{\"field\":\"id\",\"direction\":\"desc\"}]}",
            "page": self.page
        ]
        
        Alamofire.request(.GET, Endpoints.GET_MANY_REPORTS, parameters: parameters as? [String : AnyObject])
            .responseJSON { response in
                
                switch response.result {
                case .Success(let value):
                    
                    //
                    // Choose whether or not the reports should refresh or
                    // whether loaded reports should be appended to the existing
                    // list of reports
                    //
                    if (isRefreshingReportsList) {
                        self.reports = (value["features"] as! NSArray).mutableCopy() as! NSMutableArray
                        
                        self.refreshControl?.endRefreshing()
                    }
                    else {
                        self.reports.addObjectsFromArray(value["features"] as! NSArray as [AnyObject])
                    }

                    self.tableView.reloadData()

                    //print(value["features"])
                    self.page += 1
                    
                    //
                    // Dismiss the loading indicator
                    //
                    self.loadingComplete()
                    
                case .Failure(let error):
                    print(error)
                    break
                }
                
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "reportToActivityMap" {
            let destViewController = segue.destinationViewController as! ActivityMapViewController
            destViewController.reportObject = self.reports[sender!.tag]
        } else if segue.identifier == "reportToReportComments" {
            let destViewController = segue.destinationViewController as! CommentsTableViewController
            let report = self.reports[(sender?.tag)!]
            destViewController.report = report
        } else if segue.identifier == "reportToReportLikes" {
            let destViewController = segue.destinationViewController as! LikesTableViewController
            let report = self.reports[(sender?.tag)!]
            destViewController.report = report
        }
    }
    
    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.reports.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCellWithIdentifier("SingleReport", forIndexPath: indexPath) as! TableViewCell
        
        //
        // Make sure we aren't loading old images into the new cells as
        // additional reports are loaded
        //
        if (self.reports.count >= 1) {
            //
            // REPORT OBJECT
            //
            let report = self.reports[indexPath.row].objectForKey("properties")
            let reportJson = JSON(report!)
            cell.reportObject = report
            
            let reportDescription = report?.objectForKey("report_description")
            let reportImages = report?.objectForKey("images")![0]?.objectForKey("properties")
            //        let reportClosed = report?.objectForKey("closed_by")
            
            let reportOwner = report?.objectForKey("owner")?.objectForKey("properties")
            
            
            
            //
            // Territory
            //
            let reportTerritory = report?.objectForKey("territory") as? NSDictionary
            
            var reportTerritoryName: String? = "Unknown Watershed"
            if let thisReportTerritory = reportTerritory?.objectForKey("properties")?.objectForKey("huc_8_name") as? String {
                reportTerritoryName = (thisReportTerritory) + " Watershed"
            }
            
            cell.reportTerritoryName.text = reportTerritoryName
            
            cell.reportTerritoryButton.tag = indexPath.row
            cell.reportTerritoryButton.addTarget(self, action: #selector(ActivityTableViewController.loadTerritoryProfile(_:)), forControlEvents: .TouchUpInside)

            
            
            //
            // Comment Count
            //
            let reportComments = report?.objectForKey("comments") as! NSArray
            
            
            var reportCommentsCountText: String = "0 comments"
            
            if reportComments.count == 1 {
                reportCommentsCountText = "1 comment"
            }
            else if reportComments.count >= 1 {
                reportCommentsCountText = String(reportComments.count) + " comments"
            }
            else {
                reportCommentsCountText = "0 comments"
            }
            
            cell.reportCommentCount.tag = indexPath.row
            cell.reportCommentButton.tag = indexPath.row
            
            cell.reportCommentCount.setTitle(reportCommentsCountText, forState: UIControlState.Normal)
            
            if (reportJson["closed_by"] != nil) {
                let badgeImage: UIImage = UIImage(named: "icon--Badge")!
                cell.reportCommentButton.setImage(badgeImage, forState: .Normal)
                
            } else {
                let badgeImage: UIImage = UIImage(named: "Icon--Comment")!
                cell.reportCommentButton.setImage(badgeImage, forState: .Normal)
            }
            
            // Likes Count
            //
            let reportLikes = report?.objectForKey("likes") as! NSArray
            
            var reportLikesCountText: String = "0 likes"
            
            if reportLikes.count == 1 {
                reportLikesCountText = "1 like"
                cell.reportLikeCount.hidden = false
            }
            else if reportLikes.count >= 1 {
                reportLikesCountText = String(reportLikes.count) + " likes"
                cell.reportLikeCount.hidden = false
            }
            else {
                reportLikesCountText = "0 likes"
                cell.reportLikeCount.hidden = true
            }
            
            cell.reportLikeCount.tag = indexPath.row
            cell.reportLikeCount.setTitle(reportLikesCountText, forState: UIControlState.Normal)

            // Report Like Button
            //
            cell.reportLikeButton.tag = indexPath.row
            
            let _user_id_number = NSUserDefaults.standardUserDefaults().objectForKey("currentUserAccountUID") as! NSNumber
            let _user_id_integer = _user_id_number.integerValue
            
            if _user_id_integer != 0 {
                
                let _hasLiked = self.like.userHasLikedReport(reportJson, _current_user_id: _user_id_integer)
                
                cell.reportLikeButton.setImage(UIImage(named: "icon--heart"), forState: .Normal)
                
                if (_hasLiked) {
                    cell.reportLikeButton.removeTarget(nil, action: nil, forControlEvents: .AllEvents)
                    cell.reportLikeButton.addTarget(self, action: #selector(unlikeCurrentReport(_:)), forControlEvents: .TouchUpInside)
                    cell.reportLikeButton.setImage(UIImage(named: "icon--heartred"), forState: .Normal)
                }
                else {
                    cell.reportLikeButton.removeTarget(nil, action: nil, forControlEvents: .AllEvents)
                    cell.reportLikeButton.addTarget(self, action: #selector(likeCurrentReport(_:)), forControlEvents: .TouchUpInside)
                }
                
            }
            
            
            //
            // GROUPS
            //
            let reportGroups = report?.objectForKey("groups") as? NSArray
            var reportGroupsNames: String? = ""
            
            let reportGroupsTotal = reportGroups!.count
            var reportGroupsIncrementer = 1;
            
            for _group in reportGroups! as NSArray {
                if let thisGroupName = _group.objectForKey("properties")!.objectForKey("name") as? String {
                    if reportGroupsTotal == 1 || reportGroupsIncrementer == 1 {
                        reportGroupsNames = thisGroupName
                    }
                    else if (reportGroupsTotal > 1 && reportGroupsIncrementer > 1)  {
                        reportGroupsNames = reportGroupsNames! + ", " + thisGroupName
                    }
                    
                    reportGroupsIncrementer += 1
                }
                
                
            }
            
            cell.reportGroups.text = reportGroupsNames
            
            
            //
            // USER NAME
            //
            if let firstName = reportOwner?.objectForKey("first_name"),
                let lastName = reportOwner?.objectForKey("last_name") {
                cell.reportUserName.text = (firstName as! String) + " " + (lastName as! String)
            } else {
                cell.reportUserName.text = "Unknown Reporter"
            }
            
            if "\(reportDescription!)" != "null" || "\(reportDescription!)" != "" {
                cell.reportDescription.text = "\(reportDescription!)"
                cell.reportDescription.enabledTypes = [.Hashtag, .URL]
                cell.reportDescription.hashtagColor = UIColor.colorBrand()
                cell.reportDescription.hashtagSelectedColor = UIColor.colorDarkGray()
                
                cell.reportDescription.handleHashtagTap { hashtag in
                    print("Success. You just tapped the \(hashtag) hashtag")
                    
                    let nextViewController = self.storyBoard.instantiateViewControllerWithIdentifier("HashtagTableViewController") as! HashtagTableViewController
                    
                    nextViewController.hashtag = hashtag
                    
                    self.navigationController?.pushViewController(nextViewController, animated: true)
                    
                }

                cell.reportDescription.handleURLTap { url in
                    print("Success. You just tapped the \(url) url")
                    
                    UIApplication.sharedApplication().openURL(NSURL(string: "\(url)")!)

                    
//                    let nextViewController = self.storyBoard.instantiateViewControllerWithIdentifier("HashtagTableViewController") as! HashtagTableViewController
//                    
//                    nextViewController.hashtag = hashtag
//                    
//                    self.navigationController?.pushViewController(nextViewController, animated: true)
                    
                }

            }
            else {
                    cell.reportDescription.text = ""
            }

            //
            // REPORT > OWNER > PICTURE
            //
            cell.reportOwnerImageButton.tag = indexPath.row
            cell.reportOwnerImageButton.addTarget(self, action: #selector(ActivityTableViewController.loadCommentOwnerProfile(_:)), forControlEvents: .TouchUpInside)

            var reportOwnerImageURL:NSURL! = NSURL(string: "https://www.waterreporter.org/community/images/badget--MissingUser.png")
            
            if let thisReportOwnerImageURL = reportOwner?.objectForKey("picture") {
                reportOwnerImageURL = NSURL(string: String(thisReportOwnerImageURL))
            }
            
            cell.reportOwnerImage.kf_indicatorType = .Activity
            cell.reportOwnerImage.kf_showIndicatorWhenLoading = true
            
            cell.reportOwnerImage.kf_setImageWithURL(reportOwnerImageURL, placeholderImage: nil, optionsInfo: nil, progressBlock: nil, completionHandler: {
                (image, error, cacheType, imageUrl) in
                if (image != nil) {
                    cell.reportOwnerImage.image = UIImage(CGImage: (image?.CGImage)!, scale: (image?.scale)!, orientation: UIImageOrientation.Up)
                }
                cell.reportOwnerImage.layer.cornerRadius = cell.reportOwnerImage.frame.size.width / 2
                cell.reportOwnerImage.clipsToBounds = true
            })
            
            //
            // REPORT > IMAGE
            //
            var reportImageURL:NSURL!
            
            if let thisReportImageURL = reportImages?.objectForKey("square") {
                reportImageURL = NSURL(string: String(thisReportImageURL))
            }
            
            cell.reportImage.kf_indicatorType = .Activity
            cell.reportImage.kf_showIndicatorWhenLoading = true
            
            cell.reportImage.kf_setImageWithURL(reportImageURL, placeholderImage: nil, optionsInfo: nil, progressBlock: nil, completionHandler: {
                (image, error, cacheType, imageUrl) in
                
                if (image != nil) {
                    cell.reportImage.image = Image(CGImage: (image?.CGImage)!, scale: (image?.scale)!, orientation: UIImageOrientation.Up)
                }
            })
            
            //
            // DATE
            //
            let reportDate = reportJson["report_date"].string
            
            if (reportDate != nil) {
                let dateString: String = reportDate!
                
                let dateFormatter = NSDateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
                
                let stringToFormat = dateFormatter.dateFromString(dateString)
                dateFormatter.dateFormat = "MMM d, yyyy"
                
                let displayDate = dateFormatter.stringFromDate(stringToFormat!)
                
                if let thisDisplayDate: String? = displayDate {
                    cell.reportDate.text = thisDisplayDate
                }
            }
            else {
                cell.reportDate.text = ""
            }
            //
            // PASS ON DATA TO TABLE CELL
            //
            cell.reportGetDirectionsButton.tag = indexPath.row
            
            cell.reportDirectionsButton.tag = indexPath.row
            cell.reportDirectionsButton.addTarget(self, action: #selector(openDirectionsURL(_:)), forControlEvents: .TouchUpInside)
            
            cell.reportShareButton.tag = indexPath.row
            
            
            //
            // CONTIUOUS SCROLL
            //
            if (indexPath.row == self.reports.count - 5 && !singleReport) {
                self.loadReports()
            }
            
        }
        
        return cell
    }
    
    func openDirectionsURL(sender: UIBarButtonItem) {
        
        let reportId = sender.tag
        let report = self.reports[reportId]

        let reportGeometry = report.objectForKey("geometry")
        let reportGeometries = reportGeometry!.objectForKey("geometries")
        let reportCoordinates = reportGeometries![0].objectForKey("coordinates") as! Array<Double>
        
        UIApplication.sharedApplication().openURL(NSURL(string: "https://www.google.com/maps/dir//" + String(reportCoordinates[1]) + "," + String(reportCoordinates[0]))!)
    }
    
    func refreshTableView(refreshControl: UIRefreshControl) {
        
        //
        // Load 10 newest reports from API on Activity View load
        //
        if (!singleReport) {
            
            self.page = 1
            self.reports = []
            
            self.loadReports(true)
        } else {
            self.refreshControl?.endRefreshing()
        }
        
    }

    
    //
    // MARK: Like Functionality
    //
    func userHasLikedReport(_report: JSON, _current_user_id: Int) -> Bool {
        
        if (_report["likes"].count != 0) {
            for _like in _report["likes"] {
                if (_like.1["properties"]["owner_id"].intValue == _current_user_id) {
                    return true
                }
            }
        }
        
        return false
    }
    
    func updateReportLikeCount(indexPathRow: Int, addLike: Bool = true) {
        
        print("LikeController::updateReportLikeCount")
        
        let _indexPath = NSIndexPath(forRow: indexPathRow, inSection: 0)
        
        let _cell: TableViewCell = self.tableView.cellForRowAtIndexPath(_indexPath) as! TableViewCell
        
        // Change the Heart icon to red
        //
        if (addLike) {
            _cell.reportLikeButton.setImage(UIImage(named: "icon--heartred"), forState: .Normal)
            _cell.reportLikeButton.removeTarget(nil, action: nil, forControlEvents: .AllEvents)
            _cell.reportLikeButton.addTarget(self, action: #selector(unlikeCurrentReport(_:)), forControlEvents: .TouchUpInside)
        } else {
            _cell.reportLikeButton.setImage(UIImage(named: "icon--heart"), forState: .Normal)
            _cell.reportLikeButton.removeTarget(nil, action: nil, forControlEvents: .AllEvents)
            _cell.reportLikeButton.addTarget(self, action: #selector(likeCurrentReport(_:)), forControlEvents: .TouchUpInside)
        }

        // Update the total likes count
        //
        let _report = JSON(self.reports[(indexPathRow)].objectForKey("properties")!)
        let _report_likes_count: Int = _report["likes"].count
        
        // Check if we have previously liked this photo. If so, we need to take
        // that into account when adding a new like.
        //
        let _previously_liked: Bool = self.hasPreviouslyLike(_report["likes"])
        
        var _report_likes_updated_total: Int! = _report_likes_count
        
        if (addLike) {
            if (_previously_liked) {
                _report_likes_updated_total = _report_likes_count
            }
            else {
                _report_likes_updated_total = _report_likes_count+1
            }
        }
        else {
            if (_previously_liked) {
                _report_likes_updated_total = _report_likes_count-1
            }
            else {
                _report_likes_updated_total = _report_likes_count
            }
        }
        
        var reportLikesCountText: String = ""
        
        if _report_likes_updated_total == 1 {
            reportLikesCountText = "1 like"
            _cell.reportLikeCount.hidden = false
        }
        else if _report_likes_updated_total >= 1 {
            reportLikesCountText = "\(_report_likes_updated_total) likes"
            _cell.reportLikeCount.hidden = false
        }
        else {
            reportLikesCountText = "0 likes"
            _cell.reportLikeCount.hidden = false
        }
        
        _cell.reportLikeCount.setTitle(reportLikesCountText, forState: .Normal)
        
        
    }
    
    func hasPreviouslyLike(likes: JSON) -> Bool {
        
        print("hasPreviouslyLike::likes \(likes)")
        
        // LOOP OVER PREVIOUS LIKES AND SEE IF CURRENT USER ID IS ONE OF THE OWNER IDS
        
        let _user_id_number = NSUserDefaults.standardUserDefaults().objectForKey("currentUserAccountUID") as! NSNumber

        for _like in likes {
            if (_like.1["properties"]["owner_id"].intValue == _user_id_number.integerValue) {
                print("_like.1 \(_like.1)")
                return true
            }
        }
        
        return false
    }
    
    func likeCurrentReport(sender: UIButton) {
        
        print("LikeController::likeCurrentReport Incrementing Report Likes by 1")
        
        // Update the visible "# like" count of likes
        //
        self.updateReportLikeCount(sender.tag)
        
        // Restart delay
        //
        self.likeDelay.invalidate()
        
        let infoDict : [String : AnyObject] = ["sender": sender.tag]
        
        self.likeDelay = NSTimer.scheduledTimerWithTimeInterval(NSTimeInterval(1), target: self, selector: #selector(self.attemptLikeCurrentReport(_:)), userInfo: infoDict, repeats: false)

    }
    
    func attemptLikeCurrentReport(timer: NSTimer) {
        print("userInfo \(timer.userInfo!)")
        
        let _arguments = timer.userInfo as! [String : AnyObject]
        
        if let _sender_tag = _arguments["sender"] {
            
            let senderTag = _sender_tag.integerValue
            
            print("_sender_tag \(senderTag)")
            
            // Create necessary Authorization header for our request
            //
            let accessToken = NSUserDefaults.standardUserDefaults().objectForKey("currentUserAccountAccessToken")
            let _headers = [
                "Authorization": "Bearer " + (accessToken! as! String)
            ]
    
            //
            // PARAMETERS
            //
            let _report = JSON(self.reports[(senderTag)])
            let _report_id: String = "\(_report["id"])"
    
            let _parameters: [String:AnyObject] = [
                "report_id": _report_id
            ]
    
            Alamofire.request(.POST, Endpoints.POST_LIKE, parameters: _parameters, headers: _headers, encoding: .JSON)
                .responseJSON { response in
    
                    switch response.result {
                    case .Success(let value):
                        print("Response Success \(value)")
                        self.updateReportLikes(_report_id, reportSenderTag: senderTag)
                        
                        break
                    case .Failure(let error):
                        print("Response Failure \(error)")
                        break
                    }
                    
            }
        }
    }
    
    func unlikeCurrentReport(sender: UIButton) {
        
        print("LikeController::unlikeCurrentReport  Decrementing Report Likes by 1")
        // Update the visible "# like" count of likes
        //
        self.updateReportLikeCount(sender.tag, addLike: false)
        
        // Restart delay
        //
        self.unlikeDelay.invalidate()
        
        let infoDict : [String : AnyObject] = ["sender": sender.tag]
        
        self.unlikeDelay = NSTimer.scheduledTimerWithTimeInterval(NSTimeInterval(1), target: self, selector: #selector(self.attemptUnikeCurrentReport(_:)), userInfo: infoDict, repeats: false)

    }

    func attemptUnikeCurrentReport(timer: NSTimer) {
        print("userInfo \(timer.userInfo!)")
        
        let _arguments = timer.userInfo as! [String : AnyObject]
        
        if let _sender_tag = _arguments["sender"] {
            
            let senderTag = _sender_tag.integerValue
            
            print("_sender_tag \(senderTag)")
            
            // Create necessary Authorization header for our request
            //
            let accessToken = NSUserDefaults.standardUserDefaults().objectForKey("currentUserAccountAccessToken")
            let _headers = [
                "Authorization": "Bearer " + (accessToken! as! String)
            ]
    
            //
            // PARAMETERS
            //
            let _report = JSON(self.reports[(senderTag)])
            let _report_id: String = "\(_report["id"])"
    
            let _parameters: [String:AnyObject] = [
                "report_id": _report_id
            ]
    
            //
            // ENDPOINT
            //
            var _like_id: String = ""
            let _user_id_number = NSUserDefaults.standardUserDefaults().objectForKey("currentUserAccountUID") as! NSNumber
    
            if (_report["properties"]["likes"].count != 0) {
    
                for _like in _report["properties"]["likes"] {
                    if (_like.1["properties"]["owner_id"].intValue == _user_id_number.integerValue) {
                        print("_like.1 \(_like.1)")
                        _like_id = "\(_like.1["id"])"
                    }
                }
            }
    
            let _endpoint: String = Endpoints.DELETE_LIKE + "/\(_like_id)"
    
    
            //
            // REQUEST
            //
            Alamofire.request(.DELETE, _endpoint, parameters: _parameters, headers: _headers, encoding: .JSON)
                .responseJSON { response in
                    
                    switch response.result {
                    case .Success(let value):
                        print("Response Success \(value)")
                        
                        self.updateReportLikes(_report_id, reportSenderTag: senderTag)
                        
                        break
                    case .Failure(let error):
                        print("Response Failure \(error)")
                        break
                    }
                    
            }
        }

    }
        
    func updateReportLikes(_report_id: String, reportSenderTag: Int) {
        
        // Create necessary Authorization header for our request
        //
        let accessToken = NSUserDefaults.standardUserDefaults().objectForKey("currentUserAccountAccessToken")
        let _headers = [
            "Authorization": "Bearer " + (accessToken! as! String)
        ]
    
        Alamofire.request(.GET, Endpoints.GET_MANY_REPORTS + "/\(_report_id)", headers: _headers, encoding: .JSON)
            .responseJSON { response in
                
                switch response.result {
                case .Success(let value):
                    print("Response value \(value)")
                    
                    self.reports[reportSenderTag] = value
                    
                    break
                case .Failure(let error):
                    print("Response Failure \(error)")
                    break
                    
                }
                
        }
        
    }

}
