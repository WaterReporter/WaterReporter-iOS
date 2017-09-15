//
//  NewReportLocationTableViewCell.swift
//  Water-Reporter
//
//  Created by Joshua Powell on 9/15/17.
//  Copyright © 2017 Viable Industries, L.L.C. All rights reserved.
//

import UIKit

class NewReportLocationTableViewCell: UITableViewCell {
    
    @IBOutlet weak var labelLocation: UILabel!
    @IBOutlet weak var imageLocationIcon: UIImageView!
    @IBOutlet weak var buttonChangeLocation: UIButton!
    
    //
    // MARK: Overrides
    //
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
}
