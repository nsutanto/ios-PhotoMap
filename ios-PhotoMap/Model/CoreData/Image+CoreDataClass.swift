//
//  Image+CoreDataClass.swift
//  ios-PhotoMap
//
//  Created by Nicholas Sutanto on 11/3/17.
//  Copyright © 2017 Nicholas Sutanto. All rights reserved.
//
//

import Foundation
import CoreData


public class Image: NSManagedObject {
    convenience init(id: String, imageURL: String, imageData: NSData?, latitude: Double, longitude: Double, text: String, context: NSManagedObjectContext) {
        
        // An EntityDescription is an object that has access to all
        // the information you provided in the Entity part of the model
        // you need it to create an instance of this class.
        if let ent = NSEntityDescription.entity(forEntityName: "Image", in: context) {
            self.init(entity: ent, insertInto: context)
            self.id = id
            self.imageURL = imageURL
            self.imageData = imageData
            self.latitude = latitude
            self.longitude = longitude
            self.text = text
        } else {
            fatalError("Unable to find Image entity name!")
        }
    }
}
