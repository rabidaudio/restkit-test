//
//  AppDelegate.swift
//  restkit-test
//
//  Created by fixd on 1/20/16.
//  Copyright © 2016 fixd. All rights reserved.
//

import UIKit
import CoreData
import RestKit
import PromiseKit
import AFNetworking

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    let models: [Model.Type] = [
        MakeModelYear.self,
        Vehicle.self,
        Mileage.self,
//        PullEvent.self,
//        Dtc.self,
        User.self
    ]
    
    // make context globally accessable
    static func context() -> NSManagedObjectContext {
        return RKManagedObjectStore.defaultStore().mainQueueManagedObjectContext // persistentStoreManagedObjectContext <-- use this for off-thread
    }

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        RKLogConfigureFromEnvironment()
        
        let objectManager = RKObjectManager(baseURL: NSURL(string: "http://localhost:3000/api/v2/"))
        let managedObjectModel = NSManagedObjectModel.mergedModelFromBundles(nil)
        
        let managedObjectStore = RKManagedObjectStore(managedObjectModel: managedObjectModel)
        
        // add the sqlite database
        let dbPath = RKApplicationDataDirectory().stringByAppendingString("/DataStore.sqlite")
        try! managedObjectStore.addSQLitePersistentStoreAtPath(dbPath, fromSeedDatabaseAtPath: nil, withConfiguration: nil, options: nil)
        
//        managedObjectStore.managedObjectCache = custom
        
        // TODO include valid and error response descriptors
//        objectManager.addResponseDescriptorsFromArray(<#T##responseDescriptors: [AnyObject]!##[AnyObject]!#>)
        
        managedObjectStore.createManagedObjectContexts()
        // make these these globally accessable
        objectManager.managedObjectStore = managedObjectStore
        RKManagedObjectStore.setDefaultStore(managedObjectStore)
        RKObjectManager.setSharedManager(objectManager)
        
        //show loading at top
        AFNetworkActivityIndicatorManager.sharedManager().enabled = true
        
        objectManager.requestSerializationMIMEType = RKMIMETypeJSON
        
        for model in models {
            for pattern in model.pathPatterns {
//                let requestDescriptor = RKRequestDescriptor(mapping: model.entityMapping, objectClass: (model as! AnyClass), rootKeyPath: "data", method: .Any)
                let responseDescriptor = RKResponseDescriptor(mapping: model.entityMapping, method: .Any, pathPattern: pattern, keyPath: "data", statusCodes: RKStatusCodeIndexSetForClass(.Successful))
//                objectManager.addRequestDescriptor(requestDescriptor)
                objectManager.addResponseDescriptor(responseDescriptor)
            }
        }
//        let loginMapping = RKObjectMapping(forClass: NSMutableDictionary.self)
//        loginMapping.addAttributeMappingsFromDictionary(["authentication_token": "authToken"])
////        loginMapping.addRelationshipMappingWithSourceKeyPath(nil, mapping: User.entityMapping)
//        let loginResponseDescriptor = RKResponseDescriptor(mapping: loginMapping, method: .Any, pathPattern: "users/current", keyPath: "data", statusCodes: RKStatusCodeIndexSetForClass(.Successful))
//        objectManager.addResponseDescriptor(loginResponseDescriptor)
        //objectManager.addResponseDescriptor(User.loginResponseDescriptor)
        
        //add pagination 
        let paginationMapping = RKObjectMapping(forClass: RKPaginator.self)
        paginationMapping.addAttributeMappingsFromDictionary([
            "pagination.current_page": "currentPage",
            "pagination.total_pages": "pageCount",
            "pagination.per_page": "perPage",
            "pagination.total_entries": "objectCount"
        ])
        objectManager.paginationMapping = paginationMapping
        
        //add mapping for status
        let statusMapping = RKObjectMapping(forClass: NSMutableDictionary.self)
        statusMapping.addAttributeMappingsFromDictionary(["version":"version", "current_user": "currentUser"])
        let statusResponseDescriptor = RKResponseDescriptor(mapping: statusMapping, method: .GET, pathPattern: "", keyPath: "data", statusCodes: RKStatusCodeIndexSetForClass(.Successful))
        objectManager.addResponseDescriptor(statusResponseDescriptor)
        
        objectManager.HTTPClient.setDefaultHeader("X-User-Email", value: User.lastUserEmail)
        objectManager.HTTPClient.setDefaultHeader("X-User-Token", value: User.lastUserToken)
        
        return true
    }
}
