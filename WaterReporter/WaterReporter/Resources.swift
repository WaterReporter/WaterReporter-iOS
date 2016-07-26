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
    
    func query(endpoint: String, parameters: [String: AnyObject]?) {

        //
        // Send a request to the defined endpoint with the given parameters
        //
        Alamofire.request(.GET, endpoint, parameters: parameters)
            .responseJSON { response in
                
                switch response.result {
                    
                    case .Success(let value):
                        self.returnValue(value as! NSDictionary)
                    
                    case .Failure(let error):
                        break
                }
                
        }
    }
    
    func returnValue(data: NSDictionary) -> NSDictionary {
        NSLog("%@", data)
        return data
    }
    
}

