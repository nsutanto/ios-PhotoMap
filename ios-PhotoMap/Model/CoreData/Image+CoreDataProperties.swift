//
//  Image+CoreDataProperties.swift
//  ios-PhotoMap
//
//  Created by Nicholas Sutanto on 11/3/17.
//  Copyright © 2017 Nicholas Sutanto. All rights reserved.
//
//

import Foundation
import CoreData


extension Image {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Image> {
        return NSFetchRequest<Image>(entityName: "Image")
    }

    @NSManaged public var city: String?
    @NSManaged public var country: String?
    @NSManaged public var id: String?
    @NSManaged public var imageData: NSData?
    @NSManaged public var imageURL: String?
    @NSManaged public var latitude: Double
    @NSManaged public var longitude: Double
    @NSManaged public var text: String?
    @NSManaged public var imageToUserInfo: UserInfo?

}
