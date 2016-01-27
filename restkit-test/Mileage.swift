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
    
    init(){
        super.init(type: Mileage.self, resourceName: "mileages", indexPaths: ["mileages", "vehicles/:vin/mileages"], paramMappings: [
            "id": "id",
            "value": "miles",          // 'value' conflicts with NSMangedObject
            "timestamp": "timestamp",
            "source": "source",
            "vehicle_vin": "vehicleVin",
            "created_at": "createdAt",
            "updated_at": "updatedAt"
            ])
        self.addIDMapping(VehicleModel(), onKey: "vehicleVin")
        self.addIncludedMapping(UserModel(), toMany: false)
    }
    
}

class Mileage: NSManagedObject {
    
    static let model = FixdApi.getModel("Mileage")
    
    enum Source: String {
        case Unknown = "unknown"
        case UserSubmitted = "user_submitted"
        case MilesWithMIL = "miles_since_mil"
        case MilesSinceClear = "miles_since_cleared"
    }
    
//    var source: Source {
//        get {
//            if let s = self.source_, let ss = Source(rawValue: s) {
//                return ss
//            }else{
//                return .Unknown
//            }
//        }
//        set {
//            self.source_ = newValue.rawValue
//        }
//    }
}

extension Mileage {
    
    @NSManaged var id: NSNumber?
    @NSManaged var miles: NSNumber?
    @NSManaged var timestamp: NSDate?
    @NSManaged var source: String?
    @NSManaged var vehicle: Vehicle?
    @NSManaged var user: NSManagedObject?
    
}
