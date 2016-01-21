//
//  Gist.swift
//  restkit-test
//
//  Created by fixd on 1/20/16.
//  Copyright © 2016 fixd. All rights reserved.
//

import Foundation
import RestKit

class Gist : NSManagedObject {
    
    @NSManaged var gistId: Int
    @NSManaged var url: NSURL
    @NSManaged var htmlUrl: NSURL
    @NSManaged var descriptionText: String
    @NSManaged var isPublic: Bool
    @NSManaged var createdAt: NSDate
    @NSManaged var updatedAt: NSDate
    @NSManaged var files: [File]
    @NSManaged var user: User
    
    private let formatter = NSDateFormatter()
    
//    init(id: Int, url: String, htmlUrl: String, description: String, isPublic: Bool, createdAt: String, updatedAt: String){
//        self.id = id
//        self.url = NSURL(string: url)!
//        self.htmlUrl = NSURL(string: htmlUrl)!
//        self.descriptionText = description
//        self.isPublic = isPublic
//        //formatter.timeZone = NSTimeZone(name: "GMT")
//        // NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
//        //[formatter setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
//        ///[formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"];
//        //NSDate *date = [formatter dateFromString:@"2011-01-12T14:17:55.043Z"];
//        //NSLog(@"Date: %@", date);
//        //formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z" //2013-02-12T22:58:52Z
//        formatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
//        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ" //2013-02-12T22:58:52Z
//        self.createdAt = formatter.dateFromString(createdAt)!
//        self.updatedAt = formatter.dateFromString(updatedAt)!
//    }
    
    func titleText() -> String {
        let size = descriptionText.startIndex.distanceTo(descriptionText.endIndex)
        let maxSize = 20
        return (size < maxSize ? descriptionText : descriptionText.substringToIndex(descriptionText.startIndex.advancedBy(maxSize)))
    }
    
    func subtitleText() -> String {
        return "by \(user.login) at \(formatter.stringFromDate(createdAt)) (\(files.count) files)"
    }
}