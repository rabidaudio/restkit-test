//
//  Model.swift
//  restkit-test
//
//  Created by fixd on 1/22/16.
//  Copyright © 2016 fixd. All rights reserved.
//

import Foundation
import RestKit

// This is a helper class for initialzing CoreData/RestKit for our models.
//
// Children can simply set a private initializer which calls the big initializer
// below. If the model has relationships to set, it should override `addRelationships()`.
//
// The defaults are designed to be pretty standard. If the model significantly
// deviates from the defaults, it can override other properties.
// Ultimately it just needs to generate the correct routes and request and response
// descriptors.
class Model {
    
    // the object class of the model
    let type: NSManagedObject.Type
    
    // the mappings of keys from their JSON name to their CoreData entity attribute
    let paramMappings: [String: String]
    
    // the name of the Core Data entity (e.g. `User`)
    let entityName: String
    
    // the endpoint resource name, e.g. `users` if your path is /users/:id
    let resourceName: String
    
    // the set of attributes that uniquely identify a model
    let idAttributes: [String]
    
    // a list of path patterns that return a collection, e.g. ["posts", "users/1/posts"] (note no leading slash!)
    let indexPaths: [String]
    
    let keyPath: String
    
    //todo we could simplify a lot of this:
    //  https://github.com/sammy-SC/Pluralize.swift
    //  https://github.com/travisjeffery/NSDictionary-TRVSUnderscoreCamelCaseAdditions
    
    init(type: NSManagedObject.Type, resourceName: String, idAttributes: [String] = ["id"], indexPaths: [String]? = nil, keyPath: String = "data", paramMappings: [String: String]){
        self.type = type
        self.entityName = type.entityName()
        self.resourceName = resourceName
        self.idAttributes = idAttributes
        self.indexPaths = indexPaths == nil ? [resourceName] : indexPaths!
        self.keyPath = keyPath
        self.paramMappings = paramMappings
    }
    
    var entityMapping: RKEntityMapping {
        let mapping = RKEntityMapping(forEntityForName: entityName, inManagedObjectStore: RKManagedObjectStore.defaultStore())
        mapping.addAttributeMappingsFromDictionary(paramMappings)
        mapping.identificationAttributes = idAttributes
        addRelationships(mapping)
        return mapping
    }
    
    var requestDescriptors: [RKRequestDescriptor] {
        let mapping = RKObjectMapping(forClass: NSMutableDictionary.self)
        mapping.addAttributeMappingsFromDictionary(reverseParamMappings)
        return [RKRequestDescriptor(mapping: mapping, objectClass: type, rootKeyPath: keyPath, method: .Any)]
    }
    
    var responseDescriptors: [RKResponseDescriptor] {
        var descriptors = [RKResponseDescriptor]()
        let successfulCodes = RKStatusCodeIndexSetForClass(.Successful)
        for route in routeSet {
            let crudDescriptor = RKResponseDescriptor(mapping: entityMapping, method: route.method, pathPattern: route.pathPattern, keyPath: keyPath, statusCodes: successfulCodes)
            descriptors.append(crudDescriptor)
        }
        for indexPath in indexPaths {
            let indexResponseDescriptor = RKResponseDescriptor(mapping: entityMapping, method: .GET, pathPattern: indexPath, keyPath: keyPath, statusCodes: successfulCodes)
            descriptors.append(indexResponseDescriptor)
        }
        return descriptors
    }
    
    final func addToObjectManager(manager: RKObjectManager){
        //add routes
        manager.router.routeSet.addRoutes(routeSet)
        //add descriptors
        manager.addRequestDescriptorsFromArray(requestDescriptors)
        manager.addResponseDescriptorsFromArray(responseDescriptors)
    }
    
    // Override this method to define relationships with other models.
    //
    //  == If the other object is included in the response ==
    //  Simply add a relationship mapping to the property:
    //      mapping.addPropertyMapping(RKRelationshipMapping(fromKeyPath: "user", toKeyPath: "user", withMapping: User.model.entityMapping))
    //  == If only the ID is included ==
    //  1. Add a property to the source entity in CoreData and mark it as "transient" (e.g. Post.userId)
    //  2. Include the property in your paramMappings (e.g. PostParamMappings = ["user_id": "userId"])
    //  3. Add a relationship connection:
    //      postMapping.addConnectionForRelationship("user", connectedBy: ["userId": "id"])
    func addRelationships(mapping: RKEntityMapping) {
        // default no-op
    }
    
    //the attribute in your url. e.g. `vin` if your path is /vehicles/:vin
    var idInResourcePath: String {
        return idAttributes.first!
    }
    
    // the default routeSet matches Rails ":resources"-style routes, e.g. users, users/:id, etc
    var routeSet: [RKRoute] {
        return [
            RKRoute(withClass: type, pathPattern: "\(resourceName)", method: .POST),                        //create
            RKRoute(withClass: type, pathPattern: "\(resourceName)/:\(idInResourcePath)", method: .GET),     //show
            RKRoute(withClass: type, pathPattern: "\(resourceName)/:\(idInResourcePath)", method: .PUT),     //update
            RKRoute(withClass: type, pathPattern: "\(resourceName)/:\(idInResourcePath)", method: .DELETE)   //destroy
        ]
    }
    
    // the mapping from Core Data attributes to json. The default is the reverse of paramMappings
    var reverseParamMappings: [String: String] {
        var reverseMapping = [String: String]()
        paramMappings.forEach { key, val in reverseMapping[val] = key }
        return reverseMapping
    }
}

//  === Extensions to NSObject for Model instantiation ===
//
// This takes some explaining.
//
// So typically with Core Data, you create instances of your NSManagedObjects like this:
//
//      NSManagedObject(entity: NSEntityDescription, insertIntoManagedObjectContext: NSManagedObjectContext?)
//
// The same thing goes for custom subclasses of NSMangedObject. In fact, if let's say you have a User
// class as a subclass of a Core Data `User` entity, then if you call the default initializer `User()`
// and then try and set a property, you'll get a fatal error! The default initalizer is used by
// Core Data/KVC, and you shouldn't use it. You should *always* create NSManagedObject instances by
// passing in the correct context.
// 
// [see https://developer.apple.com/library/mac/documentation/Cocoa/Conceptual/CoreData/CreatingObjects.html]
//
// However, thanks to RestKit, most of the time we never have to worry about creating objects or
// NSManagedObjectContext. Objects are created for us automatically through RKObjectManager.
// RestKit also provides us an NSManagedObjectContext to use:
//
//      RKManagedObjectStore.defaultStore().mainQueueManagedObjectContext       (on the main thread or)
//      RKManagedObjectStore.defaultStore().persistentStoreManagedObjectContext (off the main thread)
//
// In fact, the only time we really care about all the Core Data crap is when creating a new object.
// Ideally, you'd want to make a new instance of your User, set the properties, and then launch
// 
//      RKObjectManager.sharedManager().postObject(myUser, ...)
//
// If you aren't used to using Core Data, it is easy to forget that you can't do this:
//
//      let myUser = User() // will throw a runtime error if you try and set properties!
//
//  Meanwhile, doing this is pretty stupid and will probably confuse the hell out of people reading
//  your code:
//
//      // technically right, but verbose and terribly confusing
//      let context = RKManagedObjectStore.defaultStore().mainQueueManagedObjectContext
//      let entity = NSEntityDescription.entityForName("User", inManagedObjectContext: context)
//      let myUser = NSManagedObject(entity: entity, insertIntoManagedObjectContext: context)
//
// Looking for a solution, I found a great post by Brian Coyner:
//      https://briancoyner.github.io/2015/08/01/coredata-swift2.html
//
// He uses some Swift metaprogramming to make a convenience initializer for NSManagedObject
// by detecting the entity name from the class name and making a constructor that takes in
// only the NSManagedObjectContext.
//
// However, because with RestKit our context is constant, it seems redundant to include it
// in the initializer. Unfortunately, hard-coding it causes us to override the default
// initializer, which is number one on Core Data's don'ts list. So we need to include some
// argument to the initializer. Here were a few ideas I had:
//
//  1. Take in AnyObject? which we could just pass in nil. However, that looks possibly
//      even more confusing.
//
//          let myUser = User(dummyProperty: nil)
//
//  2. Take in the entity name. This removes the need for sketchy metaprogramming method
//      entityName(), but looks a little redundant. Still, I'm open to it.
//
//          let myUser = User(entityName: "User")
//
//  3. Take in a Bool, which selects which initializer to use. If true, it uses the context-
//      based one. Not great, but not terrible. Also, the `insert:` name reminds you that
//      it is an NSManagedObject which must be inserted into a context, reminiscent of
//      `insertIntoManagedObjectContext`
//
//          let myUser = User(insert: true)
//
// The last is the one I went with, but I'm open to descussion on the point. I've left
// the source for the others commented out.
//
// Also worth noting, Coyner gives another option, using a factory method and generics. This
// is nice, except that thanks to Swift's super strict typing, you must specify the type
// of your variable:
//
//          let myUser: User = User.build()
//
// I'm not totally opposed to this option either.
//
// == Anyway, TLDR: ==
// If you get a runtime error like `unrecognized selector sent to instance`,
// it is probably because you tried to use the default initializer and not the one
// provided here.
extension NSManagedObject {
    
//    convenience init(entityName: String){
//        let context = RKManagedObjectStore.defaultStore().mainQueueManagedObjectContext
//        let entity = NSEntityDescription.entityForName(entityName, inManagedObjectContext: context)!
//        self.init(entity: entity, insertIntoManagedObjectContext: context)
//    }
    
    convenience init(insert: Bool) {
        if insert {
            let entityName = self.dynamicType.entityName()
            let context = RKManagedObjectStore.defaultStore().mainQueueManagedObjectContext
            let entity = NSEntityDescription.entityForName(entityName, inManagedObjectContext: context)!
            self.init(entity: entity, insertIntoManagedObjectContext: context)
        }else{
            self.init()
        }
    }
    
//    convenience init(dummyProperty: AnyObject?){
//        let entityName = self.dynamicType.entityName()
//        let context = RKManagedObjectStore.defaultStore().mainQueueManagedObjectContext
//        let entity = NSEntityDescription.entityForName(entityName, inManagedObjectContext: context)!
//        self.init(entity: entity, insertIntoManagedObjectContext: context)
//    }
    
    public class func entityName() -> String {
        // NSStringFromClass is available in Swift 2.
        // If the data model is in a framework, then
        // the module name needs to be stripped off.
        //
        // Example:
        //   FooBar.Engine
        //   Engine
        let name = NSStringFromClass(self)
        return name.componentsSeparatedByString(".").last!
    }
    
//    static func build<T: NSManagedObject>() -> T {
//        let context = RKManagedObjectStore.defaultStore().mainQueueManagedObjectContext
//        guard let object = NSEntityDescription.insertNewObjectForEntityForName(T.entityName(), inManagedObjectContext: context) as? T
//            else { fatalError("Invalid Core Data Model.") }
//        return object
//    }
}