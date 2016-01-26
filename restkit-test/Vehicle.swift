//
//  Vehicle.swift
//  restkit-test
//
//  Created by fixd on 1/22/16.
//  Copyright © 2016 fixd. All rights reserved.
//

import Foundation
import CoreData
import RestKit

class VehicleModel: Model {
    
    private init(){
        super.init(type: Vehicle.self, entityName: "Vehicle", resourceName: "vehicles", idAttributes: ["vin"], paramMappings: [
            "vin": "vin",
            "user_submitted": "userSubmitted",
            "created_at": "createdAt",
            "updated_at": "updatedAt"
            ])
    }
    
    override func addRelationships(mapping: RKEntityMapping) {
        mapping.addPropertyMapping(RKRelationshipMapping(fromKeyPath: "make_model_year", toKeyPath: "makeModelYear", withMapping: MakeModelYear.model.entityMapping))
        mapping.addPropertyMapping(RKRelationshipMapping(fromKeyPath: "users", toKeyPath: "users", withMapping: User.model.entityMapping))
    }
}

class Vehicle: NSManagedObject {
    
    static let model = VehicleModel()
    
}

extension Vehicle {
    
    @NSManaged var vin: String?
    @NSManaged var userSubmitted: NSNumber?
    @NSManaged var users: NSSet?
    @NSManaged var pulls: NSSet?
    @NSManaged var mileages: NSSet?
    @NSManaged var makeModelYear: MakeModelYear?
    
}
