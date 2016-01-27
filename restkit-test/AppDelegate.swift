//
//  AppDelegate.swift
//  restkit-test
//
//  Created by fixd on 1/20/16.
//  Copyright © 2016 fixd. All rights reserved.
//

import UIKit
import CoreData
import RestKit
import PromiseKit
import AFNetworking

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        //initialize RestKit/CoreData
        FixdApi.setUp()
        
        return true
    }
}

//class StringToEnumTransformer: NSObject, RKValueTransforming {
//    @objc func transformValue(inputValue: AnyObject!, toValue outputValue: AutoreleasingUnsafeMutablePointer<AnyObject?>, ofClass outputValueClass: AnyClass!) throws {
//        let rawValue = inputValue as! String
//        let outClass = outputValueClass as! StringEnum.Type
//        let outputEnum = outClass.init(rawValue: rawValue)
//        if outputEnum == nil {
//            outputValue.memory = (outClass.defaultValue as! AnyObject?)
//        }else{
//            outputValue.memory = (outputEnum as! AnyObject)
//        }
//    }
//    
//    @objc func validateTransformationFromClass(inputValueClass: AnyClass!, toClass outputValueClass: AnyClass!) -> Bool {
//        return (inputValueClass as? String.Type != nil) && (outputValueClass as? StringEnum.Type != nil) && (outputValueClass as? String.Type != nil)
//    }
//}
//
//protocol StringEnum {
//    init?(rawValue: String) //the raw value initializer (enums have it, no need to implement)
//    static var defaultValue: StringEnum? { get } // the value to return if given an invalid string input. Can be nil
//}
