//
//  NewPostTableViewController.swift
//  Water-Reporter
//
//  Created by Joshua Powell on 9/26/17.
//  Copyright © 2017 Viable Industries, L.L.C. All rights reserved.
//

import Foundation
import UIKit

class NewPostTableViewController: UITableViewController {
    
    
    //
    // MARK: Variables
    //
    
    
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
    

}
