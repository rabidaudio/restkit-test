//
//  LoadingViewController.swift
//  restkit-test
//
//  Created by fixd on 1/22/16.
//  Copyright © 2016 fixd. All rights reserved.
//

import UIKit
import RestKit
import PromiseKit

class LoadingViewController: UIViewController {
    
    @IBOutlet weak var refreshView: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if !CurrentUser.loggedIn {
            //todo log out performSegueWithIdentifier(<#T##identifier: String##String#>, sender: self)
        }
        
        loadVehicles()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadVehicles() {
        let manager = RKObjectManager.sharedManager()
        
        CurrentUser.fetchCurrentUser().then { user in
            return manager.getAllObjectsForPathPatternWithPromise("vehicles", parameters: ["user_email": user!.email!])
        }.then { response -> Vehicle? in
            print("done")
            print(response)
            guard let vehicles = response as? [Vehicle] else { throw FixdError.Fuck }
            for vehicle in vehicles {
                print("GOT A VEHICLE", vehicle)
            }
            return vehicles.first
        }.then { vehicle -> Promise<[AnyObject]?> in
            if vehicle != nil {
                return manager.getAllObjectsForPathPatternWithPromise("mileages", parameters: ["vehicle_vin": vehicle!.vin!])
            }else{
                throw FixdError.Fuck
            }
        }.then { response -> Promise<AnyObject?> in
            guard let mileages = response as! [Mileage]? else {
                throw FixdError.Fuck
            }
            for mileage in mileages {
                print("mileage: ", mileage.miles, mileage.vehicle?.vin)
            }
            
            let m = Mileage(insert: true)
            
            m.miles = 300_000
            m.timestamp = NSDate()
            m.user = CurrentUser.currentUser
            m.sourceEnum = Mileage.Source.UserSubmitted
            let vehicle = mileages.first!.vehicle
            m.vehicle = vehicle
            print(vehicle, m.vehicle, vehicle!.vin)
            return manager.postObjectWithPromise(m, path: nil, parameters: ["vehicle_vin": vehicle!.vin!])
        }.then { response -> Promise<AnyObject?> in
            guard let mileage = response as? Mileage else {
                throw FixdError.Fuck
            }
            print("Created Mileage!", mileage)
            mileage.miles = 10_000
            return manager.putObjectWithPromise(mileage, path: nil, parameters: nil)
        }.then { response -> Promise<AnyObject?> in
            guard let mileage = response as? Mileage else {
                throw FixdError.Fuck
            }
            print("Updated Mileage", mileage.miles)
            
            return manager.deleteObjectWithPromise(mileage, path: nil, parameters: nil)
        }.then { response -> Void in
            guard let mileage = response as? Mileage else {
                throw FixdError.Fuck
            }
            print("Deleted!", mileage)
        }.error(FixdError.handleError)
    }
}