//
//  ClientUtil.swift
//  ios-PhotoMap
//
//  Created by Nicholas Sutanto on 10/26/17.
//  Copyright © 2017 Nicholas Sutanto. All rights reserved.
//

import Foundation

class InstagramClient {
    
    class func sharedInstance() -> InstagramClient {
        struct Singleton {
            static var sharedInstance = InstagramClient()
        }
        return Singleton.sharedInstance
    }
}
