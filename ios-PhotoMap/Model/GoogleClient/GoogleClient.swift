//
//  GoogleClient.swift
//  ios-PhotoMap
//
//  Created by Nicholas Sutanto on 11/29/17.
//  Copyright © 2017 Nicholas Sutanto. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class GoogleClient {
    
    let clientUtil = ClientUtil()
    
    class func sharedInstance() -> GoogleClient {
        struct Singleton {
            static var sharedInstance = GoogleClient()
        }
        return Singleton.sharedInstance
    }
    
    func performReverseGeoLocation(_ latitude: Double, _ longitude: Double, completionHandlerGeoLocation: @escaping (_ country: String?, _ state: String?, _ city: String?, _ error: NSError?) -> Void) {
        /* 1. Specify parameters, method (if has {key}), and HTTP body (if POST) */
        
        var city: String?
        var state: String?
        var country: String?
        
        let request = URLRequest(url: URL(string: "https://maps.googleapis.com/maps/api/geocode/json?latlng=\(latitude),\(longitude)")! as URL)
        
        /* 2. Make the request */
        let _ = clientUtil.performRequest(request: request as! NSMutableURLRequest) { (parsedResult, error) in
            
            func sendError(_ error: String) {
                let errorInfo = [NSLocalizedDescriptionKey : error]
                completionHandlerGeoLocation(nil, nil, nil, NSError(domain: "getImages", code: 1, userInfo: errorInfo))
            }
            
            /* 3. Send the desired value(s) to completion handler */
            if let error = error {
                sendError("\(error)")
            } else {
                guard let results = parsedResult?["results"] as? [[String:AnyObject]] else {
                    sendError("Error when parsing result: results")
                    return
                }
                var isAllFound = false
                for result in results {
                
                    guard let addressComponents = result["address_components"] as? [[String:AnyObject]] else {
                        sendError("Error when parsing result: addressComponents")
                        return
                    }
                    
                    for addressComponent in addressComponents {
                        guard let types = addressComponent["types"] as? [String] else {
                            sendError("Error when parsing address component")
                            return
                        }
                        
                        guard let long_name = addressComponent["long_name"] as? String else {
                            sendError("Error when parsing address component")
                            return
                        }
                        guard let short_name = addressComponent["short_name"] as? String else {
                            sendError("Error when parsing address component")
                            return
                        }
                        
                        if types.contains("locality") {
                            if (city == nil) {
                                city = short_name
                                print("\(city)")
                            }
                        }
                        
                        if types.contains("administrative_area_level_1") {
                            if (state == nil) {
                                state = short_name
                            }
                        }
                        
                        if types.contains("country") {
                            if country == nil {
                                country = long_name
                                print("\(country)")
                            }
                        }
     
                        if (city != nil && state != nil && country != nil) {
                            isAllFound = true
                            break
                        }
                    }
                    if (isAllFound) {
                        completionHandlerGeoLocation(country, state, city, nil)
                        break
                    }
                }
                
                completionHandlerGeoLocation(country, state, city, nil)
            }
        }
    }
}
