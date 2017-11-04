//
//  CountryEntity+CoreDataClass.swift
//  ios-PhotoMap
//
//  Created by Nicholas Sutanto on 11/3/17.
//  Copyright © 2017 Nicholas Sutanto. All rights reserved.
//
//

import Foundation
import CoreData


public class CountryEntity: NSManagedObject {
    convenience init(country: String, context: NSManagedObjectContext) {
        
        // An EntityDescription is an object that has access to all
        // the information you provided in the Entity part of the model
        // you need it to create an instance of this class.
        if let ent = NSEntityDescription.entity(forEntityName: "CountryEntity", in: context) {
            self.init(entity: ent, insertInto: context)
            self.country = country
        } else {
            fatalError("Unable to find Country entity name!")
        }
    }
}
