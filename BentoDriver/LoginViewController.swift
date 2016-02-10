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
import PKHUD

class LoginViewController: UIViewController, CLLocationManagerDelegate, SocketHandlerDelegate, UITextFieldDelegate {
    
    var usernameTextField: UITextField!
    var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        #if DEBUG
            print("dev build")
        #else
            print("prod build")
        #endif
        
        UIApplication.sharedApplication().statusBarStyle = .LightContent
        UIApplication.sharedApplication().idleTimerDisabled = false // ok to lock screen
        
//MARK: Forced Update
        ForcedUpdate.sharedInstance.getForcedUpdateInfo { (success) -> Void in
            if success == true {
                self.checkForcedUpdate()
            }
        }
        
//MARK: Background Image
        let backgroundImage = UIImageView(frame: CGRectMake(0, 0, view.frame.width, view.frame.height))
        backgroundImage.image = UIImage(named: "grass")
        backgroundImage.contentMode = .ScaleAspectFill
        view.addSubview(backgroundImage)
        
//MARK: Background View
        let backgroundView = UIView(frame: CGRectMake(0, 0, view.frame.width, 350))
        backgroundView.center = view.center
        view.addSubview(backgroundView)
        
//MARK: Logo
        let logoImageView = UIImageView(frame: CGRectMake(20, 20, view.frame.width - 40, 100))
        logoImageView.contentMode = UIViewContentMode.ScaleAspectFit
        logoImageView.image = UIImage(named: "logo")
        backgroundView.addSubview(logoImageView)
        
//MARK: Username
        usernameTextField = UITextField(frame: CGRectMake(20, 20 + 100 + 60, view.frame.width - 40, 50))
        usernameTextField.layer.cornerRadius = 1
        usernameTextField.textColor = UIColor(red: 0.3137, green: 0.549, blue: 0.3098, alpha: 1.0)
        usernameTextField.placeholder = "username"
        usernameTextField.font = UIFont(name: "OpenSans-Regular", size: 17)
        usernameTextField.text!.lowercaseString
        usernameTextField.autocapitalizationType = UITextAutocapitalizationType.None
        usernameTextField.autocorrectionType = .No
        usernameTextField.backgroundColor = UIColor.whiteColor()
        usernameTextField.keyboardType = UIKeyboardType.EmailAddress
        usernameTextField.clearButtonMode = UITextFieldViewMode.WhileEditing
        usernameTextField.tintColor = UIColor(red: 0.3137, green: 0.549, blue: 0.3098, alpha: 1.0)
        usernameTextField.delegate = self
        backgroundView.addSubview(usernameTextField)
        
        // username padding
        let paddingView = UIView(frame: CGRectMake(0, 0, 15, usernameTextField.frame.height))
        usernameTextField.leftView = paddingView
        usernameTextField.leftViewMode = UITextFieldViewMode.Always
        
//MARK: Password
        passwordTextField = UITextField(frame: CGRectMake(20, usernameTextField.frame.origin.y + 51, view.frame.width - 40, 50))
        passwordTextField.layer.cornerRadius = 1
        passwordTextField.textColor = UIColor(red: 0.3137, green: 0.549, blue: 0.3098, alpha: 1.0)
        passwordTextField.placeholder = "password"
        passwordTextField.font = UIFont(name: "OpenSans-Regular", size: 17)
        passwordTextField.autocapitalizationType = UITextAutocapitalizationType.None
        passwordTextField.backgroundColor = UIColor.whiteColor()
        passwordTextField.secureTextEntry = true
        passwordTextField.clearButtonMode = UITextFieldViewMode.WhileEditing
        passwordTextField.tintColor = UIColor(red: 0.3137, green: 0.549, blue: 0.3098, alpha: 1.0)
        passwordTextField.delegate = self
        backgroundView.addSubview(passwordTextField)
    
        // password padding
        let paddingView2 = UIView(frame: CGRectMake(0, 0, 15, passwordTextField.frame.height))
        passwordTextField.leftView = paddingView2
        passwordTextField.leftViewMode = UITextFieldViewMode.Always
        
//MARK: Login
        let loginButton = UIButton(frame: CGRectMake(20, passwordTextField.frame.origin.y + 70, view.frame.width - 40, 50))
        loginButton.backgroundColor = UIColor.clearColor()
        loginButton.titleLabel!.font = UIFont(name: "OpenSans-SemiBold", size: 17)
        loginButton.layer.cornerRadius = 3
        loginButton.setTitle("LOGIN", forState: .Normal)
        loginButton.addTarget(self, action: "onLogin", forControlEvents: .TouchUpInside)
        backgroundView.addSubview(loginButton)
    }
    
    override func viewWillAppear(animated: Bool) {
        // Add Observer
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "checkForcedUpdate", name: "didEnterForeground", object: nil)
        
        navigationController?.navigationBarHidden = true
        NSUserDefaults.standardUserDefaults().setBool(false, forKey: "isLoggedIn")
        NSUserDefaults.standardUserDefaults().setObject("login", forKey: "currentScreen")
        SocketHandler.sharedSocket.delegate = self
        checkLoginInfo()
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

extension LoginViewController {
    
//MARK: Forced Update
    func checkForcedUpdate() {
        if ForcedUpdate.sharedInstance.isUpToDate() == false {
            print("Current version is out-of-date!")
            promptForcedUpdate()
        }
        else {
            print("Current version is up-to-date!")
        }
    }
    
    func promptForcedUpdate() {
        let alertController = UIAlertController(title: "Update Available", message: "Please update to the new version now", preferredStyle: .Alert)
        
        alertController.addAction(UIAlertAction(title: "Update", style: UIAlertActionStyle.Default, handler: { (UIAlertAction) -> Void in
            
            if let webpage = ForcedUpdate.sharedInstance.getiOSMinVersionURL() {
                
                if UIApplication.sharedApplication().canOpenURL(NSURL(string: webpage)!) == true {
                    
                    UIApplication.sharedApplication().openURL(NSURL(string: webpage)!)
                }
            }
        }))
        
        presentViewController(alertController, animated: true, completion: nil)
    }
    
//MARK: SocketHandlerDelegate Method
    func socketHandlerDidAuthenticate() {
        NSTimer.scheduledTimerWithTimeInterval(1.5, target: self, selector: "presentHomepageWithDelay", userInfo: nil, repeats: false)
    }
    
    func socketHandlerDidConnect() {
        
    }
    
    func socketHandlerDidFailToConnect() {

    }
    
    func socketHandlerDidFailToAuthenticate() {

    }
    
    func socketHandlerDidDisconnect() {
        
    }
    
    func socketHandlerDidAssignOrder(assignedOrder: Order) {
        
    }
    
    func socketHandlerDidUnassignOrder(unassignedOrder: Order, isCurrentTask: Bool) {
        
    }
    
    func socketHandlerDidModifyOrder(modifiedOrder: Order, isCurrentTask: Bool) {
        
    }
    
    func presentHomepageWithDelay() {
        let navC = UINavigationController.init(rootViewController: OrderListViewController())
        navigationController?.presentViewController(navC, animated: true, completion: nil)
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
        presentViewController(alertController, animated: true, completion: nil)
    }
    
    func promptDisabledSettingsAlert(messageString: String) {
        let alertController = UIAlertController(title: "", message: messageString, preferredStyle: .Alert)
        alertController.addAction(UIAlertAction(title: "Settings", style: .Default, handler: { action in
            self.goToSettings()
        }))
        presentViewController(alertController, animated: true, completion: nil)
    }
    
    func goToSettings() {
        UIApplication.sharedApplication().openURL(NSURL(string: UIApplicationOpenSettingsURLString)!)
    }
    
//MARK: Login
    func checkLoginInfo() {
        // check if logged in user, if not reset textfields
        if NSUserDefaults.standardUserDefaults().objectForKey("username") == nil {
            NSUserDefaults.standardUserDefaults().setObject("", forKey: "username")
            NSUserDefaults.standardUserDefaults().setObject("", forKey: "password")
        }
        
        // set textfield text -> either empty strings to username and password
        usernameTextField.text = NSUserDefaults.standardUserDefaults().objectForKey("username") as? String
        passwordTextField.text = NSUserDefaults.standardUserDefaults().objectForKey("password") as? String
    }
    
    func onLogin() {
        // username or password fields empty
        if usernameTextField.text == "" || passwordTextField.text == "" {
            promptAlertWith("Please enter both your username and password", style: .Cancel)
            return
        }
        
        if areLocationAndNotificationEnabled() == false {
            return
        }
        
        if Connectivity.isConnectedToNetwork() == true {
            print("is connected to internet")
        }
        else {
            print("is not connected to internet")
        }
        
        User.currentUser.login(usernameTextField.text!, password: passwordTextField.text!)
    }
    
    func areLocationAndNotificationEnabled() -> Bool {
        let settingsMessage = "Both Location and Notifications must be enabled to use this app. We will only track your location when you're logged in for your shift. Please turn them on in device Settings to proceed."
        
        // if general location services enabled
        if CLLocationManager.locationServicesEnabled() {
            print("Location services for this app is not enabled")
            
            if CLLocationManager.authorizationStatus() == .NotDetermined || CLLocationManager.authorizationStatus() == .Restricted || CLLocationManager.authorizationStatus() == .Denied {
                
                promptDisabledSettingsAlert(settingsMessage)
                
                return false
            }
        }
            // general location servies disabled
        else {
            print("General location services are not enabled")
            
            promptDisabledSettingsAlert(settingsMessage)
            
            return false
        }
        
        if let settings = UIApplication.sharedApplication().currentUserNotificationSettings() {
            if settings.types.contains([.Alert, .Sound]) == false {
                // Don't have alert and sound permissions
                promptDisabledSettingsAlert(settingsMessage)
                
                return false
            }
        }
        
        return true
    }
    
//MARK: UITextfieldDelegate
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        usernameTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
        return true;
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        view.endEditing(true)
    }
}
