//
//  VI+URL.swift
//  Water-Reporter
//
//  Created by Joshua Powell on 9/26/17.
//  Copyright © 2017 Viable Industries, L.L.C. All rights reserved.
//

import Foundation
import UIKit

struct Utilities {

    func verifyUrl (urlString: String?) -> Bool {
        //Check for nil
        if let urlString = urlString {
            // create NSURL instance
            if let url = NSURL(string: urlString) {
                // check if your application can open the NSURL instance
                return UIApplication.sharedApplication().canOpenURL(url)
            }
        }
        return false
    }

}
