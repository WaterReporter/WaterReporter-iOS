//
//  ActivityMapViewController.swift
//  WaterReporter
//
//  Created by Viable Industries on 8/1/16.
//  Copyright © 2016 Viable Industries, L.L.C. All rights reserved.
//

import Foundation
import UIKit

class ActivityMapViewController: UIViewController {
    
    var toPass:AnyObject!
    
    @IBOutlet weak var coordinates: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //
        // Set the "Get Directions" Bar Button
        //
        let rightBarButton = UIBarButtonItem(title: "Get Directions", style: UIBarButtonItemStyle.Plain, target: self, action:#selector(openDirectionsURL(_:)))
        
        self.navigationItem.rightBarButtonItem = rightBarButton
        
        print("ActivityMapViewController.toPass received")
        print(toPass)
        
        coordinates.text = "something"
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func openDirectionsURL(sender: UIBarButtonItem) {
        UIApplication.sharedApplication().openURL(NSURL(string: "https://www.google.com/maps/dir//31.8424200949044,-85.7692766189575")!)
    }
}
