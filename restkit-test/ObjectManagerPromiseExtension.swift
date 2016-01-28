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
//
// some PromiseKit notes (AKA Swift quirks): 
//      - A `then` block which doesn't return a promise must explicitly state a return type (so the last one, and maybe others)
//      - `always` must come before `error`
//      - you can optionally use `firstly` before the first promise to make it a little prettier
//
// I'd like for these to use generics to detect the return type, but unfortunately when I try it causes a segfault in the compiler (lol!).
// So instead, you can just handle all of your `then` blocks like this:
//
//     .then { results in
//        guard let users = results as? [User] else { throw MyError }
//        <... use users...>
//     }
//
// Thanks to promises, you can handle all of these at the end of the chain!
//
extension RKObjectManager {
    
    func managedObjectRequestOperationWithRequestAndPromsise(request: NSURLRequest!, managedObjectContext: NSManagedObjectContext!) -> Promise<[AnyObject]?> {
        let p = Promise<[AnyObject]?> { fulfill, reject in
            managedObjectRequestOperationWithRequest(request, managedObjectContext: managedObjectContext, success: { fulfill($1.array()) }, failure:  { reject($1) })
        }
        p.error(FixdError.handleError)
        return p
    }
    
    func getObjectsAtPathWithPromise(path: String!, parameters: [NSObject : AnyObject]!) -> Promise<[AnyObject]?> {
        return Promise { fulfill, reject in
            getObjectsAtPath(path, parameters: parameters, success: { fulfill($1.array()) }, failure:  { reject($1) })
        }
    }
    
    // getObjectsAtPath() is only going to return the first page of results. If you need all pages, you need to use this method
    func getAllObjectsForPathPatternWithPromise(path: String!, parameters: [NSObject : AnyObject]!) -> Promise<[AnyObject]?> {
        let paginator = paginatorWithPathPattern(path+"?per_page=:perPage&page=:currentPage", parameters: parameters)
        // we can set perPage on the paginator to the api's max value. However it actually seems faster (about 20% in my unscientific test) to
        //let RestKit pick its own page size. not sure why (maybe it can load the new records while the next network request loads?), but I'll take it.
//        paginator.perPage = 50
        return Promise { fulfill, reject in
            var combinedResults: [AnyObject] = []
            paginator.setCompletionBlockWithSuccess({ (paginator, results, page) -> Void in
                combinedResults.appendContentsOf(results)
                if paginator.hasNextPage {
                    paginator.loadNextPage()
                }else {
                    fulfill(combinedResults)
                }
            }, failure: { reject($1) } )
            paginator.loadPage(1)
        }
    }
    
    func getObjectsAtPathForRelationshipWithPromise(relationshipName: String!, ofObject: AnyObject!, parameters: [NSObject : AnyObject]!) -> Promise<[AnyObject]?> {
        return Promise { fulfill, reject in
            getObjectsAtPathForRelationship(relationshipName, ofObject: ofObject, parameters: parameters, success: { fulfill($1.array()) }, failure:  { reject($1) })
        }
    }
    
    
    func getObjectsAtPathForRouteNamedWithPromise(routeName: String!, object: AnyObject!, parameters: [NSObject : AnyObject]!) -> Promise<[AnyObject]?> {
        return Promise { fulfill, reject in
            getObjectsAtPathForRouteNamed(routeName, object: object, parameters: parameters, success: { fulfill($1.array()) }, failure:  { reject($1) })
        }
    }
    
    func getObjectWithPromise(object: AnyObject!, path: String!, parameters: [NSObject : AnyObject]!) -> Promise<AnyObject?> {
        return Promise { fulfill, reject in
            getObject(object, path: path, parameters: parameters, success: { fulfill($1.firstObject) }, failure:  { reject($1) })
        }
    }
    
    
    func putObjectWithPromise(object: AnyObject!, path: String!, parameters: [NSObject : AnyObject]!)-> Promise<AnyObject?> {
        return Promise { fulfill, reject in
            putObject(object, path: path, parameters: parameters, success: { fulfill($1.firstObject) }, failure:  { reject($1) })
        }
    }
    
    func postObjectWithPromise(object: AnyObject!, path: String!, parameters: [NSObject : AnyObject]!)-> Promise<AnyObject?> {
        return Promise { fulfill, reject in
            postObject(object, path: path, parameters: parameters, success: { fulfill($1.firstObject) }, failure:  { reject($1) })
        }
    }
    
    func patchObjectWithPromise(object: AnyObject!, path: String!, parameters: [NSObject : AnyObject]!)-> Promise<AnyObject?> {
        return Promise { fulfill, reject in
            patchObject(object, path: path, parameters: parameters, success: { fulfill($1.firstObject) }, failure:  { reject($1) })
        }
    }
    
    func deleteObjectWithPromise(object: AnyObject!, path: String!, parameters: [NSObject : AnyObject]!)-> Promise<AnyObject?> {
        return Promise { fulfill, reject in
            deleteObject(object, path: path, parameters: parameters, success: { fulfill($1.firstObject) }, failure:  { reject($1) })
        }
    }
}