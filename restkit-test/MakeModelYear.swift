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
    
    private init(){
        super.init(type: MakeModelYear.self, entityName: "MakeModelYear", resourceName: "make_model_years", paramMappings: [
            "id": "id",
            "make": "make",
            "model": "model",
            "year": "year",
            "body_type": "bodyType",
            "edmunds_id": "edmundsId",
            "created_at": "createdAt",
            "updated_at": "updatedAt"
            ])
    }
}

class MakeModelYear: NSManagedObject {

    static let model = MakeModelYearModel()
    
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