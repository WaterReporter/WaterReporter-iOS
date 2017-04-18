//
//  HashtagTableView.swift
//  Water-Reporter
//
//  Created by Joshua Powell on 4/18/17.
//  Copyright © 2017 Viable Industries, L.L.C. All rights reserved.
//

import UIKit

class HashtagTableView: UITableView, UITableViewDataSource, UITableViewDelegate {
    
    var results: [String]! = [String]()
    var selected: String! = ""
    var search: String! = ""
    var parent: NewReportTableViewController!
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        return 1;
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        print("HashtagTableView::numberOfRowsInSection \(self.results.count)")
        
        if self.results.count != 0 {
            return self.results.count
        }
        
        return 0;
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        print("HashtagTableView::cellForRowAtIndexPath")
        
        //
        // Submissions
        //
        let cell = tableView.dequeueReusableCellWithIdentifier("hashtagAutocompleteTableViewCell", forIndexPath: indexPath) as! HashtagAutocompleteTableViewCell
        
        let _result = self.results[indexPath.row]
        
        guard (_result != "") else {
            return cell
        }
        
        cell.labelHashtagValue.text = "#\(_result)"
        
        return cell

    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {

        let _selection = self.results[indexPath.row]
        
        guard (_selection != "") else {
            return
        }
        
        print("Remove search text [\(self.search)] from selection [\(_selection)]")
        
        let _finalSelection = _selection.stringByReplacingOccurrencesOfString(self.search, withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil);
        
        print("_finalSelection [\(_finalSelection)]")
        
        
        parent.selectedValue(_finalSelection)
        
        self.hidden = true
    }
    
}
