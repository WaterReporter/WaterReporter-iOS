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

        let _object = JSON(self.trending[sender.tag])
        
        if (self.selectedType == "People") {
            let nextViewController = self.storyBoard.instantiateViewControllerWithIdentifier("ProfileTableViewController") as! ProfileTableViewController
            
            nextViewController.userId = "\(_object["id"])"
            nextViewController.userObject = _object
            self.navigationController!.pushViewController(nextViewController, animated: true)
        }
        else if (self.selectedType == "Watersheds") {
            let nextViewController = self.storyBoard.instantiateViewControllerWithIdentifier("TerritoryTableViewController") as! TerritoryTableViewController
            
            nextViewController.territory = "\(_object["properties"]["huc_8_name"])"
            nextViewController.territory_id = "\(_object["id"])"
            self.navigationController!.pushViewController(nextViewController, animated: true)
        }
        else if (self.selectedType == "Groups") {
            let nextViewController = self.storyBoard.instantiateViewControllerWithIdentifier("OrganizationTableViewController") as! OrganizationTableViewController
                        
            nextViewController.groupId = "\(_object["id"])"
            nextViewController.groupObject = _object
            nextViewController.groupProfile = _object
            
            self.navigationController!.pushViewController(nextViewController, animated: true)
        }
        else if (self.selectedType == "Tags") {
            let nextViewController = self.storyBoard.instantiateViewControllerWithIdentifier("HashtagTableViewController") as! HashtagTableViewController
            
            nextViewController.hashtag = "\(_object["properties"]["tag"])"

            self.navigationController!.pushViewController(nextViewController, animated: true)
        }

    }
    
    @IBAction func changeSearchType(sender: UIButton) {
        print("Change Tab to \(sender.currentTitle!)")
        
        // Cancel and clear search between tab switching
        //
        self.searchText = ""
        
        if self.selectedType != sender.currentTitle! {
            
            let _newType: String = sender.currentTitle!
            
            self.selectedType = _newType
            
            // Now that we have a new type selected, we need to
            // change the data in the table and change the color
            // of the selected item
            self.buttonPeople.setTitleColor(UIColor.grayColor(), forState: .Normal)
            self.buttonWatersheds.setTitleColor(UIColor.grayColor(), forState: .Normal)
            self.buttonGroups.setTitleColor(UIColor.grayColor(), forState: .Normal)
            self.buttonTags.setTitleColor(UIColor.grayColor(), forState: .Normal)
            
            self.allResultsLoaded = false
            self.page = 1
            self.trending = [AnyObject]()
            self.searchText = ""
            self.timer = NSTimer()
            self.tableView.reloadData()

            if (_newType == "People") {
                self.buttonPeople.setTitleColor(UIColor.colorBrand(), forState: .Normal)

                // Load in trending users as the default
                //
                self.loadTrendingRecords(Endpoints.TRENDING_PEOPLE, isRefreshingUserList: false)
            }
            else if (_newType == "Watersheds") {
                self.buttonWatersheds.setTitleColor(UIColor.colorBrand(), forState: .Normal)

                // Load in trending users as the default
                //
                self.loadTrendingRecords(Endpoints.TRENDING_TERRITORY, isRefreshingUserList: false)
            }
            else if (_newType == "Groups") {
                self.buttonGroups.setTitleColor(UIColor.colorBrand(), forState: .Normal)

                // Load in trending users as the default
                //
                self.loadTrendingRecords(Endpoints.TRENDING_GROUP, isRefreshingUserList: false)
            }
            else if (_newType == "Tags") {
                self.buttonTags.setTitleColor(UIColor.colorBrand(), forState: .Normal)

                // Load in trending users as the default
                //
                self.loadTrendingRecords(Endpoints.TRENDING_HASHTAG, isRefreshingUserList: false)
            }
            
        }
        
    }
    


    //
    // MARK: Global Variables
    //
    let searchController = UISearchController(searchResultsController: nil)
    var trending = [AnyObject]()
    var page: Int = 1
    var selectedType = "People"
    var allResultsLoaded: Bool = false
    let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
    var timer = NSTimer()
    var searchText: String = ""

    
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
        self.loadTrendingRecords(Endpoints.TRENDING_PEOPLE, isRefreshingUserList: false)

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
        self.allResultsLoaded = false
        self.page = 1
        self.trending = [AnyObject]()
        self.searchText = ""
        self.timer = NSTimer()

        // Load in trending users as the default
        //

        if (self.selectedType == "People") {
            // Load in trending users as the default
            //
            self.loadTrendingRecords(Endpoints.TRENDING_PEOPLE, isRefreshingUserList: false)
        }
        else if (self.selectedType == "Watersheds") {
            // Load in trending users as the default
            //
            self.loadTrendingRecords(Endpoints.TRENDING_TERRITORY, isRefreshingUserList: false)
        }
        else if (self.selectedType == "Groups") {
            // Load in trending users as the default
            //
            self.loadTrendingRecords(Endpoints.TRENDING_GROUP, isRefreshingUserList: false)
        }
        else if (self.selectedType == "Tags") {
            // Load in trending users as the default
            //
            self.loadTrendingRecords(Endpoints.TRENDING_HASHTAG, isRefreshingUserList: false)
        }
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        print("searchBar::textDidChange \(searchText)")
        
        // Everytime the text changes, updated the `searchText` and restart the
        // timerh
        //
        self.searchText = searchText;

        if (self.selectedType == "People") {
            // Load in trending users as the default
            //
            self.timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(SearchTableViewController.searchForPeople(_:)), userInfo: nil, repeats: false)
        }
        else if (self.selectedType == "Watersheds") {
            // Load in trending users as the default
            //
            self.timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(SearchTableViewController.searchForWatersheds(_:)), userInfo: nil, repeats: false)
        }
        else if (self.selectedType == "Groups") {
            // Load in trending users as the default
            //
            self.timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(SearchTableViewController.searchForGroups(_:)), userInfo: nil, repeats: false)
        }
        else if (self.selectedType == "Tags") {
            // Load in trending users as the default
            //
            self.timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(SearchTableViewController.searchForTags(_:)), userInfo: nil, repeats: false)
        }

        
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
        return self.trending.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("searchTableViewCell", forIndexPath: indexPath) as! SearchTableViewCell
        
        //
        // Make sure we aren't loading old images into the new cells as
        // additional reports are loaded
        //
        if (self.trending.count >= 1) {
            
            let result = self.trending[indexPath.row].objectForKey("properties")
            let resultJSON = JSON(result!)

            
            //
            // PEOPLE
            //
            if (self.selectedType == "People") {
                
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
    
                cell.searchResultImage.kf_setImageWithURL(resultImageURL, placeholderImage: nil, optionsInfo: nil, progressBlock: nil, completionHandler: {
                    (image, error, cacheType, imageUrl) in
                    if (image != nil) {
                        cell.searchResultImage.image = UIImage(CGImage: (image?.CGImage)!, scale: (image?.scale)!, orientation: UIImageOrientation.Up)
                    }

                    cell.searchResultImage.layer.cornerRadius = cell.searchResultImage.frame.size.width / 2
                    cell.searchResultImage.clipsToBounds = true

                })
                
                // PEOPLE > BUTTON
                //
                cell.searchResultLink.tag = indexPath.row

            }
            else if (self.selectedType == "Watersheds") {
                
                print("resultJSON>>WATERSHEDS \(resultJSON)")
                
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
                let resultImageURL:NSURL! = NSURL(string: "https://huc.waterreporter.org/boundary.png")
                
                cell.searchResultImage.backgroundColor = UIColor.colorBackground()
                
                cell.searchResultImage.kf_indicatorType = .Activity
                cell.searchResultImage.kf_showIndicatorWhenLoading = true
                
                cell.searchResultImage.kf_setImageWithURL(resultImageURL, placeholderImage: nil, optionsInfo: nil, progressBlock: nil, completionHandler: {
                    (image, error, cacheType, imageUrl) in
                    if (image != nil) {
                        cell.searchResultImage.image = UIImage(CGImage: (image?.CGImage)!, scale: (image?.scale)!, orientation: UIImageOrientation.Up)
                    }
                    
                    cell.searchResultImage.layer.cornerRadius = cell.searchResultImage.frame.size.width / 2
                    cell.searchResultImage.clipsToBounds = true
                    
                })
                
                // WATERSHED > BUTTON
                //
                cell.searchResultLink.tag = indexPath.row
            }
            else if (self.selectedType == "Groups") {
                
                print("resultJSON>>GROUPS \(resultJSON)")
                
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
                
                cell.searchResultImage.kf_setImageWithURL(resultImageURL, placeholderImage: nil, optionsInfo: nil, progressBlock: nil, completionHandler: {
                    (image, error, cacheType, imageUrl) in
                    if (image != nil) {
                        cell.searchResultImage.image = UIImage(CGImage: (image?.CGImage)!, scale: (image?.scale)!, orientation: UIImageOrientation.Up)
                    }
                    
                    cell.searchResultImage.layer.cornerRadius = cell.searchResultImage.frame.size.width / 2
                    cell.searchResultImage.clipsToBounds = true
                    
                })
                
                // GROUP > BUTTON
                //
                cell.searchResultLink.tag = indexPath.row
            }
            else if (self.selectedType == "Tags") {
                
                print("resultJSON>>TAGS \(resultJSON)")
                
                //
                // TAG > TITLE
                //
                let _name = "\(resultJSON["tag"])"
                
                cell.searchResultTitle.backgroundColor = UIColor.clearColor()
                
                if (_name != "") {
                    cell.searchResultTitle.text = "\(_name)"
                }
                else {
                    cell.searchResultTitle.text = "Unknown Group Name"
                }
                
                //
                // TAG > IMAGE
                //
                cell.searchResultImage.image = UIImage(named: "icon--hashtag")

                
                // TAG > BUTTON
                //
                cell.searchResultLink.tag = indexPath.row
            }
            
            //
            // CONTIUOUS SCROLL
            //
            if (indexPath.row == self.trending.count - 5) {
                
                if (self.searchText == "") {
                    // Only do this if there is no search happening
                    //
                    if self.selectedType == "People" {
                        self.loadTrendingRecords(Endpoints.TRENDING_PEOPLE)
                    }
                    else if self.selectedType == "Watersheds" {
                        self.loadTrendingRecords(Endpoints.TRENDING_TERRITORY)
                    }
                    else if self.selectedType == "Groups" {
                        self.loadTrendingRecords(Endpoints.TRENDING_GROUP)
                    }
                    else if self.selectedType == "Tags" {
                        self.loadTrendingRecords(Endpoints.TRENDING_HASHTAG)
                    }
                }
                else {
                    // @todo PAGINATION FOR SEARCH!!!!!! 
                    //
                }
            }
            
        }
        
        return cell
    }

    
    
    //
    // MARK: Custom Methods
    //
    func loadTrendingRecords(endpoint: String, isRefreshingUserList: Bool = false) {
        
        if self.allResultsLoaded {
            return
        }
        
        //
        // Send a request to the defined endpoint with the given parameters
        //
        let parameters = [
            "page": self.page
        ]
        
        Alamofire.request(.GET, endpoint, parameters: parameters)
            .responseJSON { response in
                
                switch response.result {
                case .Success(let value):
                    
                    let _total_pages = value["total_pages"] as! Int
                    
                    if (isRefreshingUserList) {
                        print("loadTrendingRecords::complete::isRefreshingUserList \(value)")
                        
                        self.trending = value["objects"] as! [AnyObject]
                        self.refreshControl?.endRefreshing()
                    }
                    else {
                        print("loadTrendingRecords::complete::!isRefreshingUserList \(value)")
                        
                        self.trending += value["objects"] as! [AnyObject]
                    }
                    
                    if self.page < _total_pages {
                        self.page += 1
                    }
                    else {
                        self.allResultsLoaded = true
                    }
                    
                    self.tableView.reloadData()
                    
                case .Failure(let error):
                    print(error)
                    break
                }
                
        }
    }
    
    func performSearch(endpoint: String, headers: [String: String], parameters: [String: String], isRefreshingUserList: Bool = false) {
        Alamofire.request(.GET, endpoint, headers: headers, parameters: parameters)
            .responseJSON { response in
                
                switch response.result {
                case .Success(let value):
                    
                    let _response = JSON(value)
                    
                    let _total_pages_string: String = "\(_response["properties"]["total_pages"])"
                    let _total_pages: Int? = Int(_total_pages_string)
                    
                    if (isRefreshingUserList) {
                        print("loadTrendingRecords::complete::isRefreshingUserList \(value)")
                        
                        self.trending = value["features"] as! [AnyObject]
                        self.refreshControl?.endRefreshing()
                    }
                    else {
                        print("loadTrendingRecords::complete::!isRefreshingUserList \(value)")
                        self.trending += value["features"] as! [AnyObject]
                    }
                    
                    if self.page < _total_pages {
                        self.page += 1
                    }
                    else {
                        self.allResultsLoaded = true
                    }
                    
                    self.tableView.reloadData()
                    
                case .Failure(let error):
                    print(error)
                    break
                }
                
        }

    }

    func searchForPeople(isRefreshingUserList: Bool = false) {
        
        print("searchText", self.searchText)
        
        // Since we are executing an entirely new search we need to make sure
        // that we reset all of our result variables
        //
        self.allResultsLoaded = false
        self.page = 1
        self.trending = [AnyObject]()
        
        
        if self.allResultsLoaded {
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
            "page": "\(self.page)"
        ]
        
        let endpoint = Endpoints.GET_MANY_USER
        
        self.performSearch(endpoint, headers: headers, parameters: parameters, isRefreshingUserList: isRefreshingUserList)
        
    }

    func searchForWatersheds(isRefreshingUserList: Bool = false) {
        
        print("searchText", self.searchText)
        
        // Since we are executing an entirely new search we need to make sure
        // that we reset all of our result variables
        //
        self.allResultsLoaded = false
        self.page = 1
        self.trending = [AnyObject]()
        
        
        if self.allResultsLoaded {
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
            "page": "\(self.page)"
        ]
        
        let endpoint = Endpoints.GET_MANY_TERRITORY
        
        self.performSearch(endpoint, headers: headers, parameters: parameters, isRefreshingUserList: isRefreshingUserList)
        
    }

    func searchForGroups(isRefreshingUserList: Bool = false) {
        
        print("searchText", self.searchText)
        
        // Since we are executing an entirely new search we need to make sure
        // that we reset all of our result variables
        //
        self.allResultsLoaded = false
        self.page = 1
        self.trending = [AnyObject]()
        
        
        if self.allResultsLoaded {
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
            "page": "\(self.page)"
        ]
        
        let endpoint = Endpoints.GET_MANY_ORGANIZATIONS
        
        self.performSearch(endpoint, headers: headers, parameters: parameters, isRefreshingUserList: isRefreshingUserList)
        
    }

    func searchForTags(isRefreshingUserList: Bool = false) {
        
        print("searchText", self.searchText)
        
        // Since we are executing an entirely new search we need to make sure
        // that we reset all of our result variables
        //
        self.allResultsLoaded = false
        self.page = 1
        self.trending = [AnyObject]()
        
        
        if self.allResultsLoaded {
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
            "page": "\(self.page)"
        ]
        
        let endpoint = Endpoints.GET_MANY_HASHTAGS
        
        self.performSearch(endpoint, headers: headers, parameters: parameters, isRefreshingUserList: isRefreshingUserList)
        
    }

}
