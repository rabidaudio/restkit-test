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
    
    let models = [
        "Gist": Gist.self,
        
    ]
    
    let manager = RKObjectManager(baseURL: NSURL(string: "https://api.github.com"))
    
    init(store: RKManagedObjectStore){
        manager.managedObjectStore = store
        RKObjectManager.setSharedManager(manager)
    }
}

protocol Mappable {
//    static func map() -> [NSObject : AnyObject]
    static var map: [NSObject : AnyObject] { get }
}

protocol Identifiable {
//    static func id() -> String
    static var idParamName: String { get }
}