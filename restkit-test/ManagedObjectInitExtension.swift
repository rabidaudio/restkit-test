//
//  ManagedObjectInitExtension.swift
//  restkit-test
//
//  Created by fixd on 1/27/16.
//  Copyright © 2016 fixd. All rights reserved.
//

import Foundation
import CoreData

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
    //        let context = FixdApi.mainQueueContext()
    //        let entity = NSEntityDescription.entityForName(entityName, inManagedObjectContext: context)!
    //        self.init(entity: entity, insertIntoManagedObjectContext: context)
    //    }
    
    convenience init(insert: Bool) {
        if insert {
            let entityName = self.dynamicType.entityName()
            let context = FixdApi.mainQueueContext()
            let entity = NSEntityDescription.entityForName(entityName, inManagedObjectContext: context)!
            self.init(entity: entity, insertIntoManagedObjectContext: context)
        }else{
            self.init()
        }
    }
    
    //    convenience init(dummyProperty: AnyObject?){
    //        let entityName = self.dynamicType.entityName()
    //        let context = FixdApi.mainQueueContext()
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
    //        let context = FixdApi.mainQueueContext()
    //        guard let object = NSEntityDescription.insertNewObjectForEntityForName(T.entityName(), inManagedObjectContext: context) as? T
    //            else { fatalError("Invalid Core Data Model.") }
    //        return object
    //    }
}