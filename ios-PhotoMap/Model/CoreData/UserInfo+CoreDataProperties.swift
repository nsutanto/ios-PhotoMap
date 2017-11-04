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
    @NSManaged public var userInfoToCity: NSSet?
    @NSManaged public var userInfoToCountry: NSSet?

}

// MARK: Generated accessors for userInfoToCity
extension UserInfo {

    @objc(addUserInfoToCityObject:)
    @NSManaged public func addToUserInfoToCity(_ value: CityEntity)

    @objc(removeUserInfoToCityObject:)
    @NSManaged public func removeFromUserInfoToCity(_ value: CityEntity)

    @objc(addUserInfoToCity:)
    @NSManaged public func addToUserInfoToCity(_ values: NSSet)

    @objc(removeUserInfoToCity:)
    @NSManaged public func removeFromUserInfoToCity(_ values: NSSet)

}

// MARK: Generated accessors for userInfoToCountry
extension UserInfo {

    @objc(addUserInfoToCountryObject:)
    @NSManaged public func addToUserInfoToCountry(_ value: CountryEntity)

    @objc(removeUserInfoToCountryObject:)
    @NSManaged public func removeFromUserInfoToCountry(_ value: CountryEntity)

    @objc(addUserInfoToCountry:)
    @NSManaged public func addToUserInfoToCountry(_ values: NSSet)

    @objc(removeUserInfoToCountry:)
    @NSManaged public func removeFromUserInfoToCountry(_ values: NSSet)

}
