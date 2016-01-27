//
//  FixdApi.swift
//  restkit-test
//
//  Created by fixd on 1/27/16.
//  Copyright © 2016 fixd. All rights reserved.
//

import Foundation
import RestKit

// this is the initializer and container for all the CoreData/RestKit related stuff
class FixdApi {
    
    private static let instance = FixdApi()
    
    let url = "http://localhost:3000/api/v2/"
    
    private init(){
        RKLogConfigureFromEnvironment()
        
        let objectManager = RKObjectManager(baseURL: NSURL(string: url))
        let managedObjectModel = NSManagedObjectModel.mergedModelFromBundles(nil)
        
        let managedObjectStore = RKManagedObjectStore(managedObjectModel: managedObjectModel)
        
        // add the sqlite database
        let dbPath = RKApplicationDataDirectory().stringByAppendingString("/DataStore.sqlite")
        try! managedObjectStore.addSQLitePersistentStoreAtPath(dbPath, fromSeedDatabaseAtPath: nil, withConfiguration: nil, options: nil)
        
        managedObjectStore.createManagedObjectContexts()
        // make these these globally accessable
        objectManager.managedObjectStore = managedObjectStore
        RKManagedObjectStore.setDefaultStore(managedObjectStore)
        RKObjectManager.setSharedManager(objectManager)
        
        //show loading indicator in top bar
        AFNetworkActivityIndicatorManager.sharedManager().enabled = true
    }
    
    static func setUp() {
        instance._setUp()
    }
    
    private func _setUp(){
        let objectManager = RKObjectManager.sharedManager()
        
        //our API is JSON
        objectManager.requestSerializationMIMEType = RKMIMETypeJSON
        
        // configure models
        let models = [
            MakeModelYearModel(),
            VehicleModel(),
            MileageModel(),
            UserModel()
        ]
        models.forEach { model in model.addToObjectManager(objectManager) }
        
        //add another response for session control
        objectManager.addResponseDescriptor(CurrentUser.loginResponseDescriptor)
        
        //add another response for errors
        for statusCodeSet in [RKStatusCodeIndexSetForClass(.ClientError), RKStatusCodeIndexSetForClass(.ServerError)] {
            let errorMapping = RKObjectMapping(forClass: RKErrorMessage.self)
            //map the details into userInfo (thanks to: http://stackoverflow.com/a/30254286)
            errorMapping.addPropertyMapping(RKAttributeMapping(fromKeyPath: "message", toKeyPath: "errorMessage"))
            errorMapping.addPropertyMapping(RKAttributeMapping(fromKeyPath: nil, toKeyPath: "userInfo"))
            
            let errorDesriptor = RKResponseDescriptor(mapping: errorMapping, method: .Any, pathPattern: nil, keyPath: "error", statusCodes: statusCodeSet)
            objectManager.addResponseDescriptor(errorDesriptor)
        }
        
        
        //add pagination
        let paginationMapping = RKObjectMapping(forClass: RKPaginator.self)
        paginationMapping.addAttributeMappingsFromDictionary([
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
        
        //set current headers
        objectManager.HTTPClient.setDefaultHeader("X-User-Email", value: CurrentUser.lastUserEmail)
        objectManager.HTTPClient.setDefaultHeader("X-User-Token", value: CurrentUser.lastUserToken)
    }
    
    static func mainQueueContext() -> NSManagedObjectContext {
        return RKManagedObjectStore.defaultStore().mainQueueManagedObjectContext
    }
}