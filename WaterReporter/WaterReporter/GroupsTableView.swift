//
//  GroupsTableView.swift
//  Water-Reporter
//
//  Created by Joshua Powell on 9/13/17.
//  Copyright © 2017 Viable Industries, L.L.C. All rights reserved.
//

import Foundation
import SwiftyJSON
import UIKit

class GroupsTableView: UITableView, UITableViewDelegate, UITableViewDataSource {
    
    var groups: JSON?
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        print("GroupsTableView::tableView::cellForRowAtIndexPath \(groups!)");
        
        let cell = tableView.dequeueReusableCellWithIdentifier("reportGroupTableViewCell", forIndexPath: indexPath) as! ReportGroupTableViewCell

        //
        // Assign the organization logo to the UIImageView
        //
        cell.imageViewGroupLogo.tag = indexPath.row

        var organizationImageUrl:NSURL!

        if let thisOrganizationImageUrl: String = self.groups?["features"][indexPath.row]["properties"]["organization"]["properties"]["picture"].string {
            organizationImageUrl = NSURL(string: thisOrganizationImageUrl)
        }

        cell.imageViewGroupLogo.kf_indicatorType = .Activity
        cell.imageViewGroupLogo.kf_showIndicatorWhenLoading = true

        cell.imageViewGroupLogo.kf_setImageWithURL(organizationImageUrl, placeholderImage: nil, optionsInfo: nil, progressBlock: nil, completionHandler: {
            (image, error, cacheType, imageUrl) in
            cell.imageViewGroupLogo.image = image
            cell.imageViewGroupLogo.layer.cornerRadius = cell.imageViewGroupLogo.frame.size.width / 2
            cell.imageViewGroupLogo.clipsToBounds = true
        })

        //
        // Assign the organization name to the UILabel
        //
        if let thisOrganizationName: String = self.groups?["features"][indexPath.row]["properties"]["organization"]["properties"]["name"].string {
            cell.labelGroupName.text = thisOrganizationName
        }

        // Assign existing groups to the group field
        cell.switchSelectGroup.tag = indexPath.row

//        if let _organization_id_number = self.groups?["features"][indexPath.row]["properties"]["organization_id"] {
//
////            if self.tempGroups.contains("\(_organization_id_number)") {
////                cell.switchSelectGroup.on = true
////            }
////            else {
////                cell.switchSelectGroup.on = false
////            }
//            
//        }
        
        
        return cell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 72.0
    }
    
//    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
//
//        print("GroupsTableView::tableView::numberOfSectionsInTableView")
//        
//        return 1
//    }

    func tableView(tableView:UITableView, numberOfRowsInSection section: Int) -> Int {
        
        print("GroupsTableView::tableView::numberOfRowsInSection")
        
        if self.groups == nil {
            print("Showing 0 group cells")
            return 0
        }

        print("Showing \((self.groups?.count)!) group cells")
        return (self.groups?.count)!
    }
}
