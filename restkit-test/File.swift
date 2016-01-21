//
//  File.swift
//  restkit-test
//
//  Created by fixd on 1/21/16.
//  Copyright © 2016 fixd. All rights reserved.
//

import Foundation
import CoreData


class File: NSManagedObject {
    
//    static var attributeMappings: [NSObject : AnyObject] = [
//        "id": "gistId",
//        "url": "jsonUrl",
//        "description": "descriptionText",
//        "public": "isPublic",
//        "created_at": "createdAt"
//    ]
//    
//    static var idParamName = "gistId"
//    
//    static var pathPattern = "/gists/public"
//    
//    static var name = "Gist"

}

extension File {
    
    @NSManaged var filename: String?
    @NSManaged var rawUrl: NSObject?
    @NSManaged var size: NSNumber?
    @NSManaged var gist: Gist?
    
}
