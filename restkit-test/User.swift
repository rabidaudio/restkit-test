//
//  User.swift
//  restkit-test
//
//  Created by fixd on 1/21/16.
//  Copyright © 2016 fixd. All rights reserved.
//

import Foundation
import CoreData


class User: NSManagedObject {
    
//    static var attributeMappings: [NSObject : AnyObject] = [
//        "id": "gistId",
//        "url": "jsonUrl",
//        "description": "descriptionText",
//        "public": "isPublic",
//        "created_at": "createdAt"
//    ]
//    
//    static var idParamName = "userId"
//    
//    static var pathPattern = "/gists/public"
//    
//    static var name = "User"

}

extension User {
    
    @NSManaged var avatarUrl: NSObject?
    @NSManaged var gravatarId: String?
    @NSManaged var jsonUrl: NSObject?
    @NSManaged var login: String?
    @NSManaged var userId: NSNumber?
    @NSManaged var gists: NSSet?
    
}