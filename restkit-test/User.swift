//
//  User.swift
//  restkit-test
//
//  Created by fixd on 1/22/16.
//  Copyright © 2016 fixd. All rights reserved.
//

import Foundation
import RestKit
import PromiseKit

class User: NSManagedObject, Model {

    // allow to hold an authToken, but don't persist in database
    var authToken: String?
    var password: String?
    
    static var pathPatterns = ["users", "users/:id"]
    
    // create an RKEntityMapping for yourself, mapping keys and values and setting id and relationships if neccessary
    static var entityMapping: RKEntityMapping {
        let mapping = RKEntityMapping(forEntityForName: "User", inManagedObjectStore: RKManagedObjectStore.defaultStore())
        mapping.addAttributeMappingsFromDictionary(mappingDictonary)
        mapping.identificationAttributes = ["id"]
        return mapping
    }
    
    // store current logged in user info in shared preferences
    static var currentUser: User? {
        get {
            let prefs = NSUserDefaults.standardUserDefaults()
            if let userInfo = prefs.objectForKey("currentUser") as? NSDictionary {
                let id = userInfo["id"] as! Int
                if let user = getLocalById(id) {
                    user.email = userInfo["email"] as! String?
                    user.authToken = userInfo["authToken"] as! String?
                    setHeaders(user.email, authToken: user.authToken)
                    return user
                }
            }
            // if any failures, we will end up here
            setHeaders(nil, authToken: nil)
            return nil
        }
        set(newUser) {
            let prefs = NSUserDefaults.standardUserDefaults()
            if(newUser != nil && newUser?.authToken != nil && newUser?.email != nil && newUser?.id != nil){
                let userInfo: NSDictionary = [
                    "id": newUser!.id!,
                    "email": newUser!.email!,
                    "authToken": newUser!.authToken!
                ]
                prefs.setObject(userInfo, forKey: "currentUser")
                setHeaders(newUser!.email, authToken: newUser!.authToken)
            }else{
                // log out
                prefs.setObject(nil, forKey: "currentUser")
                setHeaders(nil, authToken: nil)
            }
            prefs.synchronize()
        }
    }

    static func logout() -> Promise<Void> {
        let manager = RKObjectManager.sharedManager()
        if(currentUser == nil){
            return Promise()
        }else{
            //we don't care if the network request fails, because we are deleting the auth key anyway.
            //  shouldn't be a big deal if the session stays open on the server
            return manager.deleteObjectP(nil, path: "", parameters: nil).recover { err in
                return RKMappingResult()
            }.then { data -> Void in
                currentUser = nil
            }
        }
    }
    
    static func login(email: String, password: String) -> Promise<User> {
        let manager = RKObjectManager.sharedManager()
        return logout().then { //make sure logged out first
            manager.postObject(nil, path: "", parameters: ["user":["email": email, "password": password]])
        }.then { result -> User in
            if let userData = result.firstObject as? NSMutableDictionary {
                print(userData)
                let id = userData["id"] as! Int
                // TODO dirty...
                var user = getLocalById(id)
                if(user == nil){
                    user = User()
                    user!.id = id
                }
                user!.email = userData["email"] as! String?
                user!.authToken = userData["authentication_token"] as! String?
                
                currentUser = user
                return user!
            }else{
                throw FixdError.InvalidParseResult(result: result)
            }
        }
    }
    
    static var loginResponseDescriptor: RKResponseDescriptor {
        get{
            let mapping = RKObjectMapping(forClass: NSMutableDictionary.self)
            mapping.addAttributeMappingsFromDictionary(mappingDictonary)
            return RKResponseDescriptor(mapping: mapping, method: .POST, pathPattern: "", keyPath: "data", statusCodes: RKStatusCodeIndexSetForClass(.Successful))
        }
    }
    
    private static func getLocalById(id: Int) -> User? {
        let context = AppDelegate.context()
        let userRequest = NSFetchRequest(entityName: "User")
        userRequest.predicate = NSPredicate(format: "id == %@", String(id))
        if let results = try? context.executeFetchRequest(userRequest){
            if let user = results.first as? User {
                return user
            }
        }
        return nil
    }
    
    private static func setHeaders(email: String?, authToken: String?){
        let manager = RKObjectManager.sharedManager()
        manager.HTTPClient.setDefaultHeader("X-User-Email", value: email)
        manager.HTTPClient.setDefaultHeader("X-User-Token", value: authToken)
    }
    
    private static let mappingDictonary: [NSObject: AnyObject] = [
        "id": "id",
        "email": "email",
        "first_name": "firstName",
        "last_name": "lastName",
        "authentication_token": "authToken",
        "password": "password",
        "created_at": "createdAt",
        "updated_at": "updatedAt"
    ]
}

extension User {
    
    @NSManaged var id: NSNumber?
    @NSManaged var email: String?
    @NSManaged var firstName: String?
    @NSManaged var lastName: String?
    @NSManaged var vehicles: NSSet?
    @NSManaged var mileages: NSSet?
    @NSManaged var pulls: NSSet?
    
}