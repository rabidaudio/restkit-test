//
//  UserSessionExtension.swift
//  restkit-test
//
//  Created by fixd on 1/25/16.
//  Copyright © 2016 fixd. All rights reserved.
//

import Foundation
import RestKit
import PromiseKit


//extra methods on user for handling sessions
extension User {
    
    
    // store current logged in user info in shared preferences
    //    static var currentUser: User? {
    //        get {
    //            let prefs = NSUserDefaults.standardUserDefaults()
    //            if let userInfo = prefs.objectForKey("currentUser") as? NSDictionary {
    //                let id = userInfo["id"] as! Int
    //                let results: [User] = localQueryFor("User", withPredicate: "id == %@", andArguments: [String(id)])
    //                if !results.isEmpty {
    //                    let user = results.first!
    //                    user.email = userInfo["email"] as! String?
    ////                    user.authToken = userInfo["authToken"] as! String?
    //                    let authToken = userInfo["authToken"] as! String?
    //                    setHeaders(user.email, authToken: authToken)
    //                    return user
    //                }
    //            }
    //            // if any failures, we will end up here
    //            setHeaders(nil, authToken: nil)
    //            return nil
    //        }
    //        set(newUser) {
    //            let prefs = NSUserDefaults.standardUserDefaults()
    //            if(newUser != nil /*&& newUser?.authToken != nil*/ && newUser?.email != nil && newUser?.id != nil){
    //                let userInfo: NSDictionary = [
    //                    "id": newUser!.id!,
    //                    "email": newUser!.email!,
    ////                    "authToken": newUser!.authToken!
    //                ]
    //                prefs.setObject(userInfo, forKey: "currentUser")
    ////                setHeaders(newUser!.email, authToken: newUser!.authToken)
    //            }else{
    //                // log out
    //                prefs.setObject(nil, forKey: "currentUser")
    //                setHeaders(nil, authToken: nil)
    //            }
    //            prefs.synchronize()
    //        }
    //    }
    
    //hidden cached value of current user object
    private static var _currentUser: User?
    
    static var loggedIn: Bool {
        get {
            return _currentUser == nil
        }
    }
    
    static var lastUserEmail: String? {
        get {
            let prefs = NSUserDefaults.standardUserDefaults()
            return prefs.stringForKey("lastUserEmail")
        }
        set {
            let prefs = NSUserDefaults.standardUserDefaults()
            prefs.setObject(newValue, forKey: "lastUserEmail")
            prefs.synchronize()
        }
    }
    
    static var lastUserToken: String? {
        get {
            let prefs = NSUserDefaults.standardUserDefaults()
            return prefs.stringForKey("lastUserToken")
        }
        set {
            let prefs = NSUserDefaults.standardUserDefaults()
            prefs.setObject(newValue, forKey: "lastUserToken")
            prefs.synchronize()
        }
    }
    
    static func currentUser() -> Promise<User?> {
        if(_currentUser != nil){
            return Promise(_currentUser)
        }
        return RKObjectManager.sharedManager().getObjectWithPromise(nil, path: "users/current", parameters: nil).then { response -> User? in
            return response.firstResult()
        }
    }
    
    static func logout() -> Promise<Void> {
        let manager = RKObjectManager.sharedManager()
        return (loggedIn ?
            Promise<Response>(Response(operation: nil, result: nil)) :
            manager.deleteObjectWithPromise(nil, path: "users/current", parameters: nil)
            ).recover { err -> Response in
                //we don't care if the network request fails, because we are deleting the auth key anyway.
                //  shouldn't be a big deal if the session stays open on the server
                return Response(operation: nil, result: nil)
            }.then { data -> Void in
                // log out locally
                _currentUser = nil
                lastUserToken = nil
                setHeaders(nil)
        }
    }
    
    static func login(email: String, password: String) -> Promise<User> {
        let manager = RKObjectManager.sharedManager()
        return logout().then { //make sure logged out first
            //            var op = manager.appropriateObjectRequestOperationWithObject(nil, method: .POST, path: "", parameters: ["user":["email": email, "password": password]]) as! RKManagedObjectRequestOperation
            //            op.targetObject = nil
            //            return op.startWithPromise()
            manager.postObjectWithPromise(nil, path: "users/current", parameters: ["user":["email": email, "password": password]])
            }.then { response -> User in
                print(response, response.result.array())
                if let user: User = response.firstResult() {
                    print(user, user.authToken)
                    assert(user.authToken != nil, "should have set auth token")
                    _currentUser = user
                    lastUserEmail = user.email
                    lastUserToken = user.authToken
                    setHeaders(user)
                    return user
                }
                throw FixdError.InvalidParseResult(result: response.result)
        }
    }
    
    //    static var loginResponseDescriptor: RKResponseDescriptor {
    //        get{
    //            return RKResponseDescriptor(mapping: entityMapping, method: .POST, pathPattern: "", keyPath: "data", statusCodes: RKStatusCodeIndexSetForClass(.Successful))
    //        }
    //    }
    
    private static func setHeaders(user: User?){
        let manager = RKObjectManager.sharedManager()
        manager.HTTPClient.setDefaultHeader("X-User-Email", value: user?.email!)
        manager.HTTPClient.setDefaultHeader("X-User-Token", value: user?.authToken!)
    }
    
}