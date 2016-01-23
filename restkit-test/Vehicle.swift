//
//  Vehicle.swift
//  restkit-test
//
//  Created by fixd on 1/22/16.
//  Copyright © 2016 fixd. All rights reserved.
//

import Foundation
import RestKit


class Vehicle: NSManagedObject, Model {

    static var pathPattern = "/vehicles"
    
    // create an RKEntityMapping for yourself, mapping keys and values and setting id and relationships if neccessary
    static var entityMapping: RKEntityMapping {
        let mapping = RKEntityMapping(forEntityForName: "Vehicle", inManagedObjectStore: RKManagedObjectStore.defaultStore())
        mapping.addAttributeMappingsFromDictionary([
            "vin": "vin",
            "user_submitted": "userSubmitted",
            "created_at": "createdAt",
            "updated_at": "updatedAt"
            ])
        mapping.identificationAttributes = ["vin"]
        mapping.addPropertyMapping(RKRelationshipMapping(fromKeyPath: "make_model_year", toKeyPath: "makeModelYear", withMapping: MakeModelYear.entityMapping))
        mapping.addPropertyMapping(RKRelationshipMapping(fromKeyPath: "users", toKeyPath: "users", withMapping: User.entityMapping))
        return mapping
    }

}

extension Vehicle {
    
    @NSManaged var vin: String?
    @NSManaged var userSubmitted: NSNumber?
    @NSManaged var users: NSSet?
    @NSManaged var pulls: NSSet?
    @NSManaged var mileages: NSSet?
    @NSManaged var makeModelYear: MakeModelYear?
    
}
