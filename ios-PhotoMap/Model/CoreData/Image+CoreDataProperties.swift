//
//  Image+CoreDataProperties.swift
//  ios-PhotoMap
//
//  Created by Nicholas Sutanto on 12/2/17.
//  Copyright © 2017 Nicholas Sutanto. All rights reserved.
//
//

import Foundation
import CoreData


extension Image {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Image> {
        return NSFetchRequest<Image>(entityName: "Image")
    }

    @NSManaged public var id: String?
    @NSManaged public var imageData: NSData?
    @NSManaged public var imageURL: String?
    @NSManaged public var latitude: Double
    @NSManaged public var locationName: String?
    @NSManaged public var longitude: Double
    @NSManaged public var text: String?
    @NSManaged public var createdTime: String?
    @NSManaged public var imageToCity: CityEntity?
    @NSManaged public var imageToCountry: CountryEntity?

}
