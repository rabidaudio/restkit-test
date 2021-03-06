//
//  User.swift
//  restkit-test
//
//  Created by fixd on 1/22/16.
//  Copyright © 2016 fixd. All rights reserved.
//

import Foundation
import CoreData
import RestKit

// Note: All session-related code is in UserSessionExtension.swift
class UserModel: Model {
    
    init(){
        // it pains me to no end to persist auth tokens in the database.
        //   However, trying to fight RestKit on this is basically impossible.
        //   So instead we clear the User's auth token at log out, so there's only
        //   ever at most one token in the database
        super.init(type: User.self, params: ["id", "email", "authenticationToken", "createdAt", "updatedAt"])
    }
    
    // include login/logout response descriptor
    override var responseDescriptors: [RKResponseDescriptor] {
        let loginDescriptor = RKResponseDescriptor(mapping: entityMapping, method: .Any, pathPattern: CurrentUser.pathPattern, keyPath: responseKeyPath, statusCodes: Model.successfulCodes)
        var descriptors: [RKResponseDescriptor] = [loginDescriptor]
        descriptors.appendContentsOf(super.responseDescriptors)
        return descriptors
    }
}

class User: NSManagedObject {
    
}

extension User {
    
    @NSManaged var id: NSNumber?
    @NSManaged var email: String?
    @NSManaged var authenticationToken: String?
    @NSManaged var firstName: String?
    @NSManaged var lastName: String?
    @NSManaged var vehicles: NSSet?
    @NSManaged var mileages: NSSet?
    @NSManaged var pulls: NSSet?
    
}