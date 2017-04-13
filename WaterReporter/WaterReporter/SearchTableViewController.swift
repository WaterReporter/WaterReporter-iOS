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

class SearchTableViewController: UITableViewController, UISearchControllerDelegate, UISearchBarDelegate {

    //
    // MARK: @IBOutlets
    //
    @IBOutlet var searchTabNavigation: UIView!
    @IBOutlet weak var tableHeaderView: UIView!


    //
    // MARK: @IBActions
    //


    //
    // MARK: Global Variables
    //
    let searchController = UISearchController(searchResultsController: nil)
    var trending = [AnyObject]()
    var page: Int = 1
    var selectedType = "people"
    var allResultsLoaded: Bool = false
    
    
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
        self.loadTrendingUsers(false)

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
        // Additional action on cancel
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        print("searchBar::textDidChange \(searchText)")
        
        // Since we are executing an entirely new search we need to make sure
        // that we reset all of our result variables
        //
        self.allResultsLoaded = false
        self.page = 1
        self.trending = [AnyObject]()
        
        // With our result variables properly set, we can move on to actually
        // executing the search request.
        //
        self.searchForPeople(false, searchText: searchText);
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
            if (self.selectedType == "people") {
                
                
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
                var resultImageURL:NSURL! = NSURL(string: "https://www.waterreporter.org/images/badget--MissingUser.png")
                
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

            }
            
            //
            // CONTIUOUS SCROLL
            //
            if (indexPath.row == self.trending.count - 5) {
                self.loadTrendingUsers()
            }
            
        }
        
        return cell
    }

    
    
    //
    // MARK: Custom Methods
    //
    func loadTrendingUsers(isRefreshingUserList: Bool = false) {
        
        if self.allResultsLoaded {
            return
        }
        
        //
        // Send a request to the defined endpoint with the given parameters
        //
        let parameters = [
            "page": self.page
        ]
        
        Alamofire.request(.GET, Endpoints.TRENDING_PEOPLE_LOCAL, parameters: parameters)
            .responseJSON { response in
                
                switch response.result {
                case .Success(let value):
                    
                    let _total_pages = value["total_pages"] as! Int
                    
                    if (isRefreshingUserList) {
                        print("loadTrendingUsers::complete::isRefreshingUserList \(value)")
                        
                        self.trending = value["objects"] as! [AnyObject]
                        self.refreshControl?.endRefreshing()
                    }
                    else {
                        print("loadTrendingUsers::complete::!isRefreshingUserList \(value)")
                        
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

    func searchForPeople(isRefreshingUserList: Bool, searchText: String) {
        
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
            "q": "{\"filters\": [{\"or\": [{\"name\":\"first_name\",\"op\":\"ilike\",\"val\":\"%" + searchText + "%\"}, {\"name\":\"last_name\",\"op\":\"ilike\",\"val\":\"%" + searchText + "%\"}]}]}",
            "page": self.page
        ]
        
        Alamofire.request(.GET, Endpoints.GET_MANY_USER, headers: headers, parameters: parameters as! [String : AnyObject])
            .responseJSON { response in
                
                switch response.result {
                case .Success(let value):
                    
                    let _response = JSON(value)
                    
                    let _total_pages_string: String = "\(_response["properties"]["total_pages"])"
                    let _total_pages: Int? = Int(_total_pages_string)
                    
                    if (isRefreshingUserList) {
                        print("loadTrendingUsers::complete::isRefreshingUserList \(value)")
                        
                        self.trending = value["features"] as! [AnyObject]
                        self.refreshControl?.endRefreshing()
                    }
                    else {
                        print("loadTrendingUsers::complete::!isRefreshingUserList \(value)")
                        
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
    
}
