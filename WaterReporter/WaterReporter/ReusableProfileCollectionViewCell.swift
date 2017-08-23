//
//  ReusableProfileCollectionViewCell.swift
//  Water-Reporter
//
//  Created by Joshua Powell on 8/23/17.
//  Copyright © 2017 Viable Industries, L.L.C. All rights reserved.
//

import UIKit

class ReusableProfileCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var reportUserProfileImage: UIImageView!
    @IBOutlet weak var reportUserProfileName: UILabel!
    @IBOutlet weak var reportImage: UIImageView!
    @IBOutlet weak var reportDescription: UILabel!
    @IBOutlet weak var reportLink: UIButton!
    @IBOutlet weak var reportDate: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
}
