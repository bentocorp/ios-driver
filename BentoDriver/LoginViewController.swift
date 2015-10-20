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
    let progressHUD = JGProgressHUD(style: JGProgressHUDStyle.Dark)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UIApplication.sharedApplication().statusBarStyle = .LightContent
        
        // background color
//        self.view.backgroundColor = UIColor(red: 0.3176, green: 0.7098, blue: 0.3294, alpha: 1.0)
        
        // background image
        let backgroundImage = UIImageView(frame: CGRectMake(0, 0, self.view.frame.width, self.view.frame.height))
        backgroundImage.image = UIImage(named: "grass")
        backgroundImage.contentMode = .ScaleAspectFill
        self.view.addSubview(backgroundImage)
        
        // backgroud view
        let backgroundView = UIView(frame: CGRectMake(0, 0, self.view.frame.width, 350))
        backgroundView.center = self.view.center
        self.view.addSubview(backgroundView)
        
        // logo
        let logoImageView = UIImageView(frame: CGRectMake(20, 20, self.view.frame.width - 40, 100))
        logoImageView.contentMode = UIViewContentMode.ScaleAspectFit
        logoImageView.image = UIImage(named: "logo")
        backgroundView.addSubview(logoImageView)
        
        // username textfield
        self.usernameTextField = UITextField(frame: CGRectMake(20, 20 + 100 + 60, self.view.frame.width - 40, 50))
        self.usernameTextField!.layer.cornerRadius = 1
        self.usernameTextField!.textColor = UIColor(red: 0.3137, green: 0.549, blue: 0.3098, alpha: 1.0)
        self.usernameTextField!.placeholder = "username"
        self.usernameTextField!.font = UIFont(name: "OpenSans-Regular", size: 17)
        self.usernameTextField!.text?.lowercaseString
        self.usernameTextField!.autocapitalizationType = UITextAutocapitalizationType.None
        self.usernameTextField!.backgroundColor = UIColor.whiteColor()
        self.usernameTextField!.keyboardType = UIKeyboardType.EmailAddress
        self.usernameTextField!.clearButtonMode = UITextFieldViewMode.WhileEditing
        self.usernameTextField?.tintColor = UIColor(red: 0.3137, green: 0.549, blue: 0.3098, alpha: 1.0)
        self.usernameTextField!.delegate = self
        backgroundView.addSubview(self.usernameTextField!)
        
        // username padding
        let paddingView = UIView(frame: CGRectMake(0, 0, 15, usernameTextField!.frame.height))
        usernameTextField!.leftView = paddingView
        usernameTextField!.leftViewMode = UITextFieldViewMode.Always
        
        // password textfield
        self.passwordTextField = UITextField(frame: CGRectMake(20, self.usernameTextField!.frame.origin.y + 51, self.view.frame.width - 40, 50))
        self.passwordTextField!.layer.cornerRadius = 1
        self.passwordTextField!.textColor = UIColor(red: 0.3137, green: 0.549, blue: 0.3098, alpha: 1.0)
        self.passwordTextField!.placeholder = "password"
        self.passwordTextField!.font = UIFont(name: "OpenSans-Regular", size: 17)
        self.passwordTextField!.autocapitalizationType = UITextAutocapitalizationType.None
        self.passwordTextField!.backgroundColor = UIColor.whiteColor()
        self.passwordTextField!.secureTextEntry = true
        self.passwordTextField!.clearButtonMode = UITextFieldViewMode.WhileEditing
        self.passwordTextField?.tintColor = UIColor(red: 0.3137, green: 0.549, blue: 0.3098, alpha: 1.0)
        self.passwordTextField!.delegate = self
        backgroundView.addSubview(self.passwordTextField!)
    
        // password padding
        let paddingView2 = UIView(frame: CGRectMake(0, 0, 15, passwordTextField!.frame.height))
        passwordTextField!.leftView = paddingView2
        passwordTextField!.leftViewMode = UITextFieldViewMode.Always
        
        // login button
        let loginButton = UIButton(frame: CGRectMake(20, self.passwordTextField!.frame.origin.y + 70, self.view.frame.width - 40, 50))
        loginButton.backgroundColor = UIColor.clearColor()
        loginButton.titleLabel!.font = UIFont(name: "OpenSans-SemiBold", size: 17)
        loginButton.layer.cornerRadius = 3
        loginButton.setTitle("LOGIN", forState: .Normal)
        loginButton.addTarget(self, action: "onLogin", forControlEvents: .TouchUpInside)
        backgroundView.addSubview(loginButton)
    }
    
    override func viewWillAppear(animated: Bool) {
        // set as SocketHandler's delegate -> putting in viewwillappear because delegate methods won't get called again if i log out and try to login again
        SocketHandler.sharedSocket.delegate = self
        
        self.navigationController?.navigationBarHidden = true
        
        // check if logged in user, if not reset textfields
        if NSUserDefaults.standardUserDefaults().objectForKey("username") == nil {
            NSUserDefaults.standardUserDefaults().setObject("", forKey: "username")
            NSUserDefaults.standardUserDefaults().setObject("", forKey: "password")
            NSUserDefaults.standardUserDefaults().synchronize()
        }
        
        // set textfield text -> either empty strings to username and password
        self.usernameTextField!.text = NSUserDefaults.standardUserDefaults().objectForKey("username") as? String
        self.passwordTextField!.text = NSUserDefaults.standardUserDefaults().objectForKey("password") as? String
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func onLogin() {
        if self.usernameTextField!.text == "" || self.passwordTextField!.text == "" {
            // username and password fields empty
            self.promptAlertWith("Please enter both your username and password", style: .Cancel)
            return
        }
        
        self.progressHUD.textLabel.text = "Logging in..."
        self.progressHUD.showInView(self.view)
        
        User.currentUser.login(self.usernameTextField!.text!, password: self.passwordTextField!.text!)
    }
    
//MARK: SocketHandlerDelegate Method
    func socketHandlerDidConnect(connected: Bool) {
        if connected == false {
            self.promptAlertWith("Could not connect to Node server", style: UIAlertActionStyle.Cancel)
        }
        
        self.progressHUD.dismiss()
    }
    
    func socketHandlerDidDisconnect() {
        // handler disconnect
    }
    
    func socketHandlerDidAuthenticate(authenticated: Bool) {
        if authenticated {
            // TODO: check if connected already. if yes, don't prompt alert...
//            self.promptAlertWith("Authentication Succeeded", style: UIAlertActionStyle.Default)
            let navC = UINavigationController.init(rootViewController: OrderListViewController())
            self.navigationController?.presentViewController(navC, animated: true, completion: nil)
        }
        else {
            self.promptAlertWith("Authentication Failed", style: UIAlertActionStyle.Cancel)
        }
    }
    
    func socketHandlerDidRecievePushNotification(push: Push) {
        // handle push
    }

//MARK: Alert
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
    
//MARK: UITextfieldDelegate
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.usernameTextField?.resignFirstResponder()
        self.passwordTextField?.resignFirstResponder()
        return true;
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    //
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
}
