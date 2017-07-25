//
//  LikesTableViewController.swift
//  Water-Reporter
//
//  Created by Joshua Powell on 7/25/17.
//  Copyright © 2017 Viable Industries, L.L.C. All rights reserved.
//

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
    var comments: JSON?
    var page: Int = 1
    
    
    //
    // MARK: Overrides
    //
    override func viewDidLoad() {
        super.viewDidLoad()
    }

}
