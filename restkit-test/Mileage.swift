//
//  Mileage.swift
//  restkit-test
//
//  Created by fixd on 1/22/16.
//  Copyright © 2016 fixd. All rights reserved.
//

import Foundation
import RestKit


class Mileage: NSManagedObject, Model {

    static var pathPatterns = ["mileages", "mileages/:id", "vehicles/:vin/mileages"]
    
    // create an RKEntityMapping for yourself, mapping keys and values and setting id and relationships if neccessary
    static var entityMapping: RKEntityMapping {
        let mapping = RKEntityMapping(forEntityForName: "Mileage", inManagedObjectStore: RKManagedObjectStore.defaultStore())
        mapping.addAttributeMappingsFromDictionary([
            "id": "id",
            // 'value' conflicts with NSMangedObject
            "value": "miles",
            "timestamp": "timestamp",
            "source": "source",
            "created_at": "createdAt",
            "updated_at": "updatedAt"
            ])
        mapping.identificationAttributes = ["id"]
        return mapping
    }
}

extension Mileage {
    
    @NSManaged var id: NSNumber?
    @NSManaged var miles: NSNumber?
    @NSManaged var timestamp: NSDate?
    @NSManaged var source: String?
    @NSManaged var vehicle: Vehicle?
    @NSManaged var user: NSManagedObject?
    
}
