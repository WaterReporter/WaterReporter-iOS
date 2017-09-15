//
//  Endpoints.swift
//  WaterReporter
//
//  Created by Viable Industries on 7/25/16.
//  Copyright © 2016 Viable Industries, L.L.C. All rights reserved.
//

import Foundation

struct Endpoints {
    
    static let GET_MANY_REPORTS = "https://api.waterreporter.org/v2/data/report"
    static let POST_REPORT = "https://api.waterreporter.org/v2/data/report"

    static let GET_MANY_REPORT_LIKES = "https://api.waterreporter.org/v2/data/like"
    static let POST_LIKE = "https://api.waterreporter.org/v2/data/like"
    static let DELETE_LIKE = "https://api.waterreporter.org/v2/data/like"

    static let GET_MANY_USER = "https://api.waterreporter.org/v2/data/user"
    
    static let POST_AUTH_REMOTE = "https://api.waterreporter.org/v2/auth/remote"
    static let GET_AUTH_AUTHORIZE = "https://www.waterreporter.org/authorize"

    static let GET_USER_ME = "https://api.waterreporter.org/v2/data/me"
    static let POST_USER_REGISTER = "https://api.waterreporter.org/v2/user/register"
    static let GET_USER_PROFILE = "https://api.waterreporter.org/v2/data/user/"
    static let POST_USER_PROFILE = "https://api.waterreporter.org/v2/data/user/"
    static let POST_PASSWORD_RESET = "https://api.waterreporter.org/v2/reset"
    
    static let POST_IMAGE = "https://api.waterreporter.org/v2/media/image"
    
    static let GET_MANY_ORGANIZATIONS = "https://api.waterreporter.org/v2/data/organization"
    
    static let GET_MANY_REPORT_COMMENTS = "https://api.waterreporter.org/v2/data/comment"
    static let POST_COMMENT = "https://api.waterreporter.org/v2/data/comment"

    static let GET_MANY_HASHTAGS = "https://api.waterreporter.org/v2/data/hashtag"

    static let GET_MANY_TERRITORY = "https://api.waterreporter.org/v2/data/territory"
    static let GET_MANY_HUC8WATERSHEDS = "https://api.waterreporter.org/v2/data/huc-8"

    static let TRENDING_GROUP = "https://api.waterreporter.org/v2/data/trending/group"
    static let TRENDING_HASHTAG = "https://api.waterreporter.org/v2/data/trending/hashtag"
    static let TRENDING_PEOPLE = "https://api.waterreporter.org/v2/data/trending/people"
    static let TRENDING_TERRITORY = "https://api.waterreporter.org/v2/data/trending/territory"
    static let TERRITORY = "https://huc.waterreporter.org/8/"
    
    //
    //
    //
    
    var apiUrl: String! = "https://api.waterreporter.org/v2/data"
    
    func getManyReportComments(reportId: AnyObject) -> String {
        
        let _endpoint = apiUrl,
            _reportId = String(reportId)
        
        return _endpoint + "/report/" + _reportId + "/comments"
    }
    
}
