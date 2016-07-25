//
//  ActivityViewController.swift
//  WaterReporter
//
//  Created by Viable Industries on 7/24/16.
//  Copyright © 2016 Viable Industries, L.L.C. All rights reserved.
//

import UIKit

class ActivityViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        NSLog("ActivityViewController::viewDidLoad")
        
        //
        // Set the Navigation Bar title
        //
        self.navigationItem.title = "Activity"
    }

    
    override func viewWillAppear(animated: Bool) {
        
        NSLog("ActivityViewController::viewWillAppear")

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

