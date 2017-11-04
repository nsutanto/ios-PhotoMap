//
//  CityEntity+CoreDataProperties.swift
//  ios-PhotoMap
//
//  Created by Nicholas Sutanto on 11/3/17.
//  Copyright © 2017 Nicholas Sutanto. All rights reserved.
//
//

import Foundation
import CoreData


extension CityEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CityEntity> {
        return NSFetchRequest<CityEntity>(entityName: "CityEntity")
    }

    @NSManaged public var city: String?
    @NSManaged public var cityToUserInfo: UserInfo?
    @NSManaged public var cityToImage: NSSet?

}

// MARK: Generated accessors for cityToImage
extension CityEntity {

    @objc(addCityToImageObject:)
    @NSManaged public func addToCityToImage(_ value: Image)

    @objc(removeCityToImageObject:)
    @NSManaged public func removeFromCityToImage(_ value: Image)

    @objc(addCityToImage:)
    @NSManaged public func addToCityToImage(_ values: NSSet)

    @objc(removeCityToImage:)
    @NSManaged public func removeFromCityToImage(_ values: NSSet)

}
