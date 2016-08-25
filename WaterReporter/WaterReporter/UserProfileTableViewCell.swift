//
//  UserProfileTableViewCell.swift
//  Water-Reporter
//
//  Created by Viable Industries on 8/22/16.
//  Copyright © 2016 Viable Industries, L.L.C. All rights reserved.
//

import UIKit

class UserProfileTableViewCell: UITableViewCell {
    
    var reportObject : AnyObject?
        
    @IBOutlet weak var userReportImage: UIImageView!
    
    @IBOutlet weak var userReportDescription: UILabel!
    @IBOutlet weak var userReportGroups: UILabel!
    @IBOutlet weak var userReportOwnerImage: UIImageView!
    @IBOutlet weak var userReportOwnerName: UILabel!
    @IBOutlet weak var userReportTerritoryName: UILabel!
    @IBOutlet weak var userReportDate: UILabel!
    @IBOutlet weak var userReportButtonMap: UIButton!
    @IBOutlet weak var userReportButtonComments: UIButton!
    @IBOutlet weak var userReportCommentsCount: UIButton!
    @IBOutlet weak var userReportButtonDirections: UIButton!
    @IBOutlet weak var userReportButtonProfile: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    
}
