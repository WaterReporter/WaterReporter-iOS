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
    
    static let GET_MANY_USER = "https://api.waterreporter.org/v2/data/user"
    
    static let POST_AUTH_REMOTE = "https://api.waterreporter.org/v2/auth/remote"
    static let GET_AUTH_AUTHORIZE = "https://www.waterreporter.org/authorize"

    static let GET_USER_ME = "https://api.waterreporter.org/v2/data/me"
    static let POST_USER_REGISTER = "https://api.waterreporter.org/v2/user/register"
    static let GET_USER_PROFILE = "https://api.waterreporter.org/v2/data/user/"
    static let POST_USER_PROFILE = "https://api.waterreporter.org/v2/data/user/"
    static let POST_PASSWORD_RESET = "https://api.waterreporter.org/v2/reset"
    
    static let GET_MANY_ORGANIZATIONS = "https://api.waterreporter.org/v2/data/organization"
    
    
}
