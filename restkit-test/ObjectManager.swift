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
    ]
    
    var entities = [String : NSEntityDescription]()
    
    let manager = RKObjectManager(baseURL: NSURL(string: "https://api.github.com"))
    
    let context: NSManagedObjectContext
    
    let managedObjectModel: NSManagedObjectModel
    
    private init(){
        
        // get url for CoreData models
        let modelURL = NSBundle.mainBundle().URLForResource("restkit_test", withExtension: "momd")!
        // create managedObjectModel instance from CoreData
        managedObjectModel = NSManagedObjectModel(contentsOfURL: modelURL)!
        
        //http://cocoadocs.org/docsets/RestKit/0.25.0/
        let dbPath = RKApplicationDataDirectory().stringByAppendingString("/DataStore.sqlite")
        // create an objectStore using RestKit's CoreData wrappers
        let managedObjectStore = RKManagedObjectStore(managedObjectModel: managedObjectModel)
        managedObjectStore.createPersistentStoreCoordinator()
        try! managedObjectStore.addInMemoryPersistentStore()
        managedObjectStore.createManagedObjectContexts()
        RKManagedObjectStore.setDefaultStore(managedObjectStore)
        
        manager.managedObjectStore = managedObjectStore
        RKObjectManager.setSharedManager(manager)
        
        context = managedObjectStore.mainQueueManagedObjectContext
        
        // for all api-accessable models, create their EntityMapping, which describes how
        //  to map JSON representation to their NSManagedObjectModel fields, and 
        //  create the appropriate response descriptors
        for model in models {
            let mapping = RKEntityMapping(forEntityForName: model.name, inManagedObjectStore: managedObjectStore)
            mapping.addAttributeMappingsFromDictionary(model.attributeMappings)
            mapping.identificationAttributes = [model.idAttributeName]
            
            let responseDescriptor = RKResponseDescriptor(mapping: mapping, method: .Any, pathPattern: model.pathPattern, keyPath: nil, statusCodes: RKStatusCodeIndexSetForClass(.Successful))
            manager.addResponseDescriptor(responseDescriptor)
            
            let entity = NSEntityDescription.entityForName(model.name, inManagedObjectContext: context)
            entities[model.name] = entity
        }
    }
    
    func createRequest(type: Model.Type) -> NSFetchRequest {
        let request = NSFetchRequest()
        request.entity = entities[type.name]
        request.sortDescriptors = type.sortDescriptors
        request.fetchBatchSize = 20
        return request
    }
}

protocol Model {
    static var attributeMappings: [NSObject : AnyObject] { get }
    static var idAttributeName: String { get }
    static var pathPattern: String { get }
    static var name: String { get }
    static var sortDescriptors: [NSSortDescriptor] { get }
}
