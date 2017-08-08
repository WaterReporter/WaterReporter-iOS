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

class LikesTableViewController : UITableViewController {
    
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
        
        let _report = JSON(self.report)
        nextViewController.userId = "\(_report["likes"][sender.tag]["properties"]["owner_id"])"
        nextViewController.userObject = _report["likes"][sender.tag]
        
        self.navigationController?.pushViewController(nextViewController, animated: true)
        
    }

    
    //
    // MARK: Overrides
    //
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.likes = JSON(self.report)["properties"]["likes"]
        
        print("self.likes \(self.likes)")
        
        print("self.likes \(self.likes.count)")
        
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
        
        print("tableView::numberOfRowsInSection")
        
        var _count: Int = 0
        
        return _count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        print("tableView::cellForRowAtIndexPath")
//        
//        if indexPath.row > self.trendingTags.count {
//            return UITableViewCell()
//        }
//        
//        let result = self.trendingTags[indexPath.row].objectForKey("properties")
//        let resultJSON = JSON(result!)
//        
//        let cell = tableView.dequeueReusableCellWithIdentifier("LikeTableViewCell", forIndexPath: indexPath) as! LikeTableViewCell
        
        
        return UITableViewCell()

        
    }

}
