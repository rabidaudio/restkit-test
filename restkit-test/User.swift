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

class UserModel: Model {
    
    private init(){
        super.init(type: User.self, entityName: "User", resourceName: "users", paramMappings: [
            "id": "id",
            "first_name": "firstName",
            "last_name": "lastName",
            "email": "email",
            // it pains me to no end to persist authTokens in the database.
            //   However, trying to fight RestKit on this is basically impossible.
            //   So instead we clear the User's auth token at log out, so there's only
            //   ever at most one token in the database
            "authentication_token": "authToken",
            "created_at": "createdAt",
            "updated_at": "updatedAt"
            ])
    }
}

class User: NSManagedObject {
    
    static let model = UserModel()
    
}

extension User {
    
    @NSManaged var id: NSNumber?
    @NSManaged var email: String?
    @NSManaged var authToken: String?
    @NSManaged var firstName: String?
    @NSManaged var lastName: String?
    @NSManaged var vehicles: NSSet?
    @NSManaged var mileages: NSSet?
    @NSManaged var pulls: NSSet?
    
}