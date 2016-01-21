//
//  User.swift
//  restkit-test
//
//  Created by fixd on 1/20/16.
//  Copyright © 2016 fixd. All rights reserved.
//

import Foundation
import RestKit

class User : NSManagedObject {
    
    @NSManaged var avatarUrl: NSURL
    @NSManaged var gravatarId: String
    @NSManaged var jsonUrl: NSURL
    @NSManaged var login: String
    @NSManaged var userId: Int
    @NSManaged var gists: [Gist]
}