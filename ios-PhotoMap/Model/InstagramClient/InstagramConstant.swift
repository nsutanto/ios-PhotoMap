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
        static let REDIRECT_URI = "https://nsutanto.blogspot.com/"
        
        // MARK: URLs
        static let API_SCHEME = "https"
        static let API_HOST = "api.instagram.com"
        
        static let RESPONSE_TYPE = "token"
        //static let RESPONSE_TYPE = "code"
        static let INSTAGRAM_SCOPE = "basic"
    }

    // MARK: Paths
    struct Paths {
        static let AUTHORIZE = "/oauth/authorize/"
    }
    
    struct AuthorizationKeys {
        static let CLIENT_ID  = "client_id"
        static let REDIRECT_URI = "redirect_uri"
        static let RESPONSE_TYPE = "response_type"
    }
    
    struct AuthorizationResponse {
        static let ACCESS_TOKEN =  "access_token"
    }
}
