//
//  UserInfo+CoreDataClass.swift
//  ios-PhotoMap
//
//  Created by Nicholas Sutanto on 11/3/17.
//  Copyright © 2017 Nicholas Sutanto. All rights reserved.
//
//

import Foundation
import CoreData


public class UserInfo: NSManagedObject {
    
    convenience init(userName: String, fullName: String, profilePictureURL: String, profilePictureData: NSData?, token: String?, context: NSManagedObjectContext) {
        
        // An EntityDescription is an object that has access to all
        // the information you provided in the Entity part of the model
        // you need it to create an instance of this class.
        if let ent = NSEntityDescription.entity(forEntityName: "UserInfo", in: context) {
            self.init(entity: ent, insertInto: context)
            self.userName = userName
            self.fullName = fullName
            self.profilePictureURL = profilePictureURL
            self.profilePictureData = profilePictureData
            self.token = token
        } else {
            fatalError("Unable to find UserInfo entity name!")
        }
    }

}
