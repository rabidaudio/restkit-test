//
//  Mileage.swift
//  restkit-test
//
//  Created by fixd on 1/22/16.
//  Copyright © 2016 fixd. All rights reserved.
//

import Foundation
import RestKit

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

class Mileage: NSManagedObject {
    
    static let model = MileageModel()
    
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
}

extension Mileage {
    
    @NSManaged var id: NSNumber?
    @NSManaged var miles: NSNumber?
    @NSManaged var timestamp: NSDate?
    @NSManaged var source_: String?
    @NSManaged var vehicle: Vehicle?
    @NSManaged var user: NSManagedObject?
    
}
