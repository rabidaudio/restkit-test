//
//  User.swift
//  restkit-test
//
//  Created by fixd on 1/22/16.
//  Copyright © 2016 fixd. All rights reserved.
//

import Foundation
import RestKit


class User: NSManagedObject, Model {

    
    static var pathPatterns = ["users", "users/:id"]
    
    // create an RKEntityMapping for yourself, mapping keys and values and setting id and relationships if neccessary
    static var entityMapping: RKEntityMapping {
        let mapping = RKEntityMapping(forEntityForName: "User", inManagedObjectStore: RKManagedObjectStore.defaultStore())
        mapping.addAttributeMappingsFromDictionary([
            "id": "id",
            "email": "email",
            "first_name": "firstName",
            "last_name": "lastName",
            "authentication_token": "authToken",
            "created_at": "createdAt",
            "updated_at": "updatedAt"
            ])
        mapping.identificationAttributes = ["id"]
        return mapping
    }

}

extension User {
    
    @NSManaged var id: NSNumber?
    @NSManaged var email: String?
    @NSManaged var firstName: String?
    @NSManaged var lastName: String?
    @NSManaged var authToken: String?
    @NSManaged var vehicles: NSSet?
    @NSManaged var mileages: NSSet?
    @NSManaged var pulls: NSSet?
    
}