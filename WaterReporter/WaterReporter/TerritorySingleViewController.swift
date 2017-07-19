//
//  TerritorySingleViewController.swift
//  Water-Reporter
//
//  Created by Joshua Powell on 7/11/17.
//  Copyright © 2017 Viable Industries, L.L.C. All rights reserved.
//

import Alamofire
import Dispatch
import Foundation
import Mapbox
import SwiftyJSON
import UIKit

class TerritorySingleViewController: UIViewController, MGLMapViewDelegate {
    
    
    //
    // MARK: View-Global Variable
    //
    let mapTesting: Bool = false
    let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
    
    var territory: String = ""
    var territoryId: String = ""
    var territoryHUC8Code: String = ""
    var territoryPage: Int = 1
    
    var territorySelectedContentType: String! = "Posts"

    
    //
    //
    //
    @IBOutlet weak var mapViewWatershed: MGLMapView!

    
    //
    // MARK: Overrides
    //
    override func viewDidLoad() {
        super.viewDidLoad()

        // Display the Territory (Watershed) name
        //
        if self.territory != "" {
            
            print("Territory Name Available, update the self.labelTerritoryName.text label and the self.navigationItem.title with \(self.territory)")
            
            self.navigationItem.title = "\(self.territory)"
        }
        
        // Display the Territory's (Watershed) related geographic ID (HUC 8
        // Code)
        //
        if self.territoryHUC8Code != "" {
            
            print("Territory Geographic ID Available, update the self.navigationItem.prompt label with \(self.territoryHUC8Code)")
            
            self.navigationItem.prompt = "\(self.territoryHUC8Code)"
        }
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
    }

}
