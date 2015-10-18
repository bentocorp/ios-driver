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

class LoginViewController: UIViewController, CLLocationManagerDelegate, SocketHandlerDelegate, UITextFieldDelegate {
    
    var usernameTextField: UITextField?
    var passwordTextField: UITextField?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // background color
        self.view.backgroundColor = UIColor.darkGrayColor()
        
        // username textfield
        self.usernameTextField = UITextField(frame: CGRectMake(20, 200, self.view.frame.width - 40, 40))
        self.usernameTextField!.layer.cornerRadius = 3
        self.usernameTextField!.placeholder = "username"
        self.usernameTextField!.backgroundColor = UIColor.whiteColor()
        self.view.addSubview(self.usernameTextField!)
        
        // username placeholder padding
        let paddingView = UIView(frame: CGRectMake(0, 0, 15, usernameTextField!.frame.height))
        usernameTextField!.leftView = paddingView
        usernameTextField!.leftViewMode = UITextFieldViewMode.Always
        
        // password textfield
        self.passwordTextField = UITextField(frame: CGRectMake(20, 200 + 40 + 5, self.view.frame.width - 40, 40))
        self.passwordTextField!.layer.cornerRadius = 3
        self.passwordTextField!.placeholder = "password"
        self.passwordTextField!.backgroundColor = UIColor.whiteColor()
        self.passwordTextField!.secureTextEntry = true
        self.view.addSubview(self.passwordTextField!)
    
        // password placeholder padding
        let paddingView2 = UIView(frame: CGRectMake(0, 0, 15, passwordTextField!.frame.height))
        passwordTextField!.leftView = paddingView2
        passwordTextField!.leftViewMode = UITextFieldViewMode.Always
        
        // login button
        let loginButton = UIButton(frame: CGRectMake(20, 200 + 80 + 10, self.view.frame.width - 40, 40))
        loginButton.backgroundColor = UIColor.grayColor()
        loginButton.layer.cornerRadius = 3
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
        User.currentUser.login(self.usernameTextField!.text!, password: self.passwordTextField!.text!)
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
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.usernameTextField?.resignFirstResponder()
        self.passwordTextField?.resignFirstResponder()
        return true;
    }
}
