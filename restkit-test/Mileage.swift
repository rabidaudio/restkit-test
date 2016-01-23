//
//  Mileage.swift
//  restkit-test
//
//  Created by fixd on 1/22/16.
//  Copyright © 2016 fixd. All rights reserved.
//

import Foundation
import CoreData


class Mileage: NSManagedObject {

// Insert code here to add functionality to your managed object subclass

}

extension Mileage {
    
    @NSManaged var id: NSNumber?
    @NSManaged var value: NSNumber?
    @NSManaged var timestamp: NSDate?
    @NSManaged var source: String?
    @NSManaged var vehicle: Vehicle?
    @NSManaged var user: NSManagedObject?
    
}
