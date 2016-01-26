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
        
        if !UserModel.loggedIn {
            //todo log out performSegueWithIdentifier(<#T##identifier: String##String#>, sender: self)
        }
        
        refreshView.startAnimating()
        loadVehicles()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadVehicles() {
        let manager = RKObjectManager.sharedManager()
        
        UserModel.fetchCurrentUser().then { user in
            return manager.getAllObjectsForPathPatternWithPromise("vehicles", parameters: ["user_email": user!.email!])
        }.then { response -> Vehicle? in
//        manager.getObjectsAtPathWithPromise("vehicles", parameters: ["user_email": email]).then { response -> Void in
            print("done")
            print(response)
            self.refreshView.stopAnimating()
            self.refreshView.hidden = true
            for data in response.results {
                if let vehicle = data as? Vehicle {
                    print("GOT A VEHICLE", vehicle)
                }else{
                    print("THIS THING AINT A VEHICLE", data)
                }
            }
            return response.results.first as! Vehicle?
        }.then { vehicle -> Promise<PagedResponse> in
            if vehicle != nil {
                return manager.getAllObjectsForPathPatternWithPromise("mileages", parameters: ["vehicle_vin": vehicle!.vin!])
            }else{
                return Promise<PagedResponse>(PagedResponse(paginator: nil, results: [], page: 0))
            }
        }.then { response -> Promise<Response> in
            guard let mileages = response.results as! [Mileage]? else {
                return Promise(Response(operation: nil, result: nil))
            }
            for mileage in mileages {
                print("mileage: ", mileage.miles, mileage.vehicle?.vin)
            }
            
//            let m: Mileage = Mileage.build()
            let m = Mileage(insert: true)
            
            
//            let num = NSNumber(integer: 10)
//            m.miles = num
//            m.setValue(num, forKey: "miles")
            m.miles = 300_000
            m.timestamp = NSDate()
            m.user = UserModel.currentUser
            m.source = .UserSubmitted
            let vehicle = mileages.first!.vehicle
            m.vehicle = vehicle
            print(vehicle, m.vehicle, vehicle!.vin)
            return manager.postObjectWithPromise(m, path: nil, parameters: ["vehicle_vin": vehicle!.vin!])
        }.then { response -> Promise<Response> in
            if let mileage: Mileage = response.firstResult() {
                print("Created Mileage!", mileage)
                mileage.miles = 10_000
                return manager.putObjectWithPromise(mileage, path: nil, parameters: nil)
            }else{
                print("oh shit")
                throw FixdError.Fuck
            }
        }.then { response -> Promise<Response> in
            if let mileage: Mileage = response.firstResult() {
                print("Updated Mileage", mileage.miles)
                
                return manager.deleteObjectWithPromise(mileage, path: nil, parameters: nil)
            }else{
                throw FixdError.Fuck
            }
        }.then { response -> Void in
            if let mileage: Mileage = response.firstResult() {
                print("Deleted!", mileage)
            }else{
                throw FixdError.Fuck
            }
        }.error(FixdError.handleError)
            
            
//            let context = AppDelegate.context()
            
            //        let allUsersRequest = NSFetchRequest(entityName: "User")
            
//            print("requesting local")
//            print("got vehices locally", User.currentUser?.vehicles)
//            if let user = Model.localQueryFor("User", withPredicate: "email LIKE %@", andArguments: [email]).first {
//                print("got vehices locally", user.vehicles)
//            }
            
            
            
//            let userRequset = NSFetchRequest(entityName: "User")
//            let email = "julian@fixdapp.com"
//            userRequset.predicate = NSPredicate(format: "email LIKE %@", email)
            
            
//            do {
//                //            let allUsersResults = try context.executeFetchRequest(allUsersRequest)
//                //            print(allUsersResults)
//                
//                let userResults = try context.executeFetchRequest(userRequset)
//                if let user = userResults.first as? User {
//                    print("got vehices locally", user.vehicles)
//                }else{
//                    print("problem fetching:", userResults)
//                }
//            }catch {
//                print("problem fetching: \(error)")
//            }
//        }
//        manager.getObject(nil, path: "vehicles/4T1BG22K1YU653452", parameters: nil, success: gotVehicles, failure: failedGetVehicles)
    }
}