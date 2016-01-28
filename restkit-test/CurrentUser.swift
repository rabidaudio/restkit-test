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
class CurrentUser {
    
    static let pathPattern = "users/current"
    
    //hidden cached value of current user object
    private static var _currentUser: User?
    
    private static var manager = RKObjectManager.sharedManager()
    
    private static var prefs = NSUserDefaults.standardUserDefaults()
    
    static var isLoggedIn: Bool {
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
    
    static func get() -> User? {
        return _currentUser
    }
    
    static func fetch() -> Promise<User?> {
        if(_currentUser != nil){
            return Promise(_currentUser)
        }
        return RKObjectManager.sharedManager().getObjectWithPromise(nil, path: pathPattern, parameters: nil).then { response -> User? in
            return response as! User?
        }.recover { err -> User? in
            if FixdError.isUnauthenticated(err){
                return nil
            }else{
                throw err
            }
        }
    }
    
    static func logout() -> Promise<Void> {
        return (isLoggedIn ? Promise<AnyObject?>(nil) : manager.deleteObjectWithPromise(nil, path: pathPattern, parameters: nil)
            ).recover { err -> AnyObject? in
                //we don't care if the network request fails, because we are deleting the auth key anyway.
                //  shouldn't be a big deal if the session stays open on the server
                return nil
            }.then { data -> Void in
                // log out locally
                lastUserToken = nil
                setHeaders(nil)
                if(_currentUser != nil){
                    _currentUser!.authenticationToken = nil
                    defer { _currentUser = nil } // clear current user after save (even if save fails and throws)
                    try! _currentUser!.managedObjectContext!.save()
                }
        }
    }
    
    static func login(email: String, password: String) -> Promise<User> {
        return logout().then { //make sure logged out first
            manager.postObjectWithPromise(nil, path: pathPattern, parameters: ["user":["email": email, "password": password]])
            }.then { response -> User in
                let user = response as! User
                _currentUser = user
                lastUserEmail = user.email
                lastUserToken = user.authenticationToken
                setHeaders(user)
                return user
        }
    }
    
    private static func setHeaders(user: User?){
        manager.HTTPClient.setDefaultHeader("X-User-Email", value: user?.email!)
        manager.HTTPClient.setDefaultHeader("X-User-Token", value: user?.authenticationToken!)
    }
}