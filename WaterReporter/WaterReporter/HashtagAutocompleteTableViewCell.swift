//
//  HashtagAutocompleteTableViewCell.swift
//  WaterReporter
//
//  Created by Viable Industries on 7/25/16.
//  Copyright © 2016 Viable Industries, L.L.C. All rights reserved.
//

import UIKit

class HashtagAutocompleteTableViewCell: UITableViewCell {
    
    
    //
    // MARK: @IBOutlets
    //
    @IBOutlet weak var labelHashtagValue: UILabel!
    
    
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
