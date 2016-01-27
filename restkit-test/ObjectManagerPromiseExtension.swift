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
    
    //todo refactor to return only data item using generics
    
    func managedObjectRequestOperationWithRequestAndPromsise(request: NSURLRequest!, managedObjectContext: NSManagedObjectContext!) -> Promise<Response> {
        return Promise { fulfill, reject in
            managedObjectRequestOperationWithRequest(request, managedObjectContext: managedObjectContext, success: { fulfill(Response(operation: $0, result: $1)) }, failure:  { reject($1) })
        }
    }
    
    func getObjectsAtPathWithPromise(path: String!, parameters: [NSObject : AnyObject]!) -> Promise<Response> {
        return Promise { fulfill, reject in
            getObjectsAtPath(path, parameters: parameters, success: { fulfill(Response(operation: $0, result: $1)) }, failure:  { reject($1) })
        }
    }
    
    func getAllObjectsForPathPatternWithPromise(path: String!, parameters: [NSObject : AnyObject]!) -> Promise<PagedResponse> {
        let paginator = paginatorWithPathPattern(path+"?per_page=:perPage&page=:currentPage", parameters: parameters)
        return Promise { fulfill, reject in
            var combinedResults: [AnyObject] = []
            paginator.setCompletionBlockWithSuccess({ (paginator, results, page) -> Void in
                combinedResults.appendContentsOf(results)
                if paginator.hasNextPage {
                    paginator.loadNextPage()
                }else {
                    fulfill(PagedResponse(paginator: paginator, results: combinedResults, page: page))
                }
            }, failure: { reject($1) } )
            paginator.loadPage(1)
        }
    }
    
    func getObjectsAtPathForRelationshipWithPromise(relationshipName: String!, ofObject: AnyObject!, parameters: [NSObject : AnyObject]!) -> Promise<Response> {
        return Promise { fulfill, reject in
            getObjectsAtPathForRelationship(relationshipName, ofObject: ofObject, parameters: parameters, success: { fulfill(Response(operation: $0, result: $1)) }, failure:  { reject($1) })
        }
    }
    
    
    func getObjectsAtPathForRouteNamedWithPromise(routeName: String!, object: AnyObject!, parameters: [NSObject : AnyObject]!) -> Promise<Response> {
        return Promise { fulfill, reject in
            getObjectsAtPathForRouteNamed(routeName, object: object, parameters: parameters, success: { fulfill(Response(operation: $0, result: $1)) }, failure:  { reject($1) })
        }
    }
    
    func getObjectWithPromise(object: AnyObject!, path: String!, parameters: [NSObject : AnyObject]!) -> Promise<Response> {
        return Promise { fulfill, reject in
            getObject(object, path: path, parameters: parameters, success: { fulfill(Response(operation: $0, result: $1)) }, failure:  { reject($1) })
        }
    }
    
    
    func putObjectWithPromise(object: AnyObject!, path: String!, parameters: [NSObject : AnyObject]!)-> Promise<Response> {
        return Promise { fulfill, reject in
            putObject(object, path: path, parameters: parameters, success: { fulfill(Response(operation: $0, result: $1)) }, failure:  { reject($1) })
        }
    }
    
    func postObjectWithPromise(object: AnyObject!, path: String!, parameters: [NSObject : AnyObject]!)-> Promise<Response> {
        return Promise { fulfill, reject in
            postObject(object, path: path, parameters: parameters, success: { fulfill(Response(operation: $0, result: $1)) }, failure:  { reject($1) })
        }
    }
    
    func patchObjectWithPromise(object: AnyObject!, path: String!, parameters: [NSObject : AnyObject]!)-> Promise<Response> {
        return Promise { fulfill, reject in
            patchObject(object, path: path, parameters: parameters, success: { fulfill(Response(operation: $0, result: $1)) }, failure:  { reject($1) })
        }
    }
    
    func deleteObjectWithPromise(object: AnyObject!, path: String!, parameters: [NSObject : AnyObject]!)-> Promise<Response> {
        return Promise { fulfill, reject in
            deleteObject(object, path: path, parameters: parameters, success: { fulfill(Response(operation: $0, result: $1)) }, failure:  { reject($1) })
        }
    }
}

struct Response {
    let operation: RKObjectRequestOperation!
    let result: RKMappingResult!
    
    func firstResult<T>() -> T? {
        return result.firstObject as? T
    }
}

struct PagedResponse {
    let paginator: RKPaginator!
    let results: [AnyObject]!
    let page: UInt
}