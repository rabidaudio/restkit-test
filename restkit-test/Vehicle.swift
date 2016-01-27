//
//  Vehicle.swift
//  restkit-test
//
//  Created by fixd on 1/22/16.
//  Copyright © 2016 fixd. All rights reserved.
//

import Foundation
import CoreData

class VehicleModel: Model {
    
    init(){
        super.init(type: Vehicle.self, idAttributes: ["vin"], params: ["vin", "userSubmitted", "createdAt", "updatedAt"])
        self.addIncludedMapping(MakeModelYearModel(), toMany: false)
        self.addIncludedMapping(UserModel(), toMany: true)
    }
}

class Vehicle: NSManagedObject {
    
}

extension Vehicle {
    
    @NSManaged var vin: String?
    @NSManaged var userSubmitted: NSNumber?
    @NSManaged var users: NSSet?
    @NSManaged var pulls: NSSet?
    @NSManaged var mileages: NSSet?
    @NSManaged var makeModelYear: MakeModelYear?
    
}
