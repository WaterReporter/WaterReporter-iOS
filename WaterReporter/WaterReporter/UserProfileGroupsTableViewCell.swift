//
//  UserProfileGroupsTableViewCell.swift
//  Profle Test 001
//
//  Created by Viable Industries on 11/14/16.
//  Copyright © 2016 Viable Industries, L.L.C. All rights reserved.
//

import UIKit

class UserProfileGroupsTableViewCell: UITableViewCell {
    
    @IBOutlet weak var imageViewUserProfileGroup: UIImageView!
    @IBOutlet weak var labelUserProfileGroupName: UILabel!
    @IBOutlet weak var buttonGroupSelection: UIButton!
    
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
