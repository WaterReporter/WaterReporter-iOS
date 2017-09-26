//
//  NewPostTableViewController.swift
//  Water-Reporter
//
//  Created by Joshua Powell on 9/26/17.
//  Copyright © 2017 Viable Industries, L.L.C. All rights reserved.
//

import Foundation
import SwiftyJSON
import UIKit

class NewPostTableViewController: UITableViewController {
    
    
    //
    // MARK: Variables
    //
    var groups: JSON?
    var hashtags: JSON?

    
    
    //
    // MARK: IBOutlets
    //
    
    
    //
    // MARK: IBActions
    //
    
    
    //
    // MARK: Overrides
    //
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    //
    // MARK: Table Overrides
    //
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 5
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {

        var _headerTitle = ""
        
        switch section {
            case 4:
                _headerTitle = "Share with your groups"
                break
            default:
                _headerTitle = "" // No change
                break
        }
        
        return _headerTitle
    }
    
    override func tableView(tableView:UITableView, numberOfRowsInSection section: Int) -> Int {
        
        var numberOfRows: Int = 1
        
        switch section {
            case 1:
                if self.hashtags != nil {
                    
                    let _numberOfAvailableFeatures: Int = (self.hashtags?["features"].count)!
                    numberOfRows = (_numberOfAvailableFeatures)
                }
                break
            case 4:
                if self.groups != nil {
                    
                    let _numberOfAvailableFeatures: Int = (self.groups?["features"].count)!
                    
                    numberOfRows = (_numberOfAvailableFeatures)
                    
                }
                break;
            default:
                numberOfRows = 1
                break;
        }
        
        return numberOfRows
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        if indexPath.section == 0 && indexPath.row == 0 {
            return 136.0
        }
        
        return 44.0
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let _section: Int = indexPath.section
        let _row: Int = indexPath.row
        
        if _section == 0 && _row == 0 {
            
            let _cell = tableView.dequeueReusableCellWithIdentifier("newPostContentTableViewCell", forIndexPath: indexPath)

            return _cell
        }
        
        //
        // TEMPORARY
        //
        return UITableViewCell()
    }
    

}
