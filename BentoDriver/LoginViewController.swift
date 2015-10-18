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
        
        // username textfield
        let usernameTextField = UITextField(frame: CGRectMake(20, 100, self.view.frame.width - 40, 40))
        usernameTextField.layer.cornerRadius = 3
        usernameTextField.placeholder = "username"
        usernameTextField.backgroundColor = UIColor.
        self.view.addSubview(usernameTextField)
        
        // password textfield
        let
        
        // login button
        let loginButton = UIButton(frame: CGRectMake(100, 100, 100, 100))
        loginButton.backgroundColor = UIColor.greenColor()
        loginButton.setTitle("Login", forState: .Normal)
        loginButton.addTarget(self, action: "onLogin", forControlEvents: .TouchUpInside)
        self.view.addSubview(loginButton)
    }
    
    override func viewWillAppear(animated: Bool) {
        // set as SocketHandler's delegate -> putting in viewwillappear because delegate methods won't get called again if i log out and try to login again
        SocketHandler.sharedSocket.delegate = self
        
        self.navigationController?.navigationBarHidden = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func onLogin() {
        User.currentUser.login("marc@bentonow.com", password: "wordpass")
    }
    
//MARK: SocketHandlerDelegate Method
    func socketHandlerDidConnect(connected: Bool) {
        if connected == false {
            self.promptAlertWith("Could not connect to Node server", style: UIAlertActionStyle.Cancel)
        }
    }
    
    func socketHandlerDidDisconnect() {
        // handler disconnect
    }
    
    func socketHandlerDidAuthenticate(authenticated: Bool) {
        if authenticated {
            // TODO: check if connected already. if yes, don't prompt alert...
            self.promptAlertWith("Authentication Succeeded", style: UIAlertActionStyle.Default)
        }
        else {
            self.promptAlertWith("Authentication Failed", style: UIAlertActionStyle.Cancel)
        }
    }
    
    func socketHandlerDidRecievePushNotification(push: Push) {
        // handle push
    }
    
    func promptAlertWith(messageString: String, style: UIAlertActionStyle) {
        let alertController = UIAlertController(title: "", message: messageString, preferredStyle: .Alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .Default, handler: { action in
            // go to Order List
            if style == .Default {
                let navC = UINavigationController.init(rootViewController: OrderListViewController())
                self.navigationController?.presentViewController(navC, animated: true, completion: nil)
            }
        }))
        self.presentViewController(alertController, animated: true, completion: nil)
    }
}
