//
//  UserInfo+CoreDataProperties.swift
//  ios-PhotoMap
//
//  Created by Nicholas Sutanto on 11/3/17.
//  Copyright © 2017 Nicholas Sutanto. All rights reserved.
//
//

import Foundation
import CoreData


extension UserInfo {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<UserInfo> {
        return NSFetchRequest<UserInfo>(entityName: "UserInfo")
    }

    @NSManaged public var fullName: String?
    @NSManaged public var profilePictureData: NSData?
    @NSManaged public var profilePictureURL: String?
    @NSManaged public var userName: String?
    @NSManaged public var userInfoToImage: NSSet?

}

// MARK: Generated accessors for userInfoToImage
extension UserInfo {

    @objc(addUserInfoToImageObject:)
    @NSManaged public func addToUserInfoToImage(_ value: Image)

    @objc(removeUserInfoToImageObject:)
    @NSManaged public func removeFromUserInfoToImage(_ value: Image)

    @objc(addUserInfoToImage:)
    @NSManaged public func addToUserInfoToImage(_ values: NSSet)

    @objc(removeUserInfoToImage:)
    @NSManaged public func removeFromUserInfoToImage(_ values: NSSet)

}
