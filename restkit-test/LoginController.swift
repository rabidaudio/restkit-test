//
//  LoginController.swift
//  restkit-test
//
//  Created by fixd on 1/23/16.
//  Copyright © 2016 fixd. All rights reserved.
//

import UIKit
import RestKit
import PromiseKit

class LoginController: UIViewController {
    
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        showForm(false)
        
        let manager = RKObjectManager.sharedManager()
//        let currentUser = User.currentUser
        if(!UserModel.loggedIn){
            showForm(true)
        }else{
            // double check that we are still logged in
            manager.getObjectWithPromise(nil, path: "", parameters: nil).then { data -> Void in
                self.continueToApp()
            }.error { err -> Void in
                if let e = FixdError.getErrorInfo(err) {
                    print("data: ", e)
                }
                self.emailField.text = UserModel.lastUserEmail //currentUser!.email // go ahead and fill in their email if we have it
                self.showForm(true)
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func login(sender: AnyObject) {
        let email = emailField.text
        let password = passwordField.text
        if(email == nil || email!.isEmpty){
            // todo email?.containsString("@")
            print("invalid")
        }else if(password == nil && password!.isEmpty){
            //todo
            print("invalid")
        }else{
            loginButton.hidden = true
            loadingIndicator.hidden = false
            loadingIndicator.startAnimating()
            UserModel.login(email!, password: password!).then { user -> Void in
                self.continueToApp()
            }.always {
                self.loadingIndicator.stopAnimating()
                self.loginButton.hidden = false
                self.loadingIndicator.hidden = true
            }.error { err in
                if FixdError.isUnauthenticated(err){
                    // show invalid login
                }else{
                    FixdError.handleError(err)
                }
            }
        }
    }
    
    func showForm(visible: Bool){
        [emailField, passwordField, loginButton].forEach { $0.hidden = !visible }
        loadingIndicator.hidden = visible
    }
    
    func continueToApp(){
        performSegueWithIdentifier("login", sender: self)
    }
    
    @IBAction func unwindToLogin(unwindSegue: UIStoryboardSegue) {
        UserModel.logout()
    }
}