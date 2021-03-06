//
//  CountryEntity+CoreDataProperties.swift
//  ios-PhotoMap
//
//  Created by Nicholas Sutanto on 11/29/17.
//  Copyright © 2017 Nicholas Sutanto. All rights reserved.
//
//

import Foundation
import CoreData


extension CountryEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CountryEntity> {
        return NSFetchRequest<CountryEntity>(entityName: "CountryEntity")
    }

    @NSManaged public var country: String?
    @NSManaged public var longitude: Double
    @NSManaged public var latitude: Double
    @NSManaged public var countryToImage: NSSet?
    @NSManaged public var countryToUserInfo: UserInfo?

}

// MARK: Generated accessors for countryToImage
extension CountryEntity {

    @objc(addCountryToImageObject:)
    @NSManaged public func addToCountryToImage(_ value: Image)

    @objc(removeCountryToImageObject:)
    @NSManaged public func removeFromCountryToImage(_ value: Image)

    @objc(addCountryToImage:)
    @NSManaged public func addToCountryToImage(_ values: NSSet)

    @objc(removeCountryToImage:)
    @NSManaged public func removeFromCountryToImage(_ values: NSSet)

}
