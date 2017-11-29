//
//  ClientUtil.swift
//  ios-PhotoMap
//
//  Created by Nicholas Sutanto on 10/26/17.
//  Copyright © 2017 Nicholas Sutanto. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class InstagramClient {
    
    let clientUtil = ClientUtil()
    var accessToken: String?
   
    // Initialize core data stack
    let coreDataStack: CoreDataStack?
    
    class func sharedInstance() -> InstagramClient {
        struct Singleton {
            static var sharedInstance = InstagramClient()
        }
        return Singleton.sharedInstance
    }
    
    init() {
        let delegate = UIApplication.shared.delegate as! AppDelegate
        coreDataStack = delegate.stack
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
    
    func getUserInfo(completionHandlerUserInfo: @escaping (_ userInfo: UserInfo?, _ error: NSError?) -> Void) {
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
                let errorInfo = [NSLocalizedDescriptionKey : error]
                completionHandlerUserInfo(nil, NSError(domain: "getUserInfo", code: 1, userInfo: errorInfo))
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
                guard let profilePictureURL = dataDictionary[SelfResponses.PROFILE_PICTURE] as? String else {
                    sendError("Error when parsing result: profile_picture")
                    return
                }
                
                let request: NSFetchRequest<UserInfo> = UserInfo.fetchRequest()
                request.predicate = NSPredicate(format: "userName == %@", userName)
                if let result = try? self.coreDataStack?.context.fetch(request) {
                    if (result?.first) == nil {
                        
                        let userInfo = UserInfo(userName: userName, fullName: fullName, profilePictureURL: profilePictureURL, profilePictureData: nil, token: self.accessToken, context: (self.coreDataStack?.context)!)
            
                        completionHandlerUserInfo(userInfo, nil)
                    }
                    else {
                        let userInfo = result?.first
                        completionHandlerUserInfo(userInfo, nil)
                    }
                }
                else {
                    sendError("User is already created")
                }
            }
        }
    }
    
    func getImages(completionHandlerGetImages: @escaping (_ images: [Image]?, _ error: NSError?) -> Void) {
        
        var imageArray = [Image]()
        /* 1. Specify parameters, method (if has {key}), and HTTP body (if POST) */
        let methodParameters = [
            Parameters.ACCESS_TOKEN: self.accessToken,
            Parameters.COUNT: "5000" // let's do 5000 pictures for now... we need to improve using pagination
        ]
        
        let url = clientUtil.parseURLFromParameters(Constants.API_SCHEME,
                                                    Constants.API_HOST,
                                                    Paths.USER_MEDIA,
                                                    methodParameters as [String : AnyObject])
        let request = URLRequest(url: url)
        
        /* 2. Make the request */
        let _ = clientUtil.performRequest(request: request as! NSMutableURLRequest) { (parsedResult, error) in
            
            func sendError(_ error: String) {
                let errorInfo = [NSLocalizedDescriptionKey : error]
                completionHandlerGetImages(nil, NSError(domain: "getImages", code: 1, userInfo: errorInfo))
            }
            
            /* 3. Send the desired value(s) to completion handler */
            if let error = error {
                sendError("\(error)")
            } else {
                
                /* GUARD: Is the "data" key in our result? */
                guard let dataDictionary = parsedResult?[MediaResponses.DATA] as? [[String:AnyObject]] else {
                    sendError("Error when parsing result: data")
                    return
                }
                
                for data in dataDictionary {
                    
                    /* Guard: Is the "id" key in our result? */
                    guard let id = data[MediaResponses.ID] as? String else {
                        sendError("Error when parsing result: id")
                        return
                    }
                    
                    /* Guard: Is the "type" key in our result? */
                    guard let type = data[MediaResponses.TYPE] as? String else {
                        sendError("Error when parsing result: type")
                        return
                    }
                    
                    
                    /* Guard: Is the "caption" key in our result? Caption is optional, some pictures might not have captions */
                    var text : String = ""
                    if let caption = data[MediaResponses.CAPTION] as? [String:AnyObject]  {
                        /* Guard: Is the "text" key in our result? */
                        if let textTemp = caption[MediaResponses.TEXT] as? String {
                            text = textTemp
                        } else {
                            sendError("Error when parsing result: text")
                            return
                        }
                    }
                    else {
                        // Do nothing. No caption.
                    }
                    
                    /* Guard: Is the "location" key in our result? Geo location is optional, some picture might not have geo location*/
                    var longitude: Double? = nil
                    var latitude: Double? = nil
                    if let location = data[MediaResponses.LOCATION] as? [String:AnyObject]  {
                        /* Guard: Is the "longitude" key in our result? */
                        if let longitudeTemp = location[MediaResponses.LONGITUDE] as? Double {
                            longitude = longitudeTemp
                        } else {
                            sendError("Error when parsing result: longitude")
                            return
                        }
                        
                        /* Guard: Is the "latitude" key in our result? */
                        if let latitudeTemp = location[MediaResponses.LATITUDE] as? Double {
                            latitude = latitudeTemp
                        } else {
                            sendError("Error when parsing result: latitude")
                            return
                        }
                    } else {
                        // Do nothing. No location data.
                    }
                    
                    
                    if (type == "image") {
                        /* Guard: Is the "images" key in our result? */
                        guard let images = data[MediaResponses.IMAGES] as? [String:AnyObject] else {
                            sendError("Error when parsing result: images")
                            return
                        }
                        
                        /* Guard: Is the "images - Standard Resolution" key in our result? */
                        guard let standardResolution = images[MediaResponses.STANDARD_RESOLUTION] as? [String:AnyObject] else {
                            sendError("Error when parsing result: standard resolution")
                            return
                        }
                        
                        /* Guard: Is the "images - Standard Resolution - URL" key in our result? */
                        guard let imageURL = standardResolution[MediaResponses.URL] as? String else {
                            sendError("Error when parsing result: url")
                            return
                        }
                        
                        let image = self.addImageToCoreData(longitude, latitude, id, imageURL, text)
                        
                        if image != nil {
                            imageArray.append(image!)
                        }
                    }
                    else if (type == "carousel") {
                        /* Guard: Is the "carousel" key in our result? */
                        guard let carousel_medias = data[MediaResponses.CAROUSEL_MEDIA] as? [[String:AnyObject]] else {
                            sendError("Error when parsing result: carousel media")
                            return
                        }
                        
                        for imageEntry in carousel_medias {
                            /* Guard: Is the "images" key in our result? */
                            if let images = imageEntry[MediaResponses.IMAGES] as? [String:AnyObject]  {
                                /* Guard: Is the "images - Standard Resolution" key in our result? */
                                guard let standardResolution = images[MediaResponses.STANDARD_RESOLUTION] as? [String:AnyObject] else {
                                    sendError("Error when parsing result: standard resolution")
                                    return
                                }
                                
                                /* Guard: Is the "images - Standard Resolution - URL" key in our result? */
                                guard let imageURL = standardResolution[MediaResponses.URL] as? String else {
                                    sendError("Error when parsing result: url")
                                    return
                                }
                                
                                let image = self.addImageToCoreData(longitude, latitude, id, imageURL, text)
                                
                                if image != nil {
                                    imageArray.append(image!)
                                }
                            }
                            else {
                                // can be videos, do not care for now.
                            }
                           
                        }
                    }
                }
                completionHandlerGetImages(imageArray, nil)
            }
        }
    }
    
    private func addImageToCoreData(_ longitude: Double?, _ latitude: Double?, _ id: String, _ imageURL: String, _ text: String) -> Image? {
        
        // Add to core data. It is unique ID and image URL
        let request: NSFetchRequest<Image> = Image.fetchRequest()
        let predicateID = NSPredicate(format: "id == %@", id)
        let predicateURL = NSPredicate(format: "imageURL == %@", imageURL)
        
        let predicateCompound = NSCompoundPredicate.init(type: .and, subpredicates: [predicateID,predicateURL])
        request.predicate = predicateCompound
        
        if let result = try? self.coreDataStack?.context.fetch(request) {
            if (result?.first) == nil {
                if (longitude != nil && latitude != nil) {
                    // let's create the image object only if there is location data. That's the purpose of the app.
                    let image = Image(id: id, imageURL: imageURL, imageData: nil, latitude: latitude!, longitude: longitude!, text: text, context: (self.coreDataStack?.context)!)
                    return image
                }
            } else {
                let image = result?.first
                if image?.longitude != longitude || image?.latitude != latitude {
                    
                    image?.longitude = longitude!
                    image?.latitude = latitude!
                    
                    // reset so that we can do reverse geo location later
                    image?.imageToCity = nil
                    image?.imageToCountry = nil
                    
                    return image
                }
            }
        }
        return nil
    }
}
