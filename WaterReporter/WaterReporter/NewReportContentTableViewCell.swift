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
        
        // Enable custom "Done" toolbar
        //
        self.addDoneButtonOnKeyboard()
        
//        dataSource.parent = self

    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }

    //
    // MARK: Custom
    //
    func addDoneButtonOnKeyboard() {
        let doneToolbar: UIToolbar = UIToolbar(frame: CGRectMake(0, 0, 320, 50))
        doneToolbar.barStyle = UIBarStyle.Default

        let flexSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil)
        let done: UIBarButtonItem = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.Done, target: self, action: #selector(self.doneButtonAction))

        var items: [UIBarButtonItem]? = [UIBarButtonItem]()

        items?.append(flexSpace)
        items?.append(done)

        doneToolbar.items = items

        doneToolbar.sizeToFit()

        self.textviewReportDescription.inputAccessoryView = doneToolbar
    }

    func doneButtonAction() {
        self.textviewReportDescription.resignFirstResponder()
    }

    func textViewShouldReturn(textField: UITextView) -> Bool {
        
        let nextTag = textField.tag + 1;
        let nextResponder=textField.superview?.superview?.superview?.viewWithTag(nextTag) as UIResponder!
        
        if (nextResponder != nil){
            nextResponder?.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
        }
        
        return false
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        let nextTag = textField.tag + 1;
        let nextResponder=textField.superview?.superview?.superview?.viewWithTag(nextTag) as UIResponder!
        
        if (nextResponder != nil){
            nextResponder?.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
        }
        
        return false
    }
    
}
