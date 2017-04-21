//
//  SearchTableViewCell.swift
//  Water-Reporter
//
//  Created by Joshua Powell on 4/11/17.
//  Copyright © 2017 Viable Industries, L.L.C. All rights reserved.
//

import UIKit

class SearchTableViewCell: UITableViewCell {
    
    var reportObject : AnyObject?
    
    @IBOutlet weak var searchResultImage: UIImageView!
    @IBOutlet weak var searchResultTitle: UILabel!
    @IBOutlet weak var searchResultSubTitle: UILabel!
    @IBOutlet weak var searchResultLink: UIButton!

    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        self.searchResultImage.image = nil
    }
    
    
    
}
