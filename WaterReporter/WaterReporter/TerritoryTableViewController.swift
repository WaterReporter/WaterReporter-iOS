//
//  TerritoryTableViewController.swift
//  Water-Reporter
//
//  Created by Joshua Powell on 4/12/17.
//  Copyright © 2017 Viable Industries, L.L.C. All rights reserved.
//

import UIKit

class TerritoryTableViewController: UITableViewController {
    
    //
    // MARK: View-Global Variable
    //
    var territory: String = ""
    var territory_id: String = ""
    
    //
    // MARK: @IBOutlet
    //
    @IBOutlet weak var labelTerritoryName: UILabel!
    
    
    //
    // MARK: @IBAction
    //
    
    
    //
    //
    //
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if self.territory != "" {
            self.labelTerritoryName.text = "\(self.territory)"
        }
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        
        self.navigationController?.navigationBarHidden = false
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(true)
                
        if self.isMovingFromParentViewController()
        {
            self.navigationController?.navigationBarHidden = true
        }
        else
        {
            self.navigationController?.navigationBarHidden = false
        }
        
    }

}
