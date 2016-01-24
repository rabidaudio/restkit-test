//
//  LoadingViewController.swift
//  restkit-test
//
//  Created by fixd on 1/22/16.
//  Copyright © 2016 fixd. All rights reserved.
//

import UIKit
import RestKit

class LoadingViewController: UIViewController {
    
    @IBOutlet weak var refreshView: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        refreshView.startAnimating()
        loadVehicles()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadVehicles() {
        let manager = RKObjectManager.sharedManager()
        
        manager.getObjectsAtPath("vehicles", parameters: ["user_email": "julian@fixdapp.com"], success: gotVehicles, failure: failedGetVehicles)
//        manager.getObject(nil, path: "vehicles/4T1BG22K1YU653452", parameters: nil, success: gotVehicles, failure: failedGetVehicles)
    }
    
    func gotVehicles(operation: RKObjectRequestOperation!, result: RKMappingResult!) {
        print("done")
        print(result)
        refreshView.stopAnimating()
        refreshView.hidden = true
        
        for data in result.array() {
            if let vehicle = data as? Vehicle {
                print("GOT A VEHICLE", vehicle)
            }else{
                print("THIS THING AINT A VEHICLE", data)
            }
        }
    }
    
    func failedGetVehicles(operation: RKObjectRequestOperation!, err: NSError!) {
        print("err", err)
        
        let context = AppDelegate.context()
        
//        let allUsersRequest = NSFetchRequest(entityName: "User")
        
        let userRequset = NSFetchRequest(entityName: "User")
        let email = "julian@fixdapp.com"
        userRequset.predicate = NSPredicate(format: "email LIKE %@", email)
        
        print("requesting local")
        do {
//            let allUsersResults = try context.executeFetchRequest(allUsersRequest)
//            print(allUsersResults)
            
            let userResults = try context.executeFetchRequest(userRequset)
            if let user = userResults.first as? User {
                print("got vehices locally", user.vehicles)
            }else{
                print("problem fetching:", userResults)
            }
        }catch {
            print("problem fetching: \(error)")
        }
    }
}