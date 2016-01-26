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
    
    let models: [Model] = [
        MakeModelYear.model,
        Vehicle.model,
        Mileage.model,
//        PullEvent.self,
//        Dtc.self,
        User.model
    ]
    
    // make context globally accessable
//    static func context() -> NSManagedObjectContext {
//        return RKManagedObjectStore.defaultStore().mainQueueManagedObjectContext // persistentStoreManagedObjectContext <-- use this for off-thread
//    }

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
        
        let success = RKStatusCodeIndexSetForClass(.Successful)
        let keyPath = "data" // the ket path for all objects in APIv2
        
//        for model in models {
////            for pattern in model.pathPatterns {
//////                let requestDescriptor = RKRequestDescriptor(mapping: model.entityMapping, objectClass: (model as! AnyClass), rootKeyPath: "data", method: .Any)
////                let responseDescriptor = RKResponseDescriptor(mapping: model.entityMapping, method: .Any, pathPattern: pattern, keyPath: "data", statusCodes: RKStatusCodeIndexSetForClass(.Successful))
//////                objectManager.addRequestDescriptor(requestDescriptor)
////                objectManager.addResponseDescriptor(responseDescriptor)
////            }
//            
//            for route in model.routeSet {
//                // add the core CRUD responses and routes
//                objectManager.router.routeSet.addRoute(route)
//                let descriptor = RKResponseDescriptor(mapping: model.entityMapping, method: route.method, pathPattern: route.pathPattern, keyPath: keyPath, statusCodes: success)
//                objectManager.addResponseDescriptor(descriptor)
//                
//                // add the index response as well
//                for indexPath in model.indexPathPatterns {
//                    let indexDescriptor = RKResponseDescriptor(mapping: model.entityMapping, method: .GET, pathPattern: indexPath, keyPath: keyPath, statusCodes: success)
//                    objectManager.addResponseDescriptor(indexDescriptor)
//                }
//                
//                //also create a request descriptor
//                objectManager.addRequestDescriptor(RKRequestDescriptor(mapping: model.dictionaryMapping, objectClass: model as! AnyObject.Type, rootKeyPath: "data", method: .Any))
//            }
//        }
        
        // configure models
        models.forEach { model in model.addToObjectManager(objectManager) }
        
        //add another response for session control
//        let loginDescriptor = RKResponseDescriptor(mapping: UserModel().entityMapping, method: .Any, pathPattern: User.currentUserPathPattern, keyPath: keyPath, statusCodes: success)
        objectManager.addResponseDescriptor(UserModel.loginResponseDescriptor)
        
        //add another response for errors
        for statusCodeSet in [RKStatusCodeIndexSetForClass(.ClientError), RKStatusCodeIndexSetForClass(.ServerError)] {
            let errorMapping = RKObjectMapping(forClass: RKErrorMessage.self)
            //map the details into userInfo (thanks to: http://stackoverflow.com/a/30254286)
            errorMapping.addPropertyMapping(RKAttributeMapping(fromKeyPath: "message", toKeyPath: "errorMessage"))
            errorMapping.addPropertyMapping(RKAttributeMapping(fromKeyPath: nil, toKeyPath: "userInfo"))
            
            let errorDesriptor = RKResponseDescriptor(mapping: errorMapping, method: .Any, pathPattern: nil, keyPath: "error", statusCodes: statusCodeSet)
            objectManager.addResponseDescriptor(errorDesriptor)
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
//            "pagination.current_page": "currentPage",
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
        
        objectManager.HTTPClient.setDefaultHeader("X-User-Email", value: UserModel.lastUserEmail)
        objectManager.HTTPClient.setDefaultHeader("X-User-Token", value: UserModel.lastUserToken)
        
        return true
    }
}

//extension NSError {
//    func FixdUserInfo() -> [NSObject: AnyObject]? {
//        return userInfo[RKObjectMapperErrorObjectsKey]?.firstObject as? RKErrorMessage
//    }
//}

//class StringToEnumTransformer: NSObject, RKValueTransforming {
//    @objc func transformValue(inputValue: AnyObject!, toValue outputValue: AutoreleasingUnsafeMutablePointer<AnyObject?>, ofClass outputValueClass: AnyClass!) throws {
//        let rawValue = inputValue as! String
//        let outClass = outputValueClass as! StringEnum.Type
//        let outputEnum = outClass.init(rawValue: rawValue)
//        if outputEnum == nil {
//            outputValue.memory = (outClass.defaultValue as! AnyObject?)
//        }else{
//            outputValue.memory = (outputEnum as! AnyObject)
//        }
//    }
//    
//    @objc func validateTransformationFromClass(inputValueClass: AnyClass!, toClass outputValueClass: AnyClass!) -> Bool {
//        return (inputValueClass as? String.Type != nil) && (outputValueClass as? StringEnum.Type != nil) && (outputValueClass as? String.Type != nil)
//    }
//}
//
//protocol StringEnum {
//    init?(rawValue: String) //the raw value initializer (enums have it, no need to implement)
//    static var defaultValue: StringEnum? { get } // the value to return if given an invalid string input. Can be nil
//}
