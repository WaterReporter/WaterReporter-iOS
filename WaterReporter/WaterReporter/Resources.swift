//
//  Resources.swift
//  WaterReporter
//
//  Created by Viable Industries on 7/25/16.
//  Copyright © 2016 Viable Industries, L.L.C. All rights reserved.
//

import Alamofire
import Foundation

class Resource {
    
    func query(endpoint: String, parameters: [String: AnyObject]) {

        //
        // Send a request to the defined endpoint with the given parameters
        //
        Alamofire.request(.GET, endpoint, parameters: parameters)
            .responseJSON { response in
                
                if let JSON = response.result.value {
                    print("JSON: \(JSON)")
                }
                
        }
    }
    
    
}

