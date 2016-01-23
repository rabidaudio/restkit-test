//
//  Dtc.swift
//  restkit-test
//
//  Created by fixd on 1/22/16.
//  Copyright © 2016 fixd. All rights reserved.
//

import Foundation
import CoreData


class Dtc: NSManagedObject {

// Insert code here to add functionality to your managed object subclass

}

extension Dtc {
    
    @NSManaged var code: String?
    @NSManaged var shortName: String?
    @NSManaged var threatLevel: NSNumber?
    @NSManaged var consequences: String?
    @NSManaged var additionalDetails: String?
    @NSManaged var extremeCase: String?
    @NSManaged var reserved: NSNumber?
    @NSManaged var manufacturer: NSNumber?
    @NSManaged var pulls: NSSet?
    
}