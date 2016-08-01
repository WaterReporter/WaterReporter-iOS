//
//  TableViewCell.swift
//  WaterReporter
//
//  Created by Viable Industries on 7/25/16.
//  Copyright © 2016 Viable Industries, L.L.C. All rights reserved.
//

import UIKit

class TableViewCell: UITableViewCell {

    @IBOutlet weak var reportUserName: UILabel!
    @IBOutlet weak var reportTerritoryName: UILabel!
    @IBOutlet weak var reportDescription: UILabel!
    @IBOutlet weak var reportOwnerImage: UIImageView!
    @IBOutlet weak var reportImage: UIImageView!
    @IBOutlet weak var reportCommentCount: UILabel!
    @IBOutlet weak var reportCommentIcon: UIImageView!
    @IBOutlet weak var reportMapIcon: UIImageView!
    @IBOutlet weak var reportGroups: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
