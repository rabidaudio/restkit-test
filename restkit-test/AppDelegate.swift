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

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    let models: [Model.Type] = [
        MakeModelYear.self,
        Vehicle.self,
//        Mileage.self,
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
        
        let objectManager = RKObjectManager(baseURL: NSURL(string: "https://fixd.herokuapp.com/api/v2/"))
        
//        let modelURL = NSBundle.mainBundle().URLForResource("restkit_test", withExtension: "momd")!
        // create managedObjectModel instance from CoreData
//        let managedObjectModel = NSManagedObjectModel(contentsOfURL: modelURL)!
        //combine all the Core Data models into a NSManagedObjectModel
        let managedObjectModel = NSManagedObjectModel.mergedModelFromBundles(nil)
        
        let managedObjectStore = RKManagedObjectStore(managedObjectModel: managedObjectModel)
        
        // add the sqlite database
        let dbPath = RKApplicationDataDirectory().stringByAppendingString("/DataStore.sqlite")
        try! managedObjectStore.addSQLitePersistentStoreAtPath(dbPath, fromSeedDatabaseAtPath: nil, withConfiguration: nil, options: nil)
        
        // TODO include valid and error response descriptors
//        objectManager.addResponseDescriptorsFromArray(<#T##responseDescriptors: [AnyObject]!##[AnyObject]!#>)
        
        managedObjectStore.createManagedObjectContexts()
        // make these these globally accessable
        objectManager.managedObjectStore = managedObjectStore
        RKManagedObjectStore.setDefaultStore(managedObjectStore)
        RKObjectManager.setSharedManager(objectManager)
        
        //show loading at top
        AFNetworkActivityIndicatorManager.sharedManager().enabled = true
        
        objectManager.HTTPClient.setDefaultHeader("X-User-Email", value: "julian@fixdapp.com")
        objectManager.HTTPClient.setDefaultHeader("X-User-Token", value: "kvaa2sh21zuBABFZrdw1")
        
        
        for model in models {
            // todo figure out model.pathPattern
            let descriptor = RKResponseDescriptor(mapping: model.entityMapping, method: .Any, pathPattern: model.pathPattern, keyPath: "data", statusCodes: RKStatusCodeIndexSetForClass(.Successful))
            objectManager.addResponseDescriptor(descriptor)
        }
        
//        let context = managedObjectStore.mainQueueManagedObjectContext
        
        // use RKTransformer instead
//        RKEntityMapping.addDefaultDateFormatterForString("yyyy-MM-dd'T'HH:mm:ssZZZZZ", inTimeZone: NSTimeZone(forSecondsFromGMT: 0))
        
        return true
    }
}

