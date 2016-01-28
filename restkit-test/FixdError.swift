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
    
    case UnexpectedResultType
    
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
                fatalError("api error detected: \(info["type"]) \(info["id"]) -> \(info["message"])")
                
            }
        }else{
            // some other (non-API) error
            debugPrint("other error", error)
            fatalError()
        }
    }
    
    static func isUnauthenticated(error: ErrorType) -> Bool {
        guard let type = getErrorInfo(error)?["type"] as? String else {
            return false
        }
        return type == "NOT_AUTHENTICATED"
    }
}