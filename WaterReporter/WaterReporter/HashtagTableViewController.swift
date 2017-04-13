//
//  HashtagTableViewController.swift
//  Water-Reporter
//
//  Created by Joshua Powell on 4/12/17.
//  Copyright © 2017 Viable Industries, L.L.C. All rights reserved.
//

import UIKit

class HashtagTableViewController: UITableViewController {
    
    //
    // MARK: View-Global Variable
    //
    var hashtag: String = ""
    
    //
    // MARK: @IBOutlet
    //
    @IBOutlet weak var labelHashtagName: UILabel!
    
    
    //
    // MARK: @IBAction
    //
    
    
    //
    //
    //
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if hashtag != "" {
            self.labelHashtagName.text = self.hashtag
        }
    }
}
