//
//  CityEntity+CoreDataClass.swift
//  ios-PhotoMap
//
//  Created by Nicholas Sutanto on 11/3/17.
//  Copyright © 2017 Nicholas Sutanto. All rights reserved.
//
//

import Foundation
import CoreData


public class CityEntity: NSManagedObject {

    convenience init(city: String, state: String, context: NSManagedObjectContext) {
        
        // An EntityDescription is an object that has access to all
        // the information you provided in the Entity part of the model
        // you need it to create an instance of this class.
        if let ent = NSEntityDescription.entity(forEntityName: "CityEntity", in: context) {
            self.init(entity: ent, insertInto: context)
            self.city = city
            self.state = state
        } else {
            fatalError("Unable to find City entity name!")
        }
    }
}
