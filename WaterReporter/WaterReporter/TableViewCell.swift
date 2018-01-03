//
//  TableViewCell.swift
//  WaterReporter
//
//  Created by Viable Industries on 7/25/16.
//  Copyright © 2016 Viable Industries, L.L.C. All rights reserved.
//

import ActiveLabel
import UIKit

class TableViewCell: UITableViewCell {

    var reportObject : AnyObject?

    @IBOutlet weak var reportUserName: UILabel!
    @IBOutlet weak var reportTerritoryName: UILabel!
    @IBOutlet weak var dropletIcon: UIImageView!
    @IBOutlet weak var reportTerritoryButton: UIButton!
    @IBOutlet weak var reportDescription: ActiveLabel!
    @IBOutlet weak var reportOwnerImage: UIImageView!
    @IBOutlet weak var reportOwnerImageButton: UIButton!
    @IBOutlet weak var reportImage: UIImageView!
    @IBOutlet weak var reportGroups: UILabel!
    
    //
    // Extra actions
    //
    
    @IBOutlet weak var extraActionsButton: UIButton!

    //
    // Groups
    //
    
    @IBOutlet weak var reportGroupStackLimiter: UIView!
    @IBOutlet weak var reportGroupStack: UIStackView!
    
    @IBOutlet weak var postGroupOne: UIView!
    @IBOutlet weak var postGroupTwo: UIView!
    @IBOutlet weak var postGroupThree: UIView!
    @IBOutlet weak var postGroupFour: UIView!
    @IBOutlet weak var postGroupFive: UIView!
    
    //
    
    @IBOutlet weak var reportGetDirectionsButton: UIButton!
    @IBOutlet weak var reportDate: UILabel!
    @IBOutlet weak var reportCommentCount: UIButton!
    @IBOutlet weak var reportCommentButton: UIButton!
    @IBOutlet weak var reportDirectionsButton: UIButton!
    @IBOutlet weak var reportShareButton: UIButton!
    @IBOutlet weak var reportLikeButton: UIButton!
    @IBOutlet weak var reportLikeCount: UIButton!
    
    //
    // Open Graph
    //
    
    @IBOutlet weak var reportOpenGraphStoryLink: UIButton!
    @IBOutlet weak var reportOpenGraphView: UIStackView!
    
    @IBOutlet weak var reportOpenGraphViewGroup: UIView!
    
    
//    @IBOutlet weak var reportOpenGraphViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var reportOpenGraphImage: UIImageView!
    @IBOutlet weak var reportOpenGraphTitle: UILabel!
    @IBOutlet weak var reportOpenGraphDescription: UILabel!
    
    
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
    
        self.reportOwnerImage.image = nil
        self.reportImage.image = nil
        self.reportCommentButton.imageView?.image = nil

    }



}
