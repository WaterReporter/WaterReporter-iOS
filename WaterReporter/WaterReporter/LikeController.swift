//
//  LikeController.swift
//  Water-Reporter
//
//  Created by Joshua Powell on 8/8/17.
//  Copyright © 2017 Viable Industries, L.L.C. All rights reserved.
//

import Alamofire
import Foundation
import SwiftyJSON
import UIKit

class LikeController {
    
    init() {
    
    }
    
    //
    // MARK: Like Functionality
    //
    public func userHasLikedReport(_report: JSON, _current_user_id: Int) -> Bool {
        
        if (_report["likes"].count != 0) {
            for _like in _report["likes"] {
                if (_like.1["properties"]["owner_id"].intValue == _current_user_id) {
                    return true
                }
            }
        }
        
        return false
    }
    
    public func updateReportLikeCount(indexPathRow: Int, addLike: Bool = true) {
        
        print("LikeController::updateReportLikeCount")
        
//        let _indexPath = NSIndexPath(forRow: indexPathRow, inSection: 0)
//        
//        let _cell: TableViewCell = self.tableView.cellForRowAtIndexPath(_indexPath) as! TableViewCell
//        
//        // Change the Heart icon to red
//        //
//        if (addLike) {
//            _cell.reportLikeButton.setImage(UIImage(named: "icon--heartred"), forState: .Normal)
//            //_cell.reportLikeButton.addTarget(self, action: #selector(unlikeCurrentReport(_:)), forControlEvents: .TouchUpInside)
//        } else {
//            _cell.reportLikeButton.setImage(UIImage(named: "icon--heart"), forState: .Normal)
//            //_cell.reportLikeButton.addTarget(self, action: #selector(likeCurrentReport(_:)), forControlEvents: .TouchUpInside)
//        }
//        
//        // Update the total likes count
//        //
//        let _report = JSON(self.reports[(indexPathRow)].objectForKey("properties")!)
//        let _report_likes_count: Int = _report["likes"].count
//        
//        var _report_likes_updated_total: Int! = _report_likes_count
//        
//        if (addLike) {
//            _report_likes_updated_total = _report_likes_count+1
//        }
//        else {
//            _report_likes_updated_total = _report_likes_count-1
//        }
//        
//        var reportLikesCountText: String = ""
//        
//        if _report_likes_updated_total == 1 {
//            reportLikesCountText = "1 like"
//        }
//        else if _report_likes_updated_total >= 1 {
//            reportLikesCountText = "\(_report_likes_updated_total) likes"
//        }
//        else {
//            reportLikesCountText = "0 likes"
//        }
//        
//        _cell.reportLikeCount.setTitle(reportLikesCountText, forState: .Normal)
//        
        
    }
    
    public func likeCurrentReport(sender: UIButton) {
        
        print("LikeController::likeCurrentReport Incrementing Report Likes by 1")

//        // Update the visible "# like" count of likes
//        //
//        self.updateReportLikeCount(sender.tag)
//        
//
//        // Create necessary Authorization header for our request
//        //
//        let accessToken = NSUserDefaults.standardUserDefaults().objectForKey("currentUserAccountAccessToken")
//        let _headers = [
//            "Authorization": "Bearer " + (accessToken! as! String)
//        ]
//        
//        //
//        // PARAMETERS
//        //
//        let _report = JSON(self.reports[(sender.tag)])
//        let _report_id: String = "\(_report["id"])"
//        
//        let _parameters: [String:AnyObject] = [
//            "report_id": _report_id
//        ]
//        
//        Alamofire.request(.POST, Endpoints.POST_LIKE, parameters: _parameters, headers: _headers, encoding: .JSON)
//            .responseJSON { response in
//                
//                switch response.result {
//                case .Success(let value):
//                    print("Response Success \(value)")
//                    let _reports = self.reports[(sender.tag)]
//                    
//                    //                    _reports.addObject(value)
//                    
//                    //                    self.tableView.reloadData()
//                    
//                    break
//                case .Failure(let error):
//                    print("Response Failure \(error)")
//                    break
//                }
//                
//        }
    }
    
    public func unlikeCurrentReport(sender: UIButton) {
        
        print("LikeController::unlikeCurrentReport  Decrementing Report Likes by 1")
//        // Update the visible "# like" count of likes
//        //
//        self.updateReportLikeCount(sender.tag, addLike: false)
//        
//
//        // Create necessary Authorization header for our request
//        //
//        let accessToken = NSUserDefaults.standardUserDefaults().objectForKey("currentUserAccountAccessToken")
//        let _headers = [
//            "Authorization": "Bearer " + (accessToken! as! String)
//        ]
//        
//        //
//        // PARAMETERS
//        //
//        let _report = JSON(self.reports[(sender.tag)])
//        let _report_id: String = "\(_report["id"])"
//        
//        let _parameters: [String:AnyObject] = [
//            "report_id": _report_id
//        ]
//        
//        //
//        // ENDPOINT
//        //
//        var _like_id: String = ""
//        let _user_id_number = NSUserDefaults.standardUserDefaults().objectForKey("currentUserAccountUID") as! NSNumber
//        var _like_index: Int = 0
//        
//        if (_report["properties"]["likes"].count != 0) {
//            
//            for _like in _report["properties"]["likes"] {
//                if (_like.1["properties"]["owner_id"].intValue == _user_id_number.integerValue) {
//                    print("_like.1 \(_like.1)")
//                    _like_id = "\(_like.1["id"])"
//                    _like_index = Int(_like.0)!
//                }
//            }
//        }
//        
//        let _endpoint: String = Endpoints.DELETE_LIKE + "/\(_like_id)"
//        
//        print("_endpoint \(_endpoint)")
//        
//        
//        //
//        // REQUEST
//        //
//        Alamofire.request(.DELETE, _endpoint, parameters: _parameters, headers: _headers, encoding: .JSON)
//            .responseJSON { response in
//                
//                switch response.result {
//                case .Success(let value):
//                    print("Response Success \(value)")
//                    
//                    if (_like_index != 0) {
//                        let _reports = self.reports[(sender.tag)]
//                        let _properties = _reports.objectForKey("properties")
//                        let _likes : NSMutableArray = (_properties!.objectForKey("likes") as! NSArray).mutableCopy() as! NSMutableArray
//                        
//                        //                        _likes.removeObjectAtIndex(_like_index)
//                    }
//                    
//                    //                    self.tableView.reloadData()
//                    
//                    break
//                case .Failure(let error):
//                    print("Response Failure \(error)")
//                    break
//                }
//                
//        }
    }
    
}
