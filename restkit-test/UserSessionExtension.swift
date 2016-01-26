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
    
    static var currentUserPathPattern = "users/current"
    
//    static var loginResponseDescriptor: RKResponseDescriptor {
//        let r = RKResponseDescriptor(
//    }
    
    //hidden cached value of current user object
    private static var _currentUser: User?
    
    private static var manager = RKObjectManager.sharedManager()
    
    private static var prefs = NSUserDefaults.standardUserDefaults()
    
    static var loggedIn: Bool {
        get {
            return _currentUser == nil
        }
    }
    
    static var lastUserEmail: String? {
        get {
//            let prefs = NSUserDefaults.standardUserDefaults()
            return prefs.stringForKey("lastUserEmail")
        }
        set {
//            let prefs = NSUserDefaults.standardUserDefaults()
            prefs.setObject(newValue, forKey: "lastUserEmail")
            prefs.synchronize()
        }
    }
    
    static var lastUserToken: String? {
        get {
//            let prefs = NSUserDefaults.standardUserDefaults()
            return prefs.stringForKey("lastUserToken")
        }
        set {
//            let prefs = NSUserDefaults.standardUserDefaults()
            prefs.setObject(newValue, forKey: "lastUserToken")
            prefs.synchronize()
        }
    }
    
    
    static var currentUser: User? {
        get {
            return _currentUser
        }
    }
    
    static func fetchCurrentUser() -> Promise<User?> {
        if(_currentUser != nil){
            return Promise(_currentUser)
        }
        return RKObjectManager.sharedManager().getObjectWithPromise(nil, path: currentUserPathPattern, parameters: nil).then { response -> User? in
            return response.firstResult()
        }
    }
    
    static func logout() -> Promise<Void> {
//        let manager = RKObjectManager.sharedManager()
        return (loggedIn ?
            Promise<Response>(Response(operation: nil, result: nil)) :
            manager.deleteObjectWithPromise(nil, path: currentUserPathPattern, parameters: nil)
            ).recover { err -> Response in
                //we don't care if the network request fails, because we are deleting the auth key anyway.
                //  shouldn't be a big deal if the session stays open on the server
                return Response(operation: nil, result: nil)
            }.then { data -> Void in
                // log out locally
                lastUserToken = nil
                setHeaders(nil)
                if(_currentUser != nil){
                    _currentUser!.authToken = nil
                    defer { _currentUser = nil }
                    try! _currentUser!.managedObjectContext!.save()
                }
        }
    }
    
    static func login(email: String, password: String) -> Promise<User> {
//        let manager = RKObjectManager.sharedManager()
        return logout().then { //make sure logged out first
            manager.postObjectWithPromise(nil, path: currentUserPathPattern, parameters: ["user":["email": email, "password": password]])
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
    
    private static func setHeaders(user: User?){
//        let manager = RKObjectManager.sharedManager()
        manager.HTTPClient.setDefaultHeader("X-User-Email", value: user?.email!)
        manager.HTTPClient.setDefaultHeader("X-User-Token", value: user?.authToken!)
    }
}