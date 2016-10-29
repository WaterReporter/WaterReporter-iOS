//
//  CommentsTableViewController.swift
//  Water-Reporter
//
//  Created by Viable Industries on 10/29/16.
//  Copyright © 2016 Viable Industries, L.L.C. All rights reserved.
//

import Alamofire
import Foundation
import UIKit

class CommentsTableViewController: UITableViewController {
    
    @IBOutlet weak var navigationBarButtonActivity: UIBarButtonItem!
    @IBOutlet weak var navigationBarButtonAddComment: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationBarButtonActivity.target = self
        navigationBarButtonActivity.action = #selector(CommentsTableViewController.dismissCommentsList(_:))
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    //
    // MARK: Custom Functionaity
    //
    func dismissCommentsList(sender: AnyObject) {
        print("dismissCommentsList")
        dismissViewControllerAnimated(true, completion: nil)
    }
}
