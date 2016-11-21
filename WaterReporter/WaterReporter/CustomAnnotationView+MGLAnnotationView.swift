//
//  Rename.swift
//  Water-Reporter
//
//  Created by Viable Industries on 11/21/16.
//  Copyright © 2016 Viable Industries, L.L.C. All rights reserved.
//

import Foundation
import Mapbox

class CustomAnnotationView: MGLAnnotationView {
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // Force the annotation view to maintain a constant size when the map is tilted.
//        scalesWithViewingDistance = false
        
        // Use CALayer’s corner radius to turn this view into a circle.
//        layer.cornerRadius = frame.width / 2
//        layer.borderWidth = 4
//        layer.borderColor = UIColor.whiteColor().CGColor
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Animate the border width in/out, creating an iris effect.
//        let animation = CABasicAnimation(keyPath: "borderWidth")
//        animation.duration = 0.1
//        layer.borderWidth = selected ? frame.width / 4 : 2
//        layer.addAnimation(animation, forKey: "borderWidth")
    }
    
}
