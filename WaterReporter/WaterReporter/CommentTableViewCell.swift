//
//  CommentTableViewCell.swift
//  Water-Reporter
//
//  Created by Viable Industries on 10/31/16.
//  Copyright © 2016 Viable Industries, L.L.C. All rights reserved.
//

import UIKit

class CommentTableViewCell: UITableViewCell {
    
    @IBOutlet weak var commentOwnerImageButton: UIButton!
    @IBOutlet weak var commentOwnerImage: UIImageView!
    @IBOutlet weak var commentOwnerName: UILabel!
    @IBOutlet weak var commentDatePosted: UILabel!
    @IBOutlet weak var commentDescriptionImage: UIImageView!
    @IBOutlet weak var commentDescription: UILabel!
    
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
