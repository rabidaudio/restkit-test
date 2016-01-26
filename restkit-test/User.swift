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
    
//    static var pathPatterns = ["users", "users/:id", "users/current"]
    
    static var mappings: [NSObject: AnyObject]! = [
        "id": "id",
        "first_name": "firstName",
        "last_name": "lastName",
        "email": "email",
        "authentication_token": "authToken",
        "created_at": "createdAt",
        "updated_at": "updatedAt"
    ]
    
    static var entityMapping: RKEntityMapping {
        return defaultEntityMapping("User")
    }
    
    static var dictionaryMapping: RKObjectMapping {
        return defaultDictionaryMapping()
    }
    
    static var routeSet = [
//        RKRoute(withClass: User.self, pathPattern: "users", method: .GET), //index
        //        RKRoute(relationshipName: <#T##String!#>, objectClass: <#T##AnyClass!#>, pathPattern: "vehicles/:vin/mileages", method: .GET)
        RKRoute(withClass: User.self, pathPattern: "users/:id", method: .GET), //show
        RKRoute(withClass: User.self, pathPattern: "users/:id", method: .PUT), //update
        RKRoute(withClass: User.self, pathPattern: "users/:id", method: .DELETE), //delete
        RKRoute(withClass: User.self, pathPattern: "users", method: .POST) //create
    ]
    
    static var indexPathPatterns = ["users"]
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