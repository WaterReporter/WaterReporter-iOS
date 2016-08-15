//
//  TableViewCell.swift
//  WaterReporter
//
//  Created by Viable Industries on 7/25/16.
//  Copyright © 2016 Viable Industries, L.L.C. All rights reserved.
//

import UIKit

class TableViewCell: UITableViewCell {

    var reportObject : AnyObject?

    @IBOutlet weak var reportUserName: UILabel!
    @IBOutlet weak var reportTerritoryName: UILabel!
    @IBOutlet weak var reportDescription: UILabel!
    @IBOutlet weak var reportOwnerImage: UIImageView!
    @IBOutlet weak var reportImage: UIImageView!
    @IBOutlet weak var reportCommentIcon: UIImageView!
    @IBOutlet weak var reportMapIcon: UIImageView!
    @IBOutlet weak var reportGroups: UILabel!
    @IBOutlet weak var reportGetDirectionsButton: UIButton!
    @IBOutlet weak var reportDate: UILabel!
    @IBOutlet weak var reportCommentCount: UIButton!
    @IBOutlet weak var reportDirectionsButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }


}
