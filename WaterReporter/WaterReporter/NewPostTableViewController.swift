//
//  NewPostTableViewController.swift
//  Water-Reporter
//
//  Created by Joshua Powell on 9/26/17.
//  Copyright © 2017 Viable Industries, L.L.C. All rights reserved.
//

import Alamofire
import Foundation
import SwiftyJSON   
import UIKit

class NewPostTableViewController: UITableViewController, UITextViewDelegate {
    
    
    //
    // MARK: Variables
    //
    var groups: JSON?
    
    var hashtags: JSON?
    var hashtagSearchModeEnabled: Bool = false
    var hashtagSearchModeTypeDelay: NSTimer = NSTimer()
    var hashtagSearchModeResults: [String]! = [String]()
    var hashtagSearchModeSearch: String = ""

    
    //
    // MARK: IBOutlets
    //
    @IBOutlet weak var reportImage: UIButton!
    @IBOutlet weak var reportDescription: UITextView!
    
    @IBOutlet weak var reportHashtags: UIScrollView!
    
    @IBOutlet weak var hashtagSearchModeResult_1: UIButton!
    @IBOutlet weak var hashtagSearchModeResult_2: UIButton!
    @IBOutlet weak var hashtagSearchModeResult_3: UIButton!
    @IBOutlet weak var hashtagSearchModeResult_4: UIButton!
    @IBOutlet weak var hashtagSearchModeResult_5: UIButton!
    @IBOutlet weak var hashtagSearchModeResult_6: UIButton!
    @IBOutlet weak var hashtagSearchModeResult_7: UIButton!
    @IBOutlet weak var hashtagSearchModeResult_8: UIButton!
    @IBOutlet weak var hashtagSearchModeResult_9: UIButton!
    @IBOutlet weak var hashtagSearchModeResult_10: UIButton!
    
    
    //
    // MARK: IBActions
    //
    @IBAction func hashtagSearchModeSetSelected(sender: UIButton) {
        
        print("NewPostTableViewController::hashtagSearchModeSetSelected \(sender.tag)")
        
        //
        // Before we execute the text replacement, make sure that the index is
        // not out of range
        //
        if ((self.hashtagSearchModeResults.count-1) >= sender.tag) {
            let _value = self.hashtagSearchModeResults[sender.tag]
            let _searchText = self.hashtagSearchModeSearch
            
            self.hashtagSearchModeSetSelected(_value, searchText: _searchText)
        }
        
    }

    
    //
    // MARK: Overrides
    //
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    //
    // MARK: TextView Overrides
    //
    func textViewDidBeginEditing(textView: UITextView) {
        
        print("NewPostTableViewController::textViewDidBeginEditing with text = \(textView.text)")
        
        if textView.text == "To get started, tap on the camera to add a photo, add comments, or link to content you'd like to share." {
            textView.text = ""
        }
        
    }
    
    func textViewDidEndEditing(textView: UITextView) {

        print("NewPostTableViewController::textViewDidEndEditing with text = \"\(textView.text)\"")
        
        if textView.text == "" {
            textView.text = "To get started, tap on the camera to add a photo, add comments, or link to content you'd like to share."
        }

    }
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {

        print("NewPostTableViewController::textView::shouldChangeTextInRange")
        
        let _searchText: String = "\(textView.text)"
        
        if text == "\n" {
            
            textView.resignFirstResponder()
            
            return false
        }
        else if _searchText != "" && _searchText.characters.last! == "#" {

            print("NewPostTableViewController::textView::shouldChangeTextInRange >>>> Hashtag start detected, activating hashtag search mode")

            self.hashtagSearchModeEnabled = true
            
        }
        else if _searchText != "" && self.hashtagSearchModeEnabled == true {

            if _searchText.characters.last! == " " {
                print("NewPostTableViewController::textView::shouldChangeTextInRange >>>> Hashtag end detected, disabling hashtag search mode and reset hashtag search")
                
                //
                // User entered a space, disable hashtag search mode, and
                // reset the hashtag search functionality.
                //
                self.hashtagSearchModeEnabled = true
                self.hashtagSearchModeTypeDelay.invalidate()
                self.hashtagSearchModeResults = [String]()
            }
            else {
                
                print("NewPostTableViewController::textView::shouldChangeTextInRange >>>> Hashtag active, searching remote hashtag dataset >>>> \(_searchText)")

                //
                // Hashtag Search Mode enabled and actively searching for
                // hashtags that match user input.
                //
                self.hashtagSearchModeResults = [String]()

                let _hashtag_identifier = _searchText.rangeOfString("#", options:NSStringCompareOptions.BackwardsSearch)

                if ((_hashtag_identifier) != nil) {
                    let _hashtag_search: String! = _searchText.substringFromIndex((_hashtag_identifier?.endIndex)!)
                    let _hashtag_search_with_replacement: String! = "\(_hashtag_search)\(text)"
                    
                    self.hashtagSearchModeSearch = "#\(_hashtag_search_with_replacement)"

                    // Add what the user is typing to the top of the list
                    //
                    print("NewPostTableViewController::textView::shouldChangeTextInRange >>>> Hashtag active, searching remote hashtag dataset for keyword \(_hashtag_search_with_replacement)")

                    // @TODO: UPDATE NUMBER OF ROWS IN SECTION
                    //
                    
                    self.hashtagSearchModeTypeDelay.invalidate()

                    // @TODO: EXECUTE REMOTE HASHTAG HTTP REQUEST
                    //
                    self.hashtagSearchModeTypeDelay = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(self.searchHashtags(_:)), userInfo: _hashtag_search_with_replacement, repeats: false)
                }
            }
        }

        return true
    }
    

    //
    // MARK: Table Overrides
    //
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 5
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {

        var _headerTitle = ""
        
        switch section {
            case 4:
                _headerTitle = "Share with your groups"
                break
            default:
                _headerTitle = "" // No change
                break
        }
        
        return _headerTitle
    }
    
    override func tableView(tableView:UITableView, numberOfRowsInSection section: Int) -> Int {
        
        var numberOfRows: Int = 1
        
        switch section {
            case 1:
                if self.hashtags != nil {
                    
                    let _numberOfAvailableFeatures: Int = (self.hashtags?["features"].count)!
                    numberOfRows = (_numberOfAvailableFeatures)
                }
                else if self.hashtags == nil && self.hashtagSearchModeEnabled == true {
                    //
                    // If there are no hashtags in the list, but the user is
                    // currently in 'hashtag search mode' return at least 1
                    // row allowing them to tap the hashtag they have entered.
                    //
                    numberOfRows = 1
                }
                else {
                    //
                    // If 'hashtag search mode' is not enable then show zero
                    // rows in the section. This should completely hide the
                    // section in the table view.
                    //
                    numberOfRows = 0
                }
                break
            case 4:
                if self.groups != nil {
                    
                    let _numberOfAvailableFeatures: Int = (self.groups?["features"].count)!
                    
                    numberOfRows = (_numberOfAvailableFeatures)
                    
                }
                break;
            default:
                numberOfRows = 1
                break;
        }
        
        return numberOfRows
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        if indexPath.section == 0 && indexPath.row == 0 {
            return 136.0
        }
        else if indexPath.section == 1 && indexPath.row == 0 {
            
            //
            // Display Hashtag rows if 'hashtag search mode' is enabled.
            //
            if self.hashtagSearchModeEnabled == true {
                return 136.0
            }

            //
            // Hide entire Hashtag section if 'hashtag search mode' is disabled.
            //
            return 0.0
        }
        
        return UITableViewAutomaticDimension
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let _section: Int = indexPath.section
        let _row: Int = indexPath.row
        
        if _section == 0 && _row == 0 {
            
        }
        
        //
        // TEMPORARY
        //
        return UITableViewCell()
    }
    

    //
    // MARK: Hashtag Functionality
    //
    func searchHashtags(timer: NSTimer) {
        
        let queryText: String! = "\(timer.userInfo!)"
        
        print("searchHashtags fired with \(queryText)")
        
        //
        // Send a request to the defined endpoint with the given parameters
        //
        let parameters = [
            "q": "{\"filters\": [{\"name\":\"tag\",\"op\":\"ilike\",\"val\":\"\(queryText)%\"}], \"order_by\":[{\"field\":\"tag\",\"direction\":\"asc\"}]}"
        ]
        
        Alamofire.request(.GET, Endpoints.GET_MANY_HASHTAGS, parameters: parameters)
            .responseJSON { response in
                
                switch response.result {
                    case .Success(let value):
                        
                        print("NewPostTableViewController::searchHashtags results = \(value)")

                        let _results = JSON(value)
                        
                        for _result in _results["features"] {
                            print("_result \(_result.1["properties"]["tag"])")
                            let _tag = "#\(_result.1["properties"]["tag"])"
                            self.hashtagSearchModeResults.append(_tag)
                        }
                        
                        self.reportHashtags.hidden = false
                        
                        self.hashtagSearchModePopulateButtons(self.hashtagSearchModeResults)

                    case .Failure(let error):
                        print(error)
                        break
                }
                
        }
    }
    
    
//    func selectedValue(value: String, searchText: String) {
//        
////        let _index = NSIndexPath.init(forRow: 0, inSection: 0)
//        
////        let _selection = "\(value)"
//        
////        print("Hashtag Selected, now we need to update the textview with selected \(value) and search text \(searchText) so that it makes sense with \(self.reportDescription)")
////        
////        let _temporaryCopy = self.reportDescription
////        
////        let _updatedDescription = _temporaryCopy.stringByReplacingOccurrencesOfString(searchText, withString: _selection, options: NSStringCompareOptions.LiteralSearch, range: nil)
////        
////        print("Updated Text \(_updatedDescription)")
////        
////        // Add the hashtag to the text
////        //
////        self.reportDescription = "\(_updatedDescription)"
////        
////        // Reset the search
////        //
////        self.hashtagSearchEnabled = false
////        self.dataSource.results = [String]()
////        
////        self.tableView.reloadRowsAtIndexPaths([_index], withRowAnimation: UITableViewRowAnimation.None)
////        
////        print("Hashtag Search: Timer reset to zero due to user selection")
////        self.hashtagSearchTimer.invalidate()
//        
//        
//    }

    
    //
    // MARK: Hashtag Functionality
    //
    func hashtagSearchModePopulateButtons(results: [String]) {
        
        print("NewPostTableViewController::hashtagSearchModePopulateButtons \(results), \(results.count)")
        
        if results.count >= 10 {
            self.hashtagSearchModeResult_10.setTitle("\(self.hashtagSearchModeResults[9])", forState: .Normal)
        }

        if results.count >= 9 {
            self.hashtagSearchModeResult_9.setTitle("\(self.hashtagSearchModeResults[8])", forState: .Normal)
        }

        if results.count >= 8 {
            self.hashtagSearchModeResult_8.setTitle("\(self.hashtagSearchModeResults[7])", forState: .Normal)
        }

        if results.count >= 7 {
            self.hashtagSearchModeResult_7.setTitle("\(self.hashtagSearchModeResults[6])", forState: .Normal)
        }
        
        if results.count >= 6 {
            self.hashtagSearchModeResult_6.setTitle("\(self.hashtagSearchModeResults[5])", forState: .Normal)
        }

        if results.count >= 5 {
            self.hashtagSearchModeResult_5.setTitle("\(self.hashtagSearchModeResults[4])", forState: .Normal)
        }
        
        if results.count >= 4 {
            self.hashtagSearchModeResult_4.setTitle("\(self.hashtagSearchModeResults[3])", forState: .Normal)
        }
        
        if results.count >= 3 {
            self.hashtagSearchModeResult_3.setTitle("\(self.hashtagSearchModeResults[2])", forState: .Normal)
        }
        
        if results.count >= 2 {
            self.hashtagSearchModeResult_2.setTitle("\(self.hashtagSearchModeResults[1])", forState: .Normal)
        }
        
        if results.count >= 1 {
            self.hashtagSearchModeResult_1.setTitle("\(self.hashtagSearchModeResults[0])", forState: .Normal)
        }

    }
    
    func hashtagSearchModeSetSelected(value: String, searchText: String) {

        let _selection = "\(value)"

        print("Hashtag Selected, now we need to update the textview with selected \(value) and search text \(searchText) so that it makes sense with \(self.reportDescription.text)")

        let _temporaryCopy = self.reportDescription.text

        let _updatedDescription = _temporaryCopy.stringByReplacingOccurrencesOfString(searchText, withString: _selection, options: NSStringCompareOptions.LiteralSearch, range: nil)

        print("Updated Text \(_updatedDescription)")

        // Add the hashtag to the text
        //
        self.reportDescription.text = "\(_updatedDescription)"

        // Reset the search
        //
        self.hashtagSearchModeEnabled = false
        self.reportHashtags.hidden = true
        self.hashtagSearchModeTypeDelay.invalidate()
        self.hashtagSearchModeResults = [String]()
        
        self.hashtagSearchModeResult_1.setTitle("", forState: .Normal)
        self.hashtagSearchModeResult_2.setTitle("", forState: .Normal)
        self.hashtagSearchModeResult_3.setTitle("", forState: .Normal)
        self.hashtagSearchModeResult_4.setTitle("", forState: .Normal)
        self.hashtagSearchModeResult_5.setTitle("", forState: .Normal)
        self.hashtagSearchModeResult_6.setTitle("", forState: .Normal)
        self.hashtagSearchModeResult_7.setTitle("", forState: .Normal)
        self.hashtagSearchModeResult_8.setTitle("", forState: .Normal)
        self.hashtagSearchModeResult_9.setTitle("", forState: .Normal)
        self.hashtagSearchModeResult_10.setTitle("", forState: .Normal)
    }

}






