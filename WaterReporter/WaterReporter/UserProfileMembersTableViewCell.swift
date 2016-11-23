//
//  UserProfileMembersTableViewCell.swift
//  Water-Reporter
//
//  Created by Viable Industries on 11/23/16.
//  Copyright © 2016 Viable Industries, L.L.C. All rights reserved.
//

import UIKit

class UserProfileMembersTableViewCell: UITableViewCell {
    
    @IBOutlet weak var imageViewGroupMemberProfileImage: UIImageView!
    @IBOutlet weak var labelGroupMemberName: UILabel!
    @IBOutlet weak var buttonMemberSelection: UIButton!
    
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
