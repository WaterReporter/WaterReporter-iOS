//
//  NewReportContentTableViewCell.swift
//  Water-Reporter
//
//  Created by Joshua Powell on 9/15/17.
//  Copyright © 2017 Viable Industries, L.L.C. All rights reserved.
//

import UIKit

class NewPostContentTableViewCell: UITableViewCell, UITextViewDelegate {
    
    
    //
    // MARK: IBOutlets
    //
    @IBOutlet weak var buttonReportImage: UIButton!
    @IBOutlet weak var textViewReportDescription: UITextView!

    
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
