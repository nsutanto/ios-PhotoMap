//
//  ClientUtil.swift
//  ios-PhotoMap
//
//  Created by Nicholas Sutanto on 10/26/17.
//  Copyright © 2017 Nicholas Sutanto. All rights reserved.
//

import Foundation

class InstagramClient {
    
    let clientUtil = ClientUtil()
    var accessToken: String?
    
    class func sharedInstance() -> InstagramClient {
        struct Singleton {
            static var sharedInstance = InstagramClient()
        }
        return Singleton.sharedInstance
    }
    
    func getLoginURL() -> URL {
        let methodParameters = [
            AuthorizationKeys.CLIENT_ID: Constants.CLIENT_ID,
            AuthorizationKeys.REDIRECT_URI: Constants.REDIRECT_URI,
            AuthorizationKeys.RESPONSE_TYPE: Constants.RESPONSE_TYPE
        ]
        return clientUtil.parseURLFromParameters(Constants.API_SCHEME,
                                         Constants.API_HOST,
                                         Paths.AUTHORIZE,
                                         methodParameters as [String : AnyObject])
    }
    
}
