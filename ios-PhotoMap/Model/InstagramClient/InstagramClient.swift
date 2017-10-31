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
                /*
                /* GUARD: Is the "photos" key in our result? */
                guard let photosDictionary = parsedResult?[FlickrResponseKeys.Photos] as? [String:AnyObject] else {
                    sendError("Error when parsing result: photos")
                    return
                }
                
                /* Guard: Is the "pages" key in our result? */
                guard let pageNumberOut = photosDictionary[FlickrResponseKeys.Pages] as? Int else {
                    sendError("Error when parsing result: pages")
                    return
                }
                
                /* GUARD: Is the "photo" key in photosDictionary? */
                guard let photosArray = photosDictionary[FlickrResponseKeys.Photo] as? [[String: AnyObject]] else {
                    sendError("Error when parsing result: photo")
                    return
                }
                
                var urlArray = [String]()
                
                for photo in photosArray {
                    let photoDictionary = photo as [String:Any]
                    
                    /* GUARD: Does our photo have a key for 'url_q'? */
                    guard let imageUrlString = photoDictionary[FlickrResponseKeys.SquareURL] as? String else {
                        sendError("Error when parsing result: url_q")
                        return
                    }
                    
                    urlArray.append(imageUrlString)
                }
                
                completionHandlerSearchPhotos(urlArray, pageNumberOut, nil)
                */
            }
        }
        
        
    }
    
}
