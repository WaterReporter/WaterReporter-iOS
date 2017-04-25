//
//  CommentTableViewCell.swift
//  Water-Reporter
//
//  Created by Viable Industries on 10/31/16.
//  Copyright © 2016 Viable Industries, L.L.C. All rights reserved.
//

import ActiveLabel
import UIKit

class CommentTableViewCell: UITableViewCell {
    
    
    //
    // MARK: @IBOutlets
    //
    @IBOutlet weak var commentOwnerImageButton: UIButton!
    @IBOutlet weak var commentOwnerImage: UIImageView!
    @IBOutlet weak var commentOwnerName: UILabel!
    @IBOutlet weak var commentDatePosted: UILabel!
    @IBOutlet weak var commentDescriptionImage: UIImageView!
    @IBOutlet weak var commentDescription: ActiveLabel!
    @IBOutlet weak var commentDescriptionImageHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var commentDescriptionImageTopMarginConstraint: NSLayoutConstraint!
    @IBOutlet weak var commentDescriptionImageBottomMarginConstraint: NSLayoutConstraint!
    
    
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
