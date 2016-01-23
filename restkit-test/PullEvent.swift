//
//  PullEvent.swift
//  restkit-test
//
//  Created by fixd on 1/22/16.
//  Copyright © 2016 fixd. All rights reserved.
//

import Foundation
import CoreData


class PullEvent: NSManagedObject {

// Insert code here to add functionality to your managed object subclass

}

extension PullEvent {
    
    @NSManaged var id: NSNumber?
    @NSManaged var celOn: NSNumber?
    @NSManaged var pullTime: NSDate?
    @NSManaged var obdProtocol: String?
    @NSManaged var background: NSNumber?
    @NSManaged var vehicle: Vehicle?
    @NSManaged var dtcs: NSSet?
    @NSManaged var user: NSManagedObject?
    
}