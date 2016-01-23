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
        print("response descriptors", manager.responseDescriptors.count, manager.responseDescriptors)
        manager.getObjectsAtPath("vehicles", parameters: ["user_email": "julian@fixdapp.com"], success: gotVehicles, failure: failedGetVehicles)
    }
    
    func gotVehicles(operation: RKObjectRequestOperation!, result: RKMappingResult!) {
        print("done")
        print(result)
        refreshView.stopAnimating()
        refreshView.hidden = true
        
        for data in result.array() {
            if let vehicle = data as? Vehicle {
                print("GOT A VEHICLE")
                print("vin: ", vehicle.vin)
                print("users: ", vehicle.users?.allObjects)
            }else{
                print("THIS THING AINT A VEHICLE", data)
            }
        }
    }
    
    func failedGetVehicles(operation: RKObjectRequestOperation!, err: NSError!) {
        print("err", err)
        let alertController = UIAlertController(title: "Error", message: err.description, preferredStyle: UIAlertControllerStyle.Alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alertController, animated: true, completion: nil)
    }
}