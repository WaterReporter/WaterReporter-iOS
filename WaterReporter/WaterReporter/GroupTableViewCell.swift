//
//  GroupTableViewCell.swift
//  Water-Reporter
//
//  Created by Viable Industries on 11/11/16.
//  Copyright © 2016 Viable Industries, L.L.C. All rights reserved.
//

import UIKit

class GroupTableViewCell: UITableViewCell {
    
    var groupObject : AnyObject?
    
    @IBOutlet weak var imageViewGroupLogo: UIImageView!
    @IBOutlet weak var labelGroupName: UILabel!
    @IBOutlet weak var buttonJoinGroup: UIButton!
    @IBOutlet weak var buttonLeaveGroup: UIButton!
    
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
