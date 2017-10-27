//
//  InstagramConstant.swift
//  ios-PhotoMap
//
//  Created by Nicholas Sutanto on 10/26/17.
//  Copyright © 2017 Nicholas Sutanto. All rights reserved.
//

import Foundation

extension InstagramClient {
    // MARK: Constants
    struct Constants {
        
        static let CLIENT_ID  = "2d8f5103db6e40b696fdae1297515b55"
        static let CLIENT_SECRET = "2383a904b3ef41ca9aa476432c617eb9"
        
        // MARK: URLs
        static let API_SCHEME = "https"
        static let API_HOST = "api.instagram.com"
        static let API_PATH = ""
    
        //static let INSTAGRAM_AUTHURL = "https://api.instagram.com/oauth/authorize/"
        //static let INSTAGRAM_APIURl  = "https://api.instagram.com/v1/users/"
        
        static let REDIRECT_URI = "https://nsutanto.blogspot.com/"
        static let ACCESS_TOKEN =  "access_token"
        static let INSTAGRAM_SCOPE = "basic"
    }

    // MARK: Methods
    struct Methods {
        static let AUTHORIZE = "/oauth/authorize/"
    }
}
