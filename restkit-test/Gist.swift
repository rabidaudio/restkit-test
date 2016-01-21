//
//  Gist.swift
//  restkit-test
//
//  Created by fixd on 1/20/16.
//  Copyright © 2016 fixd. All rights reserved.
//

import Foundation
import RestKit

class Gist : NSManagedObject, Model {
    
//    static var map: [NSObject : AnyObject] = [
//        "id": "gistId",
//        "url": "jsonUrl",
//        "description": "descriptionText",
//        "public": "isPublic",
//        "created_at": "createdAt"
//    ]
//    static var idParamName: String = "gistId"
    
//    static var descriptor = RKResponseDescriptor(mapping: RKEntityMapping(forClass: Gist.self), pathPattern: "/gists/public", keyPath: nil, statusCodes: RKStatusCodeIndexSetForClass(.Successful))
    
    static var attributeMappings: [NSObject : AnyObject] = [
        "id": "gistId",
        "url": "jsonUrl",
        "description": "descriptionText",
        "public": "isPublic",
        "created_at": "createdAt"
    ]
    
    static var idParamName = "gistId"
    
    static var pathPattern = "/gists/public"
    
    static var name = "Gist"
    
    
    @NSManaged var gistId: Int
    @NSManaged var url: NSURL
    @NSManaged var htmlUrl: NSURL
    @NSManaged var descriptionText: String
    @NSManaged var isPublic: Bool
    @NSManaged var created At: NSDate
    @NSManaged var updatedAt: NSDate
    @NSManaged var files: [File]
    @NSManaged var user: User
    
    private let formatter = NSDateFormatter()
    
    func titleText() -> String {
        let size = descriptionText.startIndex.distanceTo(descriptionText.endIndex)
        let maxSize = 20
        return (size < maxSize ? descriptionText : descriptionText.substringToIndex(descriptionText.startIndex.advancedBy(maxSize)))
    }
    
    func subtitleText() -> String {
        return "by \(user.login) at \(formatter.stringFromDate(createdAt)) (\(files.count) files)"
    }
    

}