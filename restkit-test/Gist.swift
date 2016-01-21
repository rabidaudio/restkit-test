//
//  Gist.swift
//  restkit-test
//
//  Created by fixd on 1/21/16.
//  Copyright © 2016 fixd. All rights reserved.
//

import Foundation
import CoreData


class Gist: NSManagedObject, Model {

    private let formatter = NSDateFormatter()
    
    var titleText: String {
            get{
                if(descriptionText != nil){
                    let size = descriptionText!.startIndex.distanceTo(descriptionText!.endIndex)
                    let maxSize = 20
                    return (size < maxSize ? descriptionText! : descriptionText!.substringToIndex(descriptionText!.startIndex.advancedBy(maxSize)))
                }else{
                    return ""
                }
            }
    }
    
    var subtitleText: String {
        get {
            if(user != nil && createdAt != nil && files != nil){
                return "by \(user!.login!) at \(formatter.stringFromDate(createdAt!)) (\(files!.count) files)"
            }else{
                return ""
            }
        }
    }
    
    static var attributeMappings: [NSObject : AnyObject] = [
        "id": "gistId",
        "url": "jsonUrl",
        "description": "descriptionText",
        "public": "isPublic",
        "created_at": "createdAt"
    ]
    
    static var idAttributeName = "gistId"
    static var pathPattern = "/gists/public"
    static var name = "Gist"
    static var sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]
}


extension Gist {
    
    @NSManaged var createdAt: NSDate?
    @NSManaged var descriptionText: String?
    @NSManaged var gistId: NSNumber?
    @NSManaged var htmlUrl: NSObject?
    @NSManaged var isPublic: NSNumber?
    @NSManaged var jsonUrl: NSObject?
    @NSManaged var updatedAt: NSDate?
    @NSManaged var files: NSSet?
    @NSManaged var user: User?
}