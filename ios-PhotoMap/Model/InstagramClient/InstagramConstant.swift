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
        static let INSTAGRAM_SCOPE = "basic"
    }

    // MARK: Paths
    struct Paths {
        static let AUTHORIZE = "/oauth/authorize/"
        static let USER_SELF = "/v1/users/self/"
        static let USER_MEDIA = "/v1/users/self/media/recent/"
    }
    
    struct AuthorizationKeys {
        static let CLIENT_ID  = "client_id"
        static let REDIRECT_URI = "redirect_uri"
        static let RESPONSE_TYPE = "response_type"
    }
    
    struct Parameters {
        static let ACCESS_TOKEN =  "access_token"
    }
    
    struct SelfResponses {
        static let DATA = "data"
        static let USERNAME = "username"
        static let FULL_NAME = "full_name"
        static let PROFILE_PICTURE = "profile_picture"
    }
    
    struct MediaResponses {
        static let DATA = "data"
        static let CAPTION = "caption"
        static let TEXT = "text"
        static let IMAGES = "images"
        static let TYPE = "type"
        static let CAROUSEL_MEDIA = "carousel_media"
        static let STANDARD_RESOLUTION = "standard_resolution"
        static let URL = "url"
        static let ID = "id"
        static let LOCATION = "location"
        static let LATITUDE = "latitude"
        static let LONGITUDE = "longitude"
    }
}
