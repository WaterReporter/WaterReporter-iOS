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
