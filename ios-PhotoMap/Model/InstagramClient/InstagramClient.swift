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
    
    func getUserInfo() {
         /* 1. Specify parameters, method (if has {key}), and HTTP body (if POST) */
        let methodParameters = [
            Parameters.ACCESS_TOKEN: self.accessToken
        ]
        
        let url = clientUtil.parseURLFromParameters(Constants.API_SCHEME,
                                                    Constants.API_HOST,
                                                    Paths.USER_SELF,
                                                    methodParameters as [String : AnyObject])
        let request = URLRequest(url: url)
        
        /* 2. Make the request */
        let _ = clientUtil.performRequest(request: request as! NSMutableURLRequest) { (parsedResult, error) in
            
            func sendError(_ error: String) {
                let userInfo = [NSLocalizedDescriptionKey : error]
                //completionHandlerSearchPhotos(nil, nil, NSError(domain: "searchPhotos", code: 1, userInfo: userInfo))
            }
            
            /* 3. Send the desired value(s) to completion handler */
            if let error = error {
                sendError("\(error)")
            } else {
                
                /* GUARD: Is the "data" key in our result? */
                guard let dataDictionary = parsedResult?[SelfResponses.DATA] as? [String:AnyObject] else {
                    sendError("Error when parsing result: data")
                    return
                }
                
                /* Guard: Is the "username" key in our result? */
                guard let userName = dataDictionary[SelfResponses.USERNAME] as? String else {
                    sendError("Error when parsing result: username")
                    return
                }
                
                /* Guard: Is the "full_name" key in our result? */
                guard let fullName = dataDictionary[SelfResponses.FULL_NAME] as? String else {
                    sendError("Error when parsing result: full_name")
                    return
                }
                
                /* Guard: Is the "profile_picture" key in our result? */
                guard let profilePicture = dataDictionary[SelfResponses.PROFILE_PICTURE] as? String else {
                    sendError("Error when parsing result: profile_picture")
                    return
                }

                print("****** \(userName) \(fullName) \(profilePicture)")
            }
        }
    }
}
