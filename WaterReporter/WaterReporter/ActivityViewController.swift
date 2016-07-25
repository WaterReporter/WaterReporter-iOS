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
        
        self.title = "Activity"
        
        self.navigationItem.title = "Activity snt"

        // Do any additional setup after loading the view, typically from a nib.
        
        NSLog("ActivityViewController::viewDidLoad")

        
        self.tabBarController!.title = "Activity tbct"
    }

    
    override func viewWillAppear(animated: Bool) {
        
        NSLog("ActivityViewController::viewWillAppear")

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

