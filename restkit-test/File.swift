//
//  File.swift
//  restkit-test
//
//  Created by fixd on 1/20/16.
//  Copyright © 2016 fixd. All rights reserved.
//

import Foundation
import RestKit

class File : Model {
    
    @NSManaged var filename: String
    @NSManaged var rawUrl: NSURL
    @NSManaged var size: Int
    @NSManaged var gist: Gist
}