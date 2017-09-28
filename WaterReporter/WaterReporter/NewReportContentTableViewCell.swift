//
//  NewReportContentTableViewCell.swift
//  Water-Reporter
//
//  Created by Joshua Powell on 9/15/17.
//  Copyright © 2017 Viable Industries, L.L.C. All rights reserved.
//

import Alamofire
import SwiftyJSON
import UIKit

class NewReportContentTableViewCell: UITableViewCell {
    
    
    //
    // MARK: View-wide Variables
    //
    var dataSource: HashtagTableView = HashtagTableView()
    var hashtagAutocomplete: [String] = [String]()
    var hashtagSearchTimer: NSTimer = NSTimer()
    var hashtagSearchEnabled: Bool = false

    
    //
    // MARK: IBOutlets
    //
    @IBOutlet weak var buttonReportAddImage: UIButton!
    @IBOutlet weak var imageReportImage: UIImageView!
    @IBOutlet weak var textviewReportDescription: UITextView!
    @IBOutlet weak var tableViewHashtag: HashtagTableView!
    @IBOutlet weak var typeAheadHeight: NSLayoutConstraint!
    @IBOutlet weak var ogViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var ogView: UIView!
    @IBOutlet weak var ogImage: UIImageView!
    @IBOutlet weak var ogTitle: UILabel!
    @IBOutlet weak var ogDescription: UILabel!

    
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
