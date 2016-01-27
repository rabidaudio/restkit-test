//
//  Model.swift
//  restkit-test
//
//  Created by fixd on 1/22/16.
//  Copyright © 2016 fixd. All rights reserved.
//

import Foundation
import RestKit
import Pluralize_swift

// This is a helper class for initialzing CoreData/RestKit for our models.
//
// Children can simply set an initializer which calls the big initializer
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
    
    let requestKeyPath: String
    let responseKeyPath: String
    
    let entityMapping: RKEntityMapping
    
    init(type: NSManagedObject.Type, resourceName: String, idAttributes: [String] = ["id"], indexPaths: [String], requestKeyPath: String? = nil, responseKeyPath: String = "data", paramMappings: [String: String]){
        self.type = type
        self.entityName = type.entityName()
        self.resourceName = resourceName
        self.idAttributes = idAttributes
        self.indexPaths = indexPaths
        self.requestKeyPath = (requestKeyPath == nil ? entityName.toSnakeCase() : requestKeyPath!)
        self.responseKeyPath = responseKeyPath
        self.paramMappings = paramMappings
        
        self.entityMapping = RKEntityMapping(forEntityForName: entityName, inManagedObjectStore: RKManagedObjectStore.defaultStore())
        entityMapping.addAttributeMappingsFromDictionary(paramMappings)
    }
    
    // Simplifies the setup of models even further by inferring key path, json key, and resource names
    // Assumptions:
    //  1. Type name is the same as CoreData entity name, CapitalizedCamelCase, singular e.g. ServiceRecord
    //  2. CoreData attributes match the names of JSON keys, except that Swift parameters are lowerCamelCase (serviceRecord) and JSON keys are lower_snake_case (service_record)
    //  3. requestKeyPath (unless included) is lower_snake_case (service_record)
    //  4. responseKeyPath (unless included) is 'data'
    //  4. indexPath (unless provided) is pluralized_snake_case (service_records)
    // Failing any of these, you should use the other constructor
    init(type: NSManagedObject.Type, idAttributes: [String] = ["id"], indexPaths: [String]? = nil, requestKeyPath: String? = nil, responseKeyPath: String? = "data", params: [String]) {
        let name = type.entityName()
        let camelCasedName = name.lowerFirstLetter()
        let snakeCasedName = camelCasedName.toSnakeCase()
        let pluralizedSnake = camelCasedName.pluralize().toSnakeCase()
        var paramMappings = [String:String]()
        params.forEach { p in paramMappings[p.toSnakeCase()] = p }
        
        self.type = type
        self.entityName = name
        self.resourceName = pluralizedSnake
        self.idAttributes = idAttributes
        self.indexPaths = (indexPaths == nil ? [self.resourceName] : indexPaths!)
        self.requestKeyPath = (requestKeyPath == nil ? snakeCasedName : requestKeyPath!)
        self.responseKeyPath = (responseKeyPath == nil ? snakeCasedName : responseKeyPath!)
        self.paramMappings = paramMappings
        
        self.entityMapping = RKEntityMapping(forEntityForName: entityName, inManagedObjectStore: RKManagedObjectStore.defaultStore())
        entityMapping.addAttributeMappingsFromDictionary(paramMappings)
    }
    
    var requestDescriptors: [RKRequestDescriptor] {
        let mapping = RKObjectMapping(forClass: NSMutableDictionary.self)
        mapping.addAttributeMappingsFromDictionary(reverseParamMappings)
        return [RKRequestDescriptor(mapping: mapping, objectClass: type, rootKeyPath: requestKeyPath, method: .Any)]
    }
    
    var responseDescriptors: [RKResponseDescriptor] {
        var descriptors = [RKResponseDescriptor]()
        let successfulCodes = RKStatusCodeIndexSetForClass(.Successful)
        for route in routeSet {
            let crudDescriptor = RKResponseDescriptor(mapping: entityMapping, method: route.method, pathPattern: route.pathPattern, keyPath: responseKeyPath, statusCodes: successfulCodes)
            descriptors.append(crudDescriptor)
        }
        for indexPath in indexPaths {
            let indexResponseDescriptor = RKResponseDescriptor(mapping: entityMapping, method: .GET, pathPattern: indexPath, keyPath: responseKeyPath, statusCodes: successfulCodes)
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
    
    // Any relationships to other models you need to add should be done in the constructor
    //
    //  If the other object data is included (nested) in the response
    func addIncludedMapping(otherModel: Model, toMany: Bool){
        var destKeyPath = otherModel.entityName.lowerFirstLetter()
        var srcKeyPath = destKeyPath.toSnakeCase()
        if(toMany){
            destKeyPath = destKeyPath.pluralize()
            srcKeyPath = srcKeyPath.pluralize()
        }
        entityMapping.addPropertyMapping(RKRelationshipMapping(fromKeyPath: srcKeyPath, toKeyPath: destKeyPath, withMapping: otherModel.entityMapping))
    }
    
    //  If only the ID is included
    //  1. Add a property to the source entity in CoreData and mark it as "transient" (e.g. Post.userId)
    //  2. Include the property in your paramMappings (e.g. PostParamMappings = ["user_id": "userId"])
    func addIDMapping(otherModel: Model, onKey: String){
        let relationshipName = otherModel.entityName.lowercaseString
        entityMapping.addConnectionForRelationship(relationshipName, connectedBy: [onKey: otherModel.idAttributes.first!])
    }
}

extension String {
    private func toSnakeCase() -> String {
        var result = ""
        for c in self.lowerFirstLetter().characters {
            let sc = String(c)
            if sc == sc.lowercaseString {
                result += sc
            }else{
                result += "_\(sc.lowercaseString)"
            }
        }
        return result
    }
    
    private func lowerFirstLetter() -> String {
        var clone = String(self)
        let firstLetter = clone.removeAtIndex(clone.startIndex)
        return String(firstLetter).lowercaseString + clone
    }
}