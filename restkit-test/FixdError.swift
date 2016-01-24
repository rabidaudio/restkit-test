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
}