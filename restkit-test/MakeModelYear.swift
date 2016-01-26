//
//  MakeModelYear.swift
//  restkit-test
//
//  Created by fixd on 1/22/16.
//  Copyright © 2016 fixd. All rights reserved.
//

import Foundation
import RestKit

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
    
//    static var name = "MakeModelYear"
//    static var pathPatterns = ["make_model_years", "make_model_years/:id"]
    
//    static var indexPathPatterns = ["make_model_years"]
//    
//    static var mappings: [NSObject: AnyObject]! = [
//        "id": "id",
//        "make": "make",
//        "model": "model",
//        "year": "year",
//        "body_type": "bodyType",
//        "edmunds_id": "edmundsId",
//        "created_at": "createdAt",
//        "updated_at": "updatedAt"
//    ]
//    
//    // create an RKEntityMapping for yourself, mapping keys and values and setting id and relationships if neccessary
//    static var entityMapping: RKEntityMapping {
//        return defaultEntityMapping("MakeModelYear")
//    }
//    
//    static var dictionaryMapping: RKObjectMapping {
//        return defaultDictionaryMapping()
//    }
    
    
//    static var routeSet = [
////        RKRoute(withClass: MakeModelYear.self, pathPattern: "make_model_years", method: .GET), //index
//        //        RKRoute(relationshipName: <#T##String!#>, objectClass: <#T##AnyClass!#>, pathPattern: "vehicles/:vin/mileages", method: .GET)
//        RKRoute(withClass: MakeModelYear.self, pathPattern: "make_model_years/:id", method: .GET), //show
//        RKRoute(withClass: MakeModelYear.self, pathPattern: "make_model_years/:id", method: .PUT), //update
//        RKRoute(withClass: MakeModelYear.self, pathPattern: "make_model_years/:id", method: .DELETE), //delete
//        RKRoute(withClass: MakeModelYear.self, pathPattern: "make_model_years", method: .POST) //create
//    ]
    
//    static var idAttributeName = "id"
//    static var attributeMappings :[NSObject:AnyObject] = [
//        "id": "id",
//        "make": "make",
//        "model": "model",
//        
//    ]
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