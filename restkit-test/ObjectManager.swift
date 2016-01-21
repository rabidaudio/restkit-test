//
//  ObjectMapper.swift
//  restkit-test
//
//  Created by fixd on 1/20/16.
//  Copyright © 2016 fixd. All rights reserved.
//

import Foundation
import RestKit

class ObjectManager {
    
    static let instance = ObjectManager()
    
    let models: [Model.Type] = [
        Gist.self,
        File.self,
    ]
    
    let manager = RKObjectManager(baseURL: NSURL(string: "https://api.github.com"))
    
    private init(){
        
        let managedObjectStore = RKManagedObjectStore(managedObjectModel: managedObjectModel)
        managedObjectStore.createPersistentStoreCoordinator()
        
        try! managedObjectStore.addInMemoryPersistentStore()
        managedObjectStore.createManagedObjectContexts()
        RKManagedObjectStore.setDefaultStore(managedObjectStore)
        
        manager.managedObjectStore = managedObjectStore
        RKObjectManager.setSharedManager(manager)
        
        for model in models {
            let mapping = RKEntityMapping(forEntityForName: model.name, inManagedObjectStore: managedObjectStore)
            mapping.addAttributeMappingsFromDictionary(model.attributeMappings)
            mapping.identificationAttributes = [model.idAttributeName]
            let responseDescriptor = RKResponseDescriptor(mapping: mapping, method: .Any, pathPattern: model.pathPattern, keyPath: nil, statusCodes: RKStatusCodeIndexSetForClass(.Successful))
            manager.addResponseDescriptor(responseDescriptor)
        }
        
    }
    
    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = NSBundle.mainBundle().URLForResource("restkit_test", withExtension: "momd")!
        return NSManagedObjectModel(contentsOfURL: modelURL)!
    }()
}


protocol Model {
    static var attributeMappings: [NSObject : AnyObject] { get }
    static var idAttributeName: String { get }
    static var pathPattern: String { get }
    static var name: String { get }
}