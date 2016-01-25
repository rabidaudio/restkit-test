//
//  User.swift
//  restkit-test
//
//  Created by fixd on 1/22/16.
//  Copyright © 2016 fixd. All rights reserved.
//

import Foundation
import RestKit
import PromiseKit

class User: NSManagedObject, Model {
    
    static var pathPatterns = ["users", "users/:id", "users/current"]
    
    static var entityMapping: RKEntityMapping {
        let mapping = RKEntityMapping(forEntityForName: "User", inManagedObjectStore: RKManagedObjectStore.defaultStore())
        mapping.addAttributeMappingsFromDictionary([
            "id": "id",
            "first_name": "firstName",
            "last_name": "lastName",
            "email": "email",
            "authentication_token": "authToken",
            "created_at": "createdAt",
            "updated_at": "updatedAt"
        ])
        mapping.identificationAttributes = ["id"]
        
//        let loginMapping = RKObjectMapping(forClass: NSMutableDictionary.self)
//        loginMapping.addAttributeMappingsFromDictionary(["authentication_token":"authToken"])
        
//        mapping.addRelationshipMappingWithSourceKeyPath(<#T##sourceKeyPath: String!##String!#>, mapping: <#T##RKMapping!#>)
//        mapping.addRelationshipMappingWithSourceKeyPath("authentication_token", mapping: <#T##RKMapping!#>)
        
//        let loginMapping = RKObjectMapping(forClass: NSMutableDictionary.self)
//        loginMapping.addAttributeMappingsFromDictionary(["authentication_token": "authToken"])
//        mapping.addPropertyMapping(RKRelationshipMapping(fromKeyPath: nil, toKeyPath: "authToken", withMapping: loginMapping))
//        mapping.addRelationshipMappingWithSourceKeyPath(nil, mapping: User.entityMapping)
//        let loginResponseDescriptor = RKResponseDescriptor(mapping: loginMapping, method: .Any, pathPattern: "users/current", keyPath: "data", statusCodes: RKStatusCodeIndexSetForClass(.Successful))
//        objectManager.addResponseDescriptor(loginResponseDescriptor)
        
        return mapping
    }
    
    
    //note: authToken is not persisted to database
//    private var _authToken: String?
//    var authToken: String? {
//        get {
//            willAccessValueForKey("authToken")
////            let  t = primitiveValueForKey("authToken") as! String?
//            didAccessValueForKey("authToken")
//            return _authToken
//        }
//        set {
//            willChangeValueForKey("authToken")
////            setPrimitiveValue(newValue, forKey: "authToken")
//            _authToken = newValue
//            didChangeValueForKey("authToken")
//        }
//    }
    
}

extension User {
    
    @NSManaged var id: NSNumber?
    @NSManaged var email: String?
    // it pains me to no end to persist authTokens in the database.
    //   However, trying to fight RestKit on this is basically impossible.
    //   So instead we clear the User's auth token at log out, so there's only
    //   ever at most one token in the database (which is basically the same
    //   as using userDefaults)
    @NSManaged var authToken: String?
    @NSManaged var firstName: String?
    @NSManaged var lastName: String?
    @NSManaged var vehicles: NSSet?
    @NSManaged var mileages: NSSet?
    @NSManaged var pulls: NSSet?
    
}