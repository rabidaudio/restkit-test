//
//  ObjectMapper.swift
//  restkit-test
//
//  Created by fixd on 1/20/16.
//  Copyright © 2016 fixd. All rights reserved.
//

import Foundation
import RestKit

//class ObjectManager {
//    
//    static let instance = ObjectManager()
//    
//    let models: [Model.Type] = [
//    ]
//    
//    var entities = [String : NSEntityDescription]()
//    
//    
//    
//    let context: NSManagedObjectContext
//    
//    let managedObjectModel: NSManagedObjectModel
//    
//    private init(){
//        
//        // get url for CoreData models
//
//        
//        //http://cocoadocs.org/docsets/RestKit/0.25.0/
//        
//        // create an objectStore using RestKit's CoreData wrappers
//        
//        managedObjectStore.createPersistentStoreCoordinator()
//        try! managedObjectStore.addInMemoryPersistentStore()
//        managedObjectStore.createManagedObjectContexts()
//        
//        
//        manager.managedObjectStore = managedObjectStore
//        
//        
//        
//        
//        // for all api-accessable models, create their EntityMapping, which describes how
//        //  to map JSON representation to their NSManagedObjectModel fields, and 
//        //  create the appropriate response descriptors
//        for model in models {
//            let mapping = RKEntityMapping(forEntityForName: model.name, inManagedObjectStore: managedObjectStore)
//            mapping.addAttributeMappingsFromDictionary(model.attributeMappings)
//            mapping.identificationAttributes = [model.idAttributeName]
//            
//            let responseDescriptor = RKResponseDescriptor(mapping: mapping, method: .Any, pathPattern: model.pathPattern, keyPath: nil, statusCodes: RKStatusCodeIndexSetForClass(.Successful))
//            manager.addResponseDescriptor(responseDescriptor)
//            
//            let entity = NSEntityDescription.entityForName(model.name, inManagedObjectContext: context)
//            entities[model.name] = entity
//        }
//    }
//    
//    func createRequest(type: Model.Type) -> NSFetchRequest {
//        let request = NSFetchRequest()
//        request.entity = entities[type.name]
//        request.sortDescriptors = type.sortDescriptors
//        request.fetchBatchSize = 20
//        return request
//    }
//}


