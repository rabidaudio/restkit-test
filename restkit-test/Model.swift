//
//  Model.swift
//  restkit-test
//
//  Created by fixd on 1/22/16.
//  Copyright © 2016 fixd. All rights reserved.
//

import Foundation
import RestKit

protocol Model {
//    static var attributeMappings: [NSObject : AnyObject] { get }
//    static var idAttributeName: String { get }
    static var pathPatterns: [String] { get }
//    static var name: String { get }
//    static var sortDescriptors: [NSSortDescriptor] { get }
    static var entityMapping: RKEntityMapping { get }
}