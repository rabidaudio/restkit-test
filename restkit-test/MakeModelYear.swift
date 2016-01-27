//
//  MakeModelYear.swift
//  restkit-test
//
//  Created by fixd on 1/22/16.
//  Copyright © 2016 fixd. All rights reserved.
//

import Foundation
import CoreData

class MakeModelYearModel: Model {
    
    init(){
        super.init(type: MakeModelYear.self, params: ["id", "make", "model", "year", "bodyType", "edmundsId", "createdAt", "updatedAt"])
    }
}

class MakeModelYear: NSManagedObject {
    
}

extension MakeModelYear {
    
    @NSManaged var id: NSNumber?
    @NSManaged var make: String?
    @NSManaged var model: String?
    @NSManaged var year: NSNumber?
    @NSManaged var bodyType: String?
    @NSManaged var edmundsId: NSNumber?
    @NSManaged var vehicles: NSSet?
    
}