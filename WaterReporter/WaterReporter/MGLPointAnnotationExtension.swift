//
//  MGLPointAnnotationExtension.swift
//  WaterReporter
//
//  Created by Viable Industries on 8/10/16.
//  Copyright © 2016 Viable Industries, L.L.C. All rights reserved.
//

import Foundation
import Mapbox

func associatedObject<ValueType: AnyObject>(
    base: AnyObject,
    key: UnsafePointer<UInt8>,
    initialiser: () -> ValueType)
    -> ValueType {
        if let associated = objc_getAssociatedObject(base, key)
            as? ValueType { return associated }
        let associated = initialiser()
        objc_setAssociatedObject(base, key, associated,
                                 .OBJC_ASSOCIATION_RETAIN)
        return associated
}
func associateObject<ValueType: AnyObject>(
    base: AnyObject,
    key: UnsafePointer<UInt8>,
    value: ValueType) {
    objc_setAssociatedObject(base, key, value,
                             .OBJC_ASSOCIATION_RETAIN)
}

private var reportIdKey: UInt8 = 0 // We still need this boilerplate

extension MGLAnnotation {
    
    var report: AnyObject { // cat is *effectively* a stored property
        get {
            return associatedObject(self, key: &reportIdKey)
            { return [:] } // Set the initial value of the var
        }
        set { associateObject(self, key: &reportIdKey, value: newValue) }
    }
    
}

//extension MGLPointAnnotation {
//    
//    var reportId: NSNumber { // cat is *effectively* a stored property
//        get {
//            return associatedObject(self, key: &reportIdKey)
//            { return 0 } // Set the initial value of the var
//        }
//        set { associateObject(self, key: &reportIdKey, value: newValue) }
//    }
//    
//}