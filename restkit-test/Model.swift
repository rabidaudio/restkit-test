//
//  Model.swift
//  restkit-test
//
//  Created by fixd on 1/22/16.
//  Copyright © 2016 fixd. All rights reserved.
//

import Foundation
import RestKit

protocol Model {
    
    static var pathPatterns: [String] { get }
    static var entityMapping: RKEntityMapping { get }
    
}

extension Model {
    
    // run a local CoreData query only. Use with care!
    static func localQueryFor<T>(entityName: String, withPredicate: String?, andArguments: [String]?) -> [T]{
        let context = AppDelegate.context()
        let request = NSFetchRequest(entityName: entityName)
        if(withPredicate != nil){
            request.predicate = NSPredicate(format: withPredicate!, argumentArray: andArguments)
        }
        if let results = try? context.executeFetchRequest(request){
            let casted = results.map { $0 as! T }
            return casted
        }else{
            return []
        }
    }
}