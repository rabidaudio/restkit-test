//
//  ObjectManagerPromiseExtension.swift
//  restkit-test
//
//  Created by fixd on 1/24/16.
//  Copyright © 2016 fixd. All rights reserved.
//

import Foundation
import RestKit
import PromiseKit

// extend ObjectManager to include Promise-ified core methods
// some PromiseKit notes (AKA Swift quirks): 
//      - A `then` block which doesn't return a promise must explicitly state a return type (so the last one, and maybe others)
//      - `always` must come before `catch`
//      - you can optionally use `firstly` before the first promise to make it a little prettier

extension RKObjectManager {
    
    // extension of ObjectManager to allow raw HTTP requests that return promises
//    func executeRawRequest(path: String!, method: RKRequestMethod, parameters: [NSObject : AnyObject]!) -> Promise<AnyObject!> {
//        var methodString: String
//        switch method {
//        case RKRequestMethod.GET:
//            methodString = "GET"
//        case RKRequestMethod.POST:
//            methodString = "POST"
//        case RKRequestMethod.PUT:
//            methodString = "PUT"
//        case RKRequestMethod.PATCH:
//            methodString = "PATCH"
//        case RKRequestMethod.DELETE:
//            methodString = "DELETE"
//        default:
//            methodString = "GET"
//        }
//        let request = HTTPClient.requestWithMethod(methodString, path: path, parameters: parameters)
//        return Promise { fulfill, reject in
//            HTTPClient.HTTPRequestOperationWithRequest(request, success: { fulfill($1) }, failure: { reject($1) })
//        }
//    }
    
    
    func managedObjectRequestOperationWithRequest(request: NSURLRequest!, managedObjectContext: NSManagedObjectContext!) -> Promise<RKMappingResult!> {
        return Promise { fulfill, reject in
            managedObjectRequestOperationWithRequest(request, managedObjectContext: managedObjectContext, success: { fulfill($1) }, failure:  { reject($1) })
        }
    }
    
    func getObjectsAtPath(path: String!, parameters: [NSObject : AnyObject]!) -> Promise<RKMappingResult!> {
        return Promise { fulfill, reject in
            getObjectsAtPath(path, parameters: parameters, success: { fulfill($1) }, failure:  { reject($1) })
        }
    }
    
    func getObjectsAtPathForRelationship(relationshipName: String!, ofObject: AnyObject!, parameters: [NSObject : AnyObject]!) -> Promise<RKMappingResult!> {
        return Promise { fulfill, reject in
            getObjectsAtPathForRelationship(relationshipName, ofObject: ofObject, parameters: parameters, success: { fulfill($1) }, failure:  { reject($1) })
        }
    }
    
    
    func getObjectsAtPathForRouteNamed(routeName: String!, object: AnyObject!, parameters: [NSObject : AnyObject]!) -> Promise<RKMappingResult!> {
        return Promise { fulfill, reject in
            getObjectsAtPathForRouteNamed(routeName, object: object, parameters: parameters, success: { fulfill($1) }, failure:  { reject($1) })
        }
    }
    
    func getObject(object: AnyObject!, path: String!, parameters: [NSObject : AnyObject]!) -> Promise<RKMappingResult!> {
        return Promise { fulfill, reject in
            getObject(object, path: path, parameters: parameters, success: { fulfill($1) }, failure:  { reject($1) })
        }
    }
    
    
    func putObject(object: AnyObject!, path: String!, parameters: [NSObject : AnyObject]!)-> Promise<RKMappingResult!> {
        return Promise { fulfill, reject in
            putObject(object, path: path, parameters: parameters, success: { fulfill($1) }, failure:  { reject($1) })
        }
    }
    
    func postObject(object: AnyObject!, path: String!, parameters: [NSObject : AnyObject]!)-> Promise<RKMappingResult!> {
        return Promise { fulfill, reject in
            postObject(object, path: path, parameters: parameters, success: { fulfill($1) }, failure:  { reject($1) })
        }
    }
    
    func patchObject(object: AnyObject!, path: String!, parameters: [NSObject : AnyObject]!)-> Promise<RKMappingResult!> {
        return Promise { fulfill, reject in
            patchObject(object, path: path, parameters: parameters, success: { fulfill($1) }, failure:  { reject($1) })
        }
    }
    
    func deleteObjectP(object: AnyObject!, path: String!, parameters: [NSObject : AnyObject]!)-> Promise<RKMappingResult!> {
        return Promise { fulfill, reject in
            deleteObject(object, path: path, parameters: parameters, success: { fulfill($1) }, failure:  { reject($1) })
        }
    }
}