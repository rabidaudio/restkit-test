//
//  FixdError.swift
//  restkit-test
//
//  Created by fixd on 1/23/16.
//  Copyright © 2016 fixd. All rights reserved.
//

import Foundation
import RestKit

// define custom errors to throw here
enum FixdError : ErrorType {
    
    case InvalidParseResult(result: RKMappingResult)
    
    case Fuck
    
    // shortcut method for getting Fixd API error info from restkit responses
    static func getErrorInfo(error: ErrorType) -> [NSObject: AnyObject]? {
        guard let e = (error as NSError).userInfo[RKObjectMapperErrorObjectsKey]?.firstObject as? RKErrorMessage else {
            return nil
        }
        return e.userInfo
    }
    
    static func handleError(error: ErrorType) {
        if let info = getErrorInfo(error), let type = info["type"] as? String {
            switch type{
            case "NOT_AUTHENTICATED":
                // TODO redirect to Login Screen
                print("not logged in!")
            default:
                // any other error is a problem with the code
                print("api error detected: \(info["type"]) \(info["id"]) -> \(info["message"])")
            }
        }else{
            // some other (non-API) error
            debugPrint("other error", error)
        }
    }
    
    static func isUnauthenticated(error: ErrorType) -> Bool {
        guard let type = getErrorInfo(error)?["type"] as? String else {
            return false
        }
        return type == "NOT_AUTHENTICATED"
    }
}

//class ApiError {
//    
////    enum Type: String, StringEnum {
////        case NotFound = "NOT_FOUND"
////        case Forbidden = "FORBIDDEN"
////        case NotAuthenticated = "NOT_AUTHENTICATED"
////        case NoSuchRoute = "NO_SUCH_ROUTE"
////        case BadFormat = "BAD_FORMAT"
////        case ServerError = "SERVER_ERROR"
////        case Unknown = ""
////        
////        static let defaultValue: StringEnum? = Type.Unknown
////    }
//    
////    var type: Type {
////        get {
////            guard let t = type_, let tt = Type(rawValue: t) else {
////                return Type.Unknown
////            }
////            return tt
////        }
////        set {
////            type_ = newValue.rawValue
////        }
////    }
//    
//    static var objectMapping: RKObjectMapping {
//        let mapping = RKObjectMapping(forClass: ApiError.self)
//        mapping.addAttributeMappingsFromDictionary(["id": "id", "message": "errorMessage"])
//        let typeMapping = RKAttributeMapping(fromKeyPath: "type", toKeyPath: "type")
//        typeMapping.valueTransformer = StringToEnumTransformer()
//        return mapping
//    }
//    
//    var type: Type?
//    
//    var id: String?
//    
////    var userInfo: [NSObject: AnyObject]! = ["type": type.rawValue, "id": id!]
//}