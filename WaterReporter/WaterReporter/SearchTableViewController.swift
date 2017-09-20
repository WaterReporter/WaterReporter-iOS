//
//  SearchTableViewController.swift
//  Water-Reporter
//
//  Created by Joshua Powell on 4/11/17.
//  Copyright © 2017 Viable Industries, L.L.C. All rights reserved.
//

import Alamofire
import Foundation
import Kingfisher
import SwiftyJSON
import UIKit

class SearchTableViewController: UITableViewController, UISearchControllerDelegate, UISearchBarDelegate, UINavigationControllerDelegate {

    //
    // MARK: @IBOutlets
    //
    @IBOutlet var searchTabNavigation: UIView!
    
    @IBOutlet weak var tableHeaderView: UIView!

    @IBOutlet weak var buttonPeople: UIButton!
    @IBOutlet weak var buttonGroups: UIButton!
    @IBOutlet weak var buttonWatersheds: UIButton!
    @IBOutlet weak var buttonTags: UIButton!


    //
    // MARK: @IBActions
    //
    @IBAction func openSearchDetailView(sender: UIButton) {

        
        if (self.selectedType == "People") {
            let _object = JSON(self.trendingPeople[sender.tag])

            let nextViewController = self.storyBoard.instantiateViewControllerWithIdentifier("ProfileTableViewController") as! ProfileTableViewController
            
            nextViewController.userId = "\(_object["id"])"
            nextViewController.userObject = _object
            self.navigationController!.pushViewController(nextViewController, animated: true)
        }
        else if (self.selectedType == "Watersheds") {
            let _object = JSON(self.trendingWatersheds[sender.tag])

            let nextViewController = self.storyBoard.instantiateViewControllerWithIdentifier("TerritoryViewController") as! TerritoryViewController
            
            nextViewController.territory = "\(_object["properties"]["huc_8_name"])"
            nextViewController.territoryId = "\(_object["id"])"
            nextViewController.territoryHUC8Code = "\(_object["properties"]["huc_8_code"])"
            self.navigationController!.pushViewController(nextViewController, animated: true)
        }
        else if (self.selectedType == "Groups") {
            let _object = JSON(self.trendingGroups[sender.tag])

            let nextViewController = self.storyBoard.instantiateViewControllerWithIdentifier("OrganizationTableViewController") as! OrganizationTableViewController
                        
            nextViewController.groupId = "\(_object["id"])"
            nextViewController.groupObject = _object
            nextViewController.groupProfile = _object
            
            self.navigationController!.pushViewController(nextViewController, animated: true)
        }
        else if (self.selectedType == "Tags") {
            let _object = JSON(self.trendingTags[sender.tag])

            let nextViewController = self.storyBoard.instantiateViewControllerWithIdentifier("HashtagTableViewController") as! HashtagTableViewController
            
            nextViewController.hashtag = "\(_object["properties"]["tag"])"

            self.navigationController!.pushViewController(nextViewController, animated: true)
        }

    }
    
    @IBAction func changeSearchType(sender: UIButton) {
        
        print("self::changeSearchType")
        
        if self.selectedType != sender.currentTitle! {
            
            let _newType: String = sender.currentTitle!
            
            // Cancel and clear search between tab switching
            //
            self.selectedType = _newType
            
            self.tableView.reloadData()

            if (_newType == "People") {
                self.buttonPeople.setTitleColor(UIColor.colorBrand(), forState: .Normal)
                self.buttonWatersheds.setTitleColor(UIColor.grayColor(), forState: .Normal)
                self.buttonGroups.setTitleColor(UIColor.grayColor(), forState: .Normal)
                self.buttonTags.setTitleColor(UIColor.grayColor(), forState: .Normal)
            }
            else if (_newType == "Watersheds") {
                self.buttonPeople.setTitleColor(UIColor.grayColor(), forState: .Normal)
                self.buttonWatersheds.setTitleColor(UIColor.colorBrand(), forState: .Normal)
                self.buttonGroups.setTitleColor(UIColor.grayColor(), forState: .Normal)
                self.buttonTags.setTitleColor(UIColor.grayColor(), forState: .Normal)
            }
            else if (_newType == "Groups") {
                self.buttonPeople.setTitleColor(UIColor.grayColor(), forState: .Normal)
                self.buttonWatersheds.setTitleColor(UIColor.grayColor(), forState: .Normal)
                self.buttonGroups.setTitleColor(UIColor.colorBrand(), forState: .Normal)
                self.buttonTags.setTitleColor(UIColor.grayColor(), forState: .Normal)
            }
            else if (_newType == "Tags") {
                self.buttonPeople.setTitleColor(UIColor.grayColor(), forState: .Normal)
                self.buttonWatersheds.setTitleColor(UIColor.grayColor(), forState: .Normal)
                self.buttonGroups.setTitleColor(UIColor.grayColor(), forState: .Normal)
                self.buttonTags.setTitleColor(UIColor.colorBrand(), forState: .Normal)
            }
        }
    }
    


    //
    // MARK: Global Variables
    //
    let searchController = UISearchController(searchResultsController: nil)

    var trendingPeople: [AnyObject] = [AnyObject]()
    var trendingPeopleJSON: JSON!
    var trendingWatersheds = [AnyObject]()
    var trendingWatershedsJSON: JSON!
    var trendingGroups = [AnyObject]()
    var trendingGroupsJSON: JSON!
    var trendingTags = [AnyObject]()
    var trendingTagsJSON: JSON!

    var timerPeople = NSTimer()
    var timerWatersheds = NSTimer()
    var timerGroups = NSTimer()
    var timerTags = NSTimer()

    var pagePeople: Int = 1
    var pageWatersheds: Int = 1
    var pageGroups: Int = 1
    var pageTags: Int = 1

    var selectedType = "People"
    var allResultsLoaded: Bool = false
    let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)

    var searchText: String = ""
    var isSearching: Bool = false
    var isEmpty: Bool = false
    var isEmptyPeople: Bool = false
    var isEmptyGroups: Bool = false
    var isEmptyWatersheds: Bool = false
    var isEmptyTags: Bool = false

    
    //
    // MARK: Overrides
    //
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.definesPresentationContext = true

        // Configure basic search bar display
        //
        self.searchController.delegate = self
        self.searchController.searchBar.delegate = self
        self.searchController.dimsBackgroundDuringPresentation = false
        self.searchController.searchBar.barTintColor = UIColor.colorBackground()
        
        self.searchController.searchBar.searchResultsButtonSelected = true
        
        // Add the SearchBar to the TableView
        //
        tableHeaderView.addSubview(searchController.searchBar)
        self.tableView.tableHeaderView = tableHeaderView
        
        // Customize the display of the SearchBar
        //
        self.searchController.searchBar.layer.borderWidth = 0.0
        self.searchController.searchBar.layer.borderColor = UIColor.clearColor().CGColor
        self.searchController.searchBar.backgroundImage = UIImage()
        
        self.searchController.searchBar.backgroundColor = UIColor.colorBackground()
        
        // Customize the display beahviour of the StatusBar
        //
        self.setStatusBarBackgroundColor(UIColor.colorBackground())
        
        
        // Load in trending users as the default
        //
        self.loadTrendingRecords(Endpoints.TRENDING_PEOPLE, type: "People", isRefreshingUserList: true)
        self.loadTrendingRecords(Endpoints.TRENDING_TERRITORY, type: "Watersheds", isRefreshingUserList: true)
        self.loadTrendingRecords(Endpoints.TRENDING_GROUP, type: "Groups", isRefreshingUserList: true)
        self.loadTrendingRecords(Endpoints.TRENDING_HASHTAG, type: "Tags", isRefreshingUserList: true)

    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    //
    // MARK: Search Overrides
    //
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {

        // Since we are executing an entirely new search we need to make sure
        // that we reset all of our result variables
        //
        self.pagePeople = 1
        self.pageWatersheds = 1
        self.pageGroups = 1
        self.pageTags = 1
        
        self.searchText = ""

        self.trendingPeople = [AnyObject]()
        self.trendingWatersheds = [AnyObject]()
        self.trendingGroups = [AnyObject]()
        self.trendingTags = [AnyObject]()

        self.timerPeople = NSTimer()
        self.timerWatersheds = NSTimer()
        self.timerGroups = NSTimer()
        self.timerTags = NSTimer()

        self.loadTrendingRecords(Endpoints.TRENDING_PEOPLE, type: "People", isRefreshingUserList: true)
        self.loadTrendingRecords(Endpoints.TRENDING_TERRITORY, type: "Watersheds", isRefreshingUserList: true)
        self.loadTrendingRecords(Endpoints.TRENDING_GROUP, type: "Groups", isRefreshingUserList: true)
        self.loadTrendingRecords(Endpoints.TRENDING_HASHTAG, type: "Tags", isRefreshingUserList: true)
        
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        print("searchBar::textDidChange \(searchText)")
        
        // Everytime the text changes, updated the `searchText` and restart the
        // timerh
        //
        if searchText == "" {
            self.searchBarCancelButtonClicked(searchBar)
        }
        
        self.searchText = searchText
        self.isSearching = true
        self.tableView.reloadData()
        
        self.timerPeople.invalidate()
        self.timerWatersheds.invalidate()
        self.timerGroups.invalidate()
        self.timerTags.invalidate()
        
        self.pagePeople = 1
        self.pageWatersheds = 1
        self.pageGroups = 1
        self.pageTags = 1

        self.timerPeople = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(SearchTableViewController.searchForPeople(_:)), userInfo: nil, repeats: false)
        self.timerWatersheds = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(SearchTableViewController.searchForWatersheds(_:)), userInfo: nil, repeats: false)
        self.timerGroups = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(SearchTableViewController.searchForGroups(_:)), userInfo: nil, repeats: false)
        self.timerTags = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(SearchTableViewController.searchForTags(_:)), userInfo: nil, repeats: false)
        
    }
    
    
    //
    // MARK: Override General View Styles
    //
    func setStatusBarBackgroundColor(color: UIColor) {
        
        guard  let statusBar = UIApplication.sharedApplication().valueForKey("statusBarWindow")?.valueForKey("statusBar") as? UIView else {
            return
        }
        
        statusBar.backgroundColor = color
    }
    
    
    //
    // MARK: Table Overrides
    //
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 96.0
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        var _count: Int = 0
        
        if self.searchText != "" && self.isSearching == true {
            _count = 1
        }
        else if self.selectedType == "People" {
            _count = self.trendingPeople.count
            self.isEmptyPeople = false
            
            if _count == 0 && self.searchText != "" {
                self.isEmptyPeople = true
                _count = 1
            }

        }
        else if self.selectedType == "Watersheds" {
            _count = self.trendingWatersheds.count
            self.isEmptyWatersheds = false
            
            if _count == 0 && self.searchText != "" {
                self.isEmptyWatersheds = true
                _count = 1
            }

        }
        else if self.selectedType == "Groups" {
            _count = self.trendingGroups.count
            self.isEmptyGroups = false

            if _count == 0 && self.searchText != "" {
                self.isEmptyGroups = true
                _count = 1
            }
            
        }
        else if self.selectedType == "Tags" {
            _count = self.trendingTags.count
            self.isEmptyTags = false

            if _count == 0 && self.searchText != "" {
                self.isEmptyTags = true
                _count = 1
            }
        }
        
        return _count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        print("tableView::cellForRowAtIndexPath")
        
        if (self.searchText != "" && self.isSearching) {
            let cell = tableView.dequeueReusableCellWithIdentifier("searchLoadingTableViewCell", forIndexPath: indexPath)
            return cell
        }
        else if self.selectedType == "People" && self.searchText != "" && self.isEmptyPeople == true {
            let cell = tableView.dequeueReusableCellWithIdentifier("searchEmptyTableViewCell", forIndexPath: indexPath)
            return cell
        }
        else if self.selectedType == "Watersheds" && self.searchText != "" && self.isEmptyWatersheds == true {
            let cell = tableView.dequeueReusableCellWithIdentifier("searchEmptyTableViewCell", forIndexPath: indexPath)
            return cell
        }
        else if self.selectedType == "Groups" && self.searchText != "" && self.isEmptyGroups == true {
            let cell = tableView.dequeueReusableCellWithIdentifier("searchEmptyTableViewCell", forIndexPath: indexPath)
            return cell
        }
        else if self.selectedType == "Tags" && self.searchText != "" && self.isEmptyTags == true {
            let cell = tableView.dequeueReusableCellWithIdentifier("searchEmptyTableViewCell", forIndexPath: indexPath)
            return cell
        }
        else if (self.selectedType == "People" && self.isEmptyPeople == false) {

            if indexPath.row > self.trendingPeople.count {
                return UITableViewCell()
            }
            
            let cell = tableView.dequeueReusableCellWithIdentifier("searchPeopleTableViewCell", forIndexPath: indexPath) as! BasicTableViewCell

            let result = self.trendingPeople[indexPath.row].objectForKey("properties")
            let resultJSON = JSON(result!)

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
            
            if let thisResultImageURL = result?.objectForKey("picture") {
                resultImageURL = NSURL(string: String(thisResultImageURL))
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
            var _total_number_results = 0
            
            if self.trendingPeopleJSON["num_results"] != nil {
                _total_number_results = self.trendingPeopleJSON["num_results"].int!
            }
            else {
                _total_number_results = self.trendingPeopleJSON["properties"]["num_results"].int!
            }

            if (indexPath.row == self.trendingPeople.count - 2 && self.trendingPeople.count < _total_number_results) {
                
                if (self.searchText != "") {
                    self.searchForPeople(false)
                }
                else {
                    self.loadTrendingRecords(Endpoints.TRENDING_PEOPLE, type: "People", isRefreshingUserList: false)
                }
                
            }

            return cell

        }
        else if (self.selectedType == "Watersheds" && self.isEmptyWatersheds == false) {
            
            if indexPath.row > self.trendingWatersheds.count {
                return UITableViewCell()
            }
            
            let result = self.trendingWatersheds[indexPath.row].objectForKey("properties")
            let resultJSON = JSON(result!)
        
            let cell = tableView.dequeueReusableCellWithIdentifier("searchWatershedsTableViewCell", forIndexPath: indexPath) as! BasicTableViewCell

            //
            // WATERSHED > TITLE
            //
            let _watershed_name = "\(resultJSON["huc_8_name"])"
            
            cell.searchResultTitle.backgroundColor = UIColor.clearColor()
            
            if (_watershed_name != "") {
                cell.searchResultTitle.text = "\(_watershed_name)"
            }
            else {
                cell.searchResultTitle.text = "Unknown HUC 8 Watershed"
            }
            
            //
            // WATERSHED > IMAGE
            //
            cell.searchResultImageConstraintWidth.constant = 0.0
            cell.searchResultImageConstraintPaddingLeft.constant = 0.0
            
            // WATERSHED > BUTTON
            //
            cell.searchResultLink.tag = indexPath.row
            
            // CONTINUOUS SCROLL
            //
            var _total_number_results = 0
            
            if self.trendingWatershedsJSON["num_results"] != nil {
                _total_number_results = self.trendingWatershedsJSON["num_results"].int!
            }
            else {
                _total_number_results = self.trendingWatershedsJSON["properties"]["num_results"].int!
            }
            
            if (indexPath.row == self.trendingWatersheds.count - 2 && self.trendingWatersheds.count < _total_number_results) {
                
                if (self.searchText != "") {
                    self.searchForWatersheds(false)
                }
                else {
                    self.loadTrendingRecords(Endpoints.TRENDING_TERRITORY, type: "Watersheds", isRefreshingUserList: false)
                }
                
            }

            return cell
        }
        else if (self.selectedType == "Groups" && self.isEmptyGroups == false) {
            
            if indexPath.row > self.trendingGroups.count {
                return UITableViewCell()
            }
            
            let result = self.trendingGroups[indexPath.row].objectForKey("properties")
            let resultJSON = JSON(result!)
            
            let cell = tableView.dequeueReusableCellWithIdentifier("searchGroupsTableViewCell", forIndexPath: indexPath) as! BasicTableViewCell

            //
            // GROUP > TITLE
            //
            let _name = "\(resultJSON["name"])"
            
            cell.searchResultTitle.backgroundColor = UIColor.clearColor()
            
            if (_name != "") {
                cell.searchResultTitle.text = "\(_name)"
            }
            else {
                cell.searchResultTitle.text = "Unknown Group Name"
            }
            
            //
            // GROUP > IMAGE
            //
            var resultImageURL:NSURL! = NSURL(string: "https://www.waterreporter.org/community/images/badget--MissingUser.png")
            
            cell.searchResultImage.backgroundColor = UIColor.colorBackground()

            if let thisResultImageURL = result?.objectForKey("picture") {
                resultImageURL = NSURL(string: String(thisResultImageURL))
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
            
            // GROUP > BUTTON
            //
            cell.searchResultLink.tag = indexPath.row
            
            // CONTINUOUS SCROLL
            //
            var _total_number_results = 0
            
            if self.trendingGroupsJSON["num_results"] != nil {
                _total_number_results = self.trendingGroupsJSON["num_results"].int!
            }
            else {
                _total_number_results = self.trendingGroupsJSON["properties"]["num_results"].int!
            }
            
            if (indexPath.row == self.trendingGroups.count - 2 && self.trendingGroups.count < _total_number_results) {
                
                if (self.searchText != "") {
                    self.searchForGroups(false)
                }
                else {
                    self.loadTrendingRecords(Endpoints.TRENDING_GROUP, type: "Groups", isRefreshingUserList: false)
                }
                
            }
            
            return cell
        }
        else if (self.selectedType == "Tags" && self.isEmptyTags == false) {
            
            if indexPath.row > self.trendingTags.count {
                return UITableViewCell()
            }
            
            let result = self.trendingTags[indexPath.row].objectForKey("properties")
            let resultJSON = JSON(result!)
            
            let cell = tableView.dequeueReusableCellWithIdentifier("searchTagsTableViewCell", forIndexPath: indexPath) as! BasicTableViewCell

            //
            // TAG > TITLE
            //
            let _name = "\(resultJSON["tag"])"
            
            cell.searchResultTitle.backgroundColor = UIColor.clearColor()
            
            if (_name != "") {
                cell.searchResultTitle.text = "#\(_name)"
            }
            else {
                cell.searchResultTitle.text = ""
            }
            
            //
            // TAG > IMAGE
            //
            // cell.searchResultImage.image = UIImage(named: "icon--hashtag")
            cell.searchResultImageConstraintWidth.constant = 0.0
            cell.searchResultImageConstraintPaddingLeft.constant = 0.0

            
            // TAG > BUTTON
            //
            cell.searchResultLink.tag = indexPath.row
            
            // CONTINUOUS SCROLL
            //
            var _total_number_results = 0
            
            if self.trendingTagsJSON["num_results"] != nil {
                _total_number_results = self.trendingTagsJSON["num_results"].int!
            }
            else {
                _total_number_results = self.trendingTagsJSON["properties"]["num_results"].int!
            }
            
            if (indexPath.row == self.trendingTags.count - 2 && self.trendingTags.count < _total_number_results) {
                
                if (self.searchText != "") {
                    self.searchForTags(false)
                }
                else {
                    self.loadTrendingRecords(Endpoints.TRENDING_HASHTAG, type: "Tags", isRefreshingUserList: false)
                }
                
            }
            
            return cell
        }
        else {
            return UITableViewCell()
        }

    }

    
    
    //
    // MARK: Custom Methods
    //
    func loadTrendingRecords(endpoint: String, type: String, isRefreshingUserList: Bool = false) {
        
        //
        // Send a request to the defined endpoint with the given parameters
        //
        if type == "People" {
            let parameters = [
                "page":"\(self.pagePeople)"
            ]
            self.loadTrendingRecordsWithDynamicPage(parameters, endpoint: endpoint, type: type, isRefreshingUserList: isRefreshingUserList)
        }
        else if type == "Watersheds" {
            let parameters = [
                "page":"\(self.pageWatersheds)"
            ]

            self.loadTrendingRecordsWithDynamicPage(parameters, endpoint: endpoint, type: type, isRefreshingUserList: isRefreshingUserList)
        }
        else if type == "Groups" {
            let parameters = [
                "page":"\(self.pageGroups)"
            ]
            self.loadTrendingRecordsWithDynamicPage(parameters, endpoint: endpoint, type: type, isRefreshingUserList: isRefreshingUserList)
        }
        else if type == "Tags" {
            let parameters = [
                "page":"\(self.pageTags)"
            ]
            self.loadTrendingRecordsWithDynamicPage(parameters, endpoint: endpoint, type: type, isRefreshingUserList: isRefreshingUserList)
        }
        
    }
    
    func loadTrendingRecordsWithDynamicPage(parameters: [String: String], endpoint: String, type: String, isRefreshingUserList: Bool = false) {
        
        Alamofire.request(.GET, endpoint, parameters: parameters)
            .responseJSON { response in
                
                switch response.result {
                case .Success(let value):
                    
                    if (isRefreshingUserList) {
//                        print("loadTrendingRecords::complete::isRefreshingUserList \(value)")
                        
                        if type == "People" {
                            self.trendingPeople = value["objects"] as! [AnyObject]
                            self.trendingPeopleJSON = JSON(value)
                            
                            self.pagePeople += 1
                        }
                        else if type == "Watersheds" {
                            self.trendingWatersheds = value["objects"] as! [AnyObject]
                            self.trendingWatershedsJSON = JSON(value)
                            
                            self.pageWatersheds += 1
                        }
                        else if type == "Groups" {
                            self.trendingGroups = value["objects"] as! [AnyObject]
                            self.trendingGroupsJSON = JSON(value)

                            self.pageGroups += 1
                        }
                        else if type == "Tags" {
                            self.trendingTags = value["objects"] as! [AnyObject]
                            self.trendingTagsJSON = JSON(value)

                            self.pageTags += 1
                        }
                        
                        self.refreshControl?.endRefreshing()
                    }
                    else {
//                        print("loadTrendingRecords::complete::!isRefreshingUserList \(value)")
                        
                        if type == "People" {
                            self.trendingPeople += value["objects"] as! [AnyObject]
                            self.trendingPeopleJSON = JSON(value)
                            
                            self.pagePeople += 1
                        }
                        else if type == "Watersheds" {
                            self.trendingWatersheds += value["objects"] as! [AnyObject]
                            self.trendingWatershedsJSON = JSON(value)

                            self.pageWatersheds += 1
                        }
                        else if type == "Groups" {
                            self.trendingGroups += value["objects"] as! [AnyObject]
                            self.trendingGroupsJSON = JSON(value)

                            self.pageGroups += 1
                        }
                        else if type == "Tags" {
                            self.trendingTags += value["objects"] as! [AnyObject]
                            self.trendingTagsJSON = JSON(value)
                            
                            self.pageTags += 1
                        }
                    }
                    
                    self.tableView.reloadData()
                    
                case .Failure(let error):
                    print(error)
                    break
                }
                
        }
    }
    
    func performSearch(endpoint: String, type: String, headers: [String: String], parameters: [String: String], isRefreshingUserList: Bool) {
        
        
        Alamofire.request(.GET, endpoint, headers: headers, parameters: parameters)
            .responseJSON { response in
                
                print("response \(response)")
                
                let statusCode = (response.response?.statusCode)!
                
                print("Status Code: \(statusCode == 400)  \("\(statusCode)" == "400")")
                
                if statusCode == 200 {
                    switch response.result {
                    case .Success(let value):
                        
                        self.isSearching = false
                        
                        let _tmpData = JSON(value)
                        
                        if (parameters["page"]! == "\(1)") {
                            //                        print("performSearch::complete::isRefreshingUserList \(value)")
                            
                            if type == "People" {
                                self.trendingPeople = value["features"] as! [AnyObject]
                                self.trendingPeopleJSON = JSON(value)
                                
                                if self.trendingPeople.count == 0 {
                                    self.isEmpty = true
                                }
                                
                                // Check if we should paginate
                                //
                                var _total_number_results = 0
                                
                                if self.trendingPeopleJSON["num_results"] != nil {
                                    _total_number_results = JSON(value)["num_results"].int!
                                }
                                else if JSON(value)["properties"]["num_results"] != nil {
                                    _total_number_results = JSON(value)["properties"]["num_results"].int!
                                }
                                
                                if self.pagePeople < _total_number_results {
                                    self.pagePeople += 1
                                }
                            }
                            else if type == "Watersheds" {
                                self.trendingWatersheds = value["objects"] as! [AnyObject]
                                self.trendingWatershedsJSON = JSON(value)
                                
                                // Check if we should paginate
                                //
                                var _total_number_results = 0
                                
                                if self.trendingWatershedsJSON["num_results"] != nil {
                                    _total_number_results = JSON(value)["num_results"].int!
                                }
                                else if JSON(value)["properties"]["num_results"] != nil {
                                    _total_number_results = JSON(value)["properties"]["num_results"].int!
                                }
                                
                                if self.pageWatersheds < _total_number_results {
                                    self.pageWatersheds += 1
                                }
                            }
                            else if type == "Groups" {
                                self.trendingGroups = value["features"] as! [AnyObject]
                                self.trendingGroupsJSON = JSON(value)
                                
                                // Check if we should paginate
                                //
                                var _total_number_results = 0
                                
                                if self.trendingGroupsJSON["num_results"] != nil {
                                    _total_number_results = JSON(value)["num_results"].int!
                                }
                                else if JSON(value)["properties"]["num_results"] != nil {
                                    _total_number_results = JSON(value)["properties"]["num_results"].int!
                                }
                                
                                if self.pageGroups < _total_number_results {
                                    self.pageGroups += 1
                                }
                            }
                            else if type == "Tags" {
                                self.trendingTags = value["features"] as! [AnyObject]
                                self.trendingTagsJSON = JSON(value)
                                
                                // Check if we should paginate
                                //
                                var _total_number_results = 0
                                
                                if self.trendingTagsJSON["num_results"] != nil {
                                    _total_number_results = JSON(value)["num_results"].int!
                                }
                                else if JSON(value)["properties"]["num_results"] != nil {
                                    _total_number_results = JSON(value)["properties"]["num_results"].int!
                                }
                                
                                if self.pageTags < _total_number_results {
                                    self.pageTags += 1
                                }
                            }
                            
                            self.refreshControl?.endRefreshing()
                        }
                        else if (_tmpData["features"] != nil && _tmpData["features"].count != 0) {
                            //                        print("performSearch::complete::!isRefreshingUserList \(value)")
                            
                            if type == "People" {
                                self.trendingPeople += value["features"] as! [AnyObject]
                                self.trendingPeopleJSON = JSON(value)
                                
                                if self.trendingPeople.count == 0 {
                                    self.isEmpty = true
                                }
                                
                                // Check if we should paginate
                                //
                                var _total_number_results = 0
                                
                                if self.trendingPeopleJSON["num_results"] != nil {
                                    _total_number_results = JSON(value)["num_results"].int!
                                }
                                else if JSON(value)["properties"]["num_results"] != nil {
                                    _total_number_results = JSON(value)["properties"]["num_results"].int!
                                }
                                
                                if self.pagePeople < _total_number_results {
                                    self.pagePeople += 1
                                }
                            }
                            else if type == "Watersheds" {
                                self.trendingWatersheds += value["features"] as! [AnyObject]
                                self.trendingWatershedsJSON = JSON(value)
                                
                                // Check if we should paginate
                                //
                                var _total_number_results = 0
                                
                                if self.trendingWatershedsJSON["num_results"] != nil {
                                    _total_number_results = JSON(value)["num_results"].int!
                                }
                                else if JSON(value)["properties"]["num_results"] != nil {
                                    _total_number_results = JSON(value)["properties"]["num_results"].int!
                                }
                                
                                if self.pageWatersheds < _total_number_results {
                                    self.pageWatersheds += 1
                                }
                            }
                            else if type == "Groups" {
                                self.trendingGroups += value["features"] as! [AnyObject]
                                self.trendingGroupsJSON = JSON(value)
                                
                                // Check if we should paginate
                                //
                                var _total_number_results = 0
                                
                                if self.trendingGroupsJSON["num_results"] != nil {
                                    _total_number_results = JSON(value)["num_results"].int!
                                }
                                else if JSON(value)["properties"]["num_results"] != nil {
                                    _total_number_results = JSON(value)["properties"]["num_results"].int!
                                }
                                
                                if self.pageGroups < _total_number_results {
                                    self.pageGroups += 1
                                }
                            }
                            else if type == "Tags" {
                                self.trendingTags += value["features"] as! [AnyObject]
                                self.trendingTagsJSON = JSON(value)
                                
                                // Check if we should paginate
                                //
                                var _total_number_results = 0
                                
                                if self.trendingTagsJSON["num_results"] != nil {
                                    _total_number_results = JSON(value)["num_results"].int!
                                }
                                else if JSON(value)["properties"]["num_results"] != nil {
                                    _total_number_results = JSON(value)["properties"]["num_results"].int!
                                }
                                
                                if self.pageTags < _total_number_results {
                                    self.pageTags += 1
                                }
                            }
                        }
                        
                        self.tableView.reloadData()
                        
                    case .Failure(let error):
                        print(error)
                        break
                    }
                }
                
        }

    }

    func searchForPeople(_isRefreshingUserList: Bool) {
        
        // Since we are executing an entirely new search we need to make sure
        // that we reset all of our result variables
        //
        if self.searchText == "" {
            return
        }
        
        //
        // Send a request to the defined endpoint with the given parameters
        //
        let accessToken = NSUserDefaults.standardUserDefaults().objectForKey("currentUserAccountAccessToken")
        let headers = [
            "Authorization": "Bearer " + (accessToken! as! String)
        ]
        
        let parameters = [
            "q": "{\"filters\": [{\"or\": [{\"name\":\"first_name\",\"op\":\"ilike\",\"val\":\"%" + self.searchText + "%\"}, {\"name\":\"last_name\",\"op\":\"ilike\",\"val\":\"%" + self.searchText + "%\"}]}]}",
            "page": "\(self.pagePeople)"
        ]
        
        let endpoint = Endpoints.GET_MANY_USER
        
        self.performSearch(endpoint, type: "People", headers: headers, parameters: parameters, isRefreshingUserList: _isRefreshingUserList)
        
    }

    func searchForWatersheds(isRefreshingUserList: Bool = true) {
        
        print("searchText", self.searchText)
        
        // Since we are executing an entirely new search we need to make sure
        // that we reset all of our result variables
        //
        if self.searchText == "" {
            return
        }
        
        //
        // Send a request to the defined endpoint with the given parameters
        //
        let accessToken = NSUserDefaults.standardUserDefaults().objectForKey("currentUserAccountAccessToken")
        let headers = [
            "Authorization": "Bearer " + (accessToken! as! String)
        ]
        
        let parameters = [
            "q": "{\"filters\": [{\"name\":\"huc_8_name\",\"op\":\"ilike\",\"val\":\"%" + self.searchText + "%\"}]}",
            "page": "\(self.pageWatersheds)"
        ]
        
        let endpoint = Endpoints.GET_MANY_HUC8WATERSHEDS
        
        self.performSearch(endpoint, type: "Watersheds", headers: headers, parameters: parameters, isRefreshingUserList: true)
        
    }

    func searchForGroups(isRefreshingUserList: Bool = true) {
        
        print("searchText", self.searchText)
        
        // Since we are executing an entirely new search we need to make sure
        // that we reset all of our result variables
        //
        if self.searchText == "" {
            return
        }
        
        //
        // Send a request to the defined endpoint with the given parameters
        //
        let accessToken = NSUserDefaults.standardUserDefaults().objectForKey("currentUserAccountAccessToken")
        let headers = [
            "Authorization": "Bearer " + (accessToken! as! String)
        ]
        
        let parameters = [
            "q": "{\"filters\": [{\"name\":\"name\",\"op\":\"ilike\",\"val\":\"%" + self.searchText + "%\"}]}",
            "page": "\(self.pageGroups)"
        ]
        
        let endpoint = Endpoints.GET_MANY_ORGANIZATIONS
        
        self.performSearch(endpoint, type: "Groups", headers: headers, parameters: parameters, isRefreshingUserList: true)
        
    }

    func searchForTags(isRefreshingUserList: Bool = true) {
        
        print("searchText", self.searchText)
        
        // Since we are executing an entirely new search we need to make sure
        // that we reset all of our result variables
        //
        if self.searchText == "" {
            return
        }
        
        //
        // Send a request to the defined endpoint with the given parameters
        //
        let accessToken = NSUserDefaults.standardUserDefaults().objectForKey("currentUserAccountAccessToken")
        let headers = [
            "Authorization": "Bearer " + (accessToken! as! String)
        ]
        
        let parameters = [
            "q": "{\"filters\": [{\"name\":\"tag\",\"op\":\"ilike\",\"val\":\"%" + self.searchText + "%\"}]}",
            "page": "\(self.pageTags)"
        ]
        
        let endpoint = Endpoints.GET_MANY_HASHTAGS
        
        self.performSearch(endpoint, type: "Tags", headers: headers, parameters: parameters, isRefreshingUserList: true)
        
    }

}
