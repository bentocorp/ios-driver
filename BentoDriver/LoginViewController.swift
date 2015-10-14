//
//  LoginViewController.swift
//  BentoDriver
//
//  Created by Joseph Lau on 10/9/15.
//  Copyright © 2015 Joseph Lau. All rights reserved.
//

import UIKit
import CoreLocation
import SwiftyJSON

class LoginViewController: UIViewController, CLLocationManagerDelegate, SocketHandlerDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // background color
        self.view.backgroundColor = UIColor.whiteColor()
        
        // set as SocketHandler's delegate
        SocketHandler.sharedSocket.delegate = self
        
        // login button
        let loginButton = UIButton(frame: CGRectMake(100, 100, 100, 100))
        loginButton.backgroundColor = UIColor.greenColor()
        loginButton.setTitle("Login", forState: .Normal)
        loginButton.addTarget(self, action: "onLogin", forControlEvents: .TouchUpInside)
        self.view.addSubview(loginButton)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func onLogin() {
        User.login("marc@bentonow.co", password: "wordpass")
    }
    
//MARK: SocketHandlerDelegate Method
    func userConnected(connected: Bool) {
        if connected == false {
            self.promptAlertWith("Could not connect to Node server")
        }
    }
    
    func userAuthenticated(authenticated: Bool) {
        if authenticated {
            self.promptAlertWith("Authenticated User")
        }
        else {
            self.promptAlertWith("Could not authenticate user")
        }
    }
    
    func promptAlertWith(messageString: String) {
        let alertController = UIAlertController(title: "", message: messageString, preferredStyle: .Alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
        self.presentViewController(alertController, animated: true, completion: nil)
    }
}
