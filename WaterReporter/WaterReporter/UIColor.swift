//
//  UIColor.swift
//  WaterReporter
//
//  Created by Viable Industries on 7/25/16.
//  Copyright © 2016 Viable Industries, L.L.C. All rights reserved.
//

import Foundation
import UIKit

extension UIColor {
    
    class func colorBrand(alpha:CGFloat = 1.00) -> UIColor {
        return UIColor(red:0.10, green:0.67, blue:0.87, alpha: alpha)
    }
    
    class func colorDisabled(alpha:CGFloat = 1.00) -> UIColor {
        return UIColor(red:0.64, green:0.64, blue:0.64, alpha: alpha)
    }
    
}