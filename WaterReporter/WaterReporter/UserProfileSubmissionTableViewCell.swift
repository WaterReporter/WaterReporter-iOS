//
//  UserProfileSubmissionTableViewCell.swift
//
//  Created by Viable Industries on 8/6/16.
//  Copyright © 2016 Viable Industries, L.L.C. All rights reserved.
//

import UIKit

class UserProfileSubmissionTableViewCell: UITableViewCell {
    
    
    //
    // MARK: @IBOutlets
    //
    @IBOutlet weak var imageViewReportOwnerImage: UIImageView!

    @IBOutlet weak var reportOwnerImageButton: UIButton!
    
    @IBOutlet weak var reportOwnerName: UILabel!
    @IBOutlet weak var reportTerritoryName: UILabel!
    @IBOutlet weak var reportDate: UILabel!
    @IBOutlet weak var reportImageView: UIImageView!
    
    @IBOutlet weak var buttonReportShare: UIButton!
    @IBOutlet weak var buttonReportMap: UIButton!
    @IBOutlet weak var buttonReportDirections: UIButton!
    @IBOutlet weak var buttonReportComments: UIButton!
    @IBOutlet weak var labelReportDescription: UILabel!
    @IBOutlet weak var labelReportGroups: UILabel!
    
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
