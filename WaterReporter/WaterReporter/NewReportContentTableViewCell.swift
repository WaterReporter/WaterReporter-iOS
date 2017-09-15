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

    
    //
    // MARK: Overrides
    //
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Enable custom "Done" toolbar
        //
        self.addDoneButtonOnKeyboard()
        
        
        // Enable Hashtag Tableview
        //
        self.tableViewHashtag.delegate = self.dataSource
        self.tableViewHashtag.dataSource = self.dataSource
        dataSource.parent = self

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
        self.textviewReportDescription.resignFirstResponder()
    }
    
    
    //
    // MARK: Hashtag
    //
    func searchHashtags(timer: NSTimer) {

        let queryText: String! = "\(timer.userInfo!)"

        print("searchHashtags fired with \(queryText)")

        //
        // Send a request to the defined endpoint with the given parameters
        //
        let parameters = [
            "q": "{\"filters\": [{\"name\":\"tag\",\"op\":\"like\",\"val\":\"\(queryText)%\"}]}"
        ]

        Alamofire.request(.GET, Endpoints.GET_MANY_HASHTAGS, parameters: parameters)
            .responseJSON { response in

                switch response.result {
                case .Success(let value):

                    let _results = JSON(value)
                    print("_results \(_results)")

                    for _result in _results["features"] {
                        print("_result \(_result.1["properties"]["tag"])")
                        let _tag = "\(_result.1["properties"]["tag"])"
                        self.dataSource.results.append(_tag)
                    }

                    self.dataSource.numberOfRowsInSection(_results["features"].count)

                    self.tableViewHashtag.reloadData()

                case .Failure(let error):
                    print(error)
                    break
                }
                
        }
    }

    func textViewDidChange(textView: UITextView) {
        
        let _text: String = "\(textView.text)"
        
        if _text != "" && _text.characters.last! == "#" {
            self.hashtagSearchEnabled = true
            self.textviewReportDescription.becomeFirstResponder()
            
            print("Hashtag Search: Found start of hashtag")
        }
        else if _text != "" && self.hashtagSearchEnabled == true && _text.characters.last! == " " {
            self.tableViewHashtag.hidden = true
            self.hashtagSearchEnabled = false
            self.dataSource.results = [String]()
            
            self.typeAheadHeight.constant = 0.0
            self.tableViewHashtag.reloadData()
            self.textviewReportDescription.becomeFirstResponder()
            
            print("Hashtag Search: Disabling search because space was entered")
            print("Hashtag Search: Timer reset to zero due to search termination (space entered)")
            self.hashtagSearchTimer.invalidate()
            
        }
        else if _text != "" && self.hashtagSearchEnabled == true {
            
            self.tableViewHashtag.hidden = false
            self.dataSource.results = [String]()
            
            self.typeAheadHeight.constant = 128.0
            self.tableViewHashtag.reloadData()
            self.textviewReportDescription.becomeFirstResponder()
            
            // Identify hashtag search
            //
            let _hashtag_identifier = _text.rangeOfString("#", options:NSStringCompareOptions.BackwardsSearch)
            if ((_hashtag_identifier) != nil) {
                let _hashtag_search: String! = _text.substringFromIndex((_hashtag_identifier?.endIndex)!)
                
                // Add what the user is typing to the top of the list
                //
                print("Hashtag Search: Performing search for \(_hashtag_search)")
                
                dataSource.results = ["\(_hashtag_search)"]
                dataSource.search = "\(_hashtag_search)"
                
                dataSource.numberOfRowsInSection(dataSource.results.count)
                
                self.tableViewHashtag.reloadData()
                
                // Execute the serverside search BUT wait a few milliseconds between
                // each character so we aren't returning inconsistent results to
                // the user
                //
                print("Hashtag Search: Timer reset to zero")
                self.hashtagSearchTimer.invalidate()
                
                print("Hashtag Search: Send this to search methods \(_hashtag_search) after delay expires")
                self.hashtagSearchTimer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(self.searchHashtags(_:)), userInfo: _hashtag_search, repeats: false)
                
            }
            
        }
    }
    
    func selectedValue(value: String) {

        // Add the hashtag to the text
        //
        self.textviewReportDescription.text = "\(self.textviewReportDescription.text)\(value)"
        self.tableViewHashtag.reloadData()

        self.textviewReportDescription.becomeFirstResponder()


        // Reset the search
        //
        self.tableViewHashtag.hidden = true
        self.hashtagSearchEnabled = false
        self.dataSource.results = [String]()

        self.typeAheadHeight.constant = 0.0
        self.tableViewHashtag.reloadData()
        self.textviewReportDescription.becomeFirstResponder()
        
        print("Hashtag Search: Timer reset to zero due to user selection")
        self.hashtagSearchTimer.invalidate()


    }

    
}
