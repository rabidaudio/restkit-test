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
extension UserModel {
    
    static let currentUserPathPattern = "users/current"
    
    //hidden cached value of current user object
    private static var _currentUser: User?
    
    private static var manager = RKObjectManager.sharedManager()
    
    private static var prefs = NSUserDefaults.standardUserDefaults()
    
    static let loginResponseDescriptor: RKResponseDescriptor = {
        let userModel = UserModel()
        let success = RKStatusCodeIndexSetForClass(.Successful)
        return RKResponseDescriptor(mapping: userModel.entityMapping, method: .Any, pathPattern: currentUserPathPattern, keyPath: userModel.responseKeyPath, statusCodes: success)
    }()
    
    static var loggedIn: Bool {
        get {
            return _currentUser == nil
        }
    }
    
    static var lastUserEmail: String? {
        get {
            return prefs.stringForKey("lastUserEmail")
        }
        set {
            prefs.setObject(newValue, forKey: "lastUserEmail")
            prefs.synchronize()
        }
    }
    
    static var lastUserToken: String? {
        get {
            return prefs.stringForKey("lastUserToken")
        }
        set {
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
                    _currentUser!.authenticationToken = nil
                    defer { _currentUser = nil }
                    try! _currentUser!.managedObjectContext!.save()
                }
        }
    }
    
    static func login(email: String, password: String) -> Promise<User> {
        return logout().then { //make sure logged out first
            manager.postObjectWithPromise(nil, path: currentUserPathPattern, parameters: ["user":["email": email, "password": password]])
            }.then { response -> User in
                if let user: User = response.firstResult() {
                    _currentUser = user
                    lastUserEmail = user.email
                    lastUserToken = user.authenticationToken
                    setHeaders(user)
                    return user
                }
                throw FixdError.InvalidParseResult(result: response.result)
        }
    }
    
    private static func setHeaders(user: User?){
        manager.HTTPClient.setDefaultHeader("X-User-Email", value: user?.email!)
        manager.HTTPClient.setDefaultHeader("X-User-Token", value: user?.authenticationToken!)
    }
}