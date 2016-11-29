//
//  UserProfileCompleteViewController.swift
//  Water-Reporter
//
//  Created by Viable Industries on 11/28/16.
//  Copyright © 2016 Viable Industries, L.L.C. All rights reserved.
//

import Foundation
import UIKit

class UserProfileCompleteViewController: UIViewController {
    
    @IBAction func dismissCongratulationsMessage(sender: UIBarButtonItem) {
    
        let nextViewController = self.storyBoard.instantiateViewControllerWithIdentifier("PrimaryTabBarController") as! UITabBarController
        
        self.presentViewController(nextViewController, animated: false, completion: nil)

    }
    
    let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)

}
