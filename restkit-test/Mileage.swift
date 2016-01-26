//
//  Mileage.swift
//  restkit-test
//
//  Created by fixd on 1/22/16.
//  Copyright © 2016 fixd. All rights reserved.
//

import Foundation
import RestKit


class Mileage: NSManagedObject {
    
//    static var indexPathPatterns = ["mileages", "vehicles/:vin/mileages"]
//    
//    static var mappings: [NSObject: AnyObject]! = [
//        "id": "id",
//        // 'value' conflicts with NSMangedObject
//        "value": "miles",
//        "timestamp": "timestamp",
//        // using field source_ as string field, source as backed by enum
//        "source": "source_",
//        "vehicle_vin": "vin",
//        "created_at": "createdAt",
//        "updated_at": "updatedAt"
//    ]
    
    enum Source: String {
        case Unknown = "unknown"
        case UserSubmitted = "user_submitted"
        case MilesWithMIL = "miles_since_mil"
        case MilesSinceClear = "miles_since_cleared"
    }
    
    var source: Source {
        get {
            if let s = self.source_, let ss = Source(rawValue: s) {
                return ss
            }else{
                return .Unknown
            }
        }
        set {
            self.source_ = newValue.rawValue
        }
    }

//    static var pathPatterns = ["mileages", "mileages/:id", "vehicles/:vin/mileages"]
    
    // create an RKEntityMapping for yourself, mapping keys and values and setting id and relationships if neccessary
//    static var entityMapping: RKEntityMapping {
//        let mapping = RKEntityMapping(forEntityForName: "Mileage", inManagedObjectStore: RKManagedObjectStore.defaultStore())
//        mapping.addAttributeMappingsFromDictionary(mappings)
//        mapping.identificationAttributes = ["id"]
//        
//        // when only an ID for another object is returned, you need to add a transient attribute in core data, add a mapping for the field as well, and then call addConnectionForRelationship
//        mapping.addConnectionForRelationship("vehicle", connectedBy: ["vin": "vin"])
//        return mapping
//    }
    
//    static var dictionaryMapping: RKObjectMapping {
//        return defaultDictionaryMapping()
//    }
//    
//    static var routeSet: [RKRoute!] {
//        return defaultRouteSet("mileages")
//    }
    
    
//    static var routeSet = [
////        RKRoute(withClass: Mileage.self, pathPattern: "mileages", method: .GET), //index
////        RKRoute(relationshipName: <#T##String!#>, objectClass: <#T##AnyClass!#>, pathPattern: "vehicles/:vin/mileages", method: .GET)
//        RKRoute(withClass: Mileage.self, pathPattern: "mileages/:id", method: .GET), //show
//        RKRoute(withClass: Mileage.self, pathPattern: "mileages/:id", method: .PUT), //update
//        RKRoute(withClass: Mileage.self, pathPattern: "mileages/:id", method: .DELETE), //delete
//        RKRoute(withClass: Mileage.self, pathPattern: "mileages", method: .POST) //create
//    ]
    
    static let model = MileageModel()
}

class MileageModel: Model {
    
    private init(){
        super.init(type: Mileage.self,entityName: "Mileage", resourceName: "mileages", indexPaths: ["mileages", "vehicles/:vin/mileages"], paramMappings: [
            "id": "id",
            // 'value' conflicts with NSMangedObject
            "value": "miles",
            "timestamp": "timestamp",
            // using field source_ as string field, source as backed by enum
            "source": "source_",
            "vehicle_vin": "vin",
            "created_at": "createdAt",
            "updated_at": "updatedAt"
            ])
        
    }
    
    override func addRelationships(mapping: RKEntityMapping) {
        mapping.addConnectionForRelationship("vehicle", connectedBy: ["vin": "vin"])
    }
}

extension Mileage {
    
    @NSManaged var id: NSNumber?
    @NSManaged var miles: NSNumber?
    @NSManaged var timestamp: NSDate?
    @NSManaged var source_: String?
    @NSManaged var vehicle: Vehicle?
    @NSManaged var user: NSManagedObject?
    
}
