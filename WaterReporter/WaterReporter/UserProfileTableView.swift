//
//  UserProfileTableView.swift
//  Water-Reporter
//
//  Created by Viable Industries on 8/22/16.
//  Copyright © 2016 Viable Industries, L.L.C. All rights reserved.
//

import Alamofire
import Foundation
import UIKit

class UserProfileTableView: UITableView {
    
    var reports = [AnyObject]()
    var singleReport: Bool = false
    var page: Int = 1
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code

        if (!singleReport) {
            self.loadSubmissions()
        }

    }
    
    func loadSubmissions() {
        
        print("loadSubmissions")
        
        //
        // Send a request to the defined endpoint with the given parameters
        //
        let parameters = [
            "q": "{\"filters\": [{\"name\":\"owner_id\", \"op\":\"eq\", \"val\":274}], \"order_by\": [{\"field\":\"report_date\",\"direction\":\"desc\"},{\"field\":\"id\",\"direction\":\"desc\"}]}",
            "page": self.page
        ]
        
        Alamofire.request(.GET, Endpoints.GET_MANY_REPORTS, parameters: parameters as? [String : AnyObject])
            .responseJSON { response in
                
                switch response.result {
                case .Success(let value):
                    self.reports += value["features"] as! [AnyObject]
                    self.reloadData()
                    
                    print(value["features"])
                    self.page += 1
                    
                case .Failure(let error):
                    print(error)
                    break
                }
                
        }
    }
    
}
