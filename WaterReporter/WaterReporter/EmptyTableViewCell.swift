//
//  EmptyTableViewCell.swift
//  Water-Reporter
//
//  Created by Joshua Powell on 9/6/17.
//  Copyright © 2017 Viable Industries, L.L.C. All rights reserved.
//

import UIKit

class EmptyTableViewCell: UITableViewCell {
    
    
    //
    // MARK: @IBOutlets
    //
    @IBOutlet weak var emptyMessageAction: UIButton!
    @IBOutlet weak var emptyMessageIcon: UIImageView!
    @IBOutlet weak var emptyMessageDescription: UILabel!
    
    
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
