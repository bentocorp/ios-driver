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
        
        UIApplication.sharedApplication().statusBarStyle = .LightContent
        UIApplication.sharedApplication().idleTimerDisabled = false // ok to lock screen
        
//MARK: Background Image
        let backgroundImage = UIImageView(frame: CGRectMake(0, 0, self.view.frame.width, self.view.frame.height))
        backgroundImage.image = UIImage(named: "grass")
        backgroundImage.contentMode = .ScaleAspectFill
        self.view.addSubview(backgroundImage)
        
//MARK: Background View
        let backgroundView = UIView(frame: CGRectMake(0, 0, self.view.frame.width, 350))
        backgroundView.center = self.view.center
        self.view.addSubview(backgroundView)
        
//MARK: Logo
        let logoImageView = UIImageView(frame: CGRectMake(20, 20, self.view.frame.width - 40, 100))
        logoImageView.contentMode = UIViewContentMode.ScaleAspectFit
        logoImageView.image = UIImage(named: "logo")
        backgroundView.addSubview(logoImageView)
        
//MARK: Username
        self.usernameTextField = UITextField(frame: CGRectMake(20, 20 + 100 + 60, self.view.frame.width - 40, 50))
        self.usernameTextField.layer.cornerRadius = 1
        self.usernameTextField.textColor = UIColor(red: 0.3137, green: 0.549, blue: 0.3098, alpha: 1.0)
        self.usernameTextField.placeholder = "username"
        self.usernameTextField.font = UIFont(name: "OpenSans-Regular", size: 17)
        self.usernameTextField.text!.lowercaseString
        self.usernameTextField.autocapitalizationType = UITextAutocapitalizationType.None
        self.usernameTextField.autocorrectionType = .No
        self.usernameTextField.backgroundColor = UIColor.whiteColor()
        self.usernameTextField.keyboardType = UIKeyboardType.EmailAddress
        self.usernameTextField.clearButtonMode = UITextFieldViewMode.WhileEditing
        self.usernameTextField.tintColor = UIColor(red: 0.3137, green: 0.549, blue: 0.3098, alpha: 1.0)
        self.usernameTextField.delegate = self
        backgroundView.addSubview(self.usernameTextField)
        
        // username padding
        let paddingView = UIView(frame: CGRectMake(0, 0, 15, self.usernameTextField.frame.height))
        usernameTextField.leftView = paddingView
        usernameTextField.leftViewMode = UITextFieldViewMode.Always
        
//MARK: Password
        self.passwordTextField = UITextField(frame: CGRectMake(20, self.usernameTextField.frame.origin.y + 51, self.view.frame.width - 40, 50))
        self.passwordTextField.layer.cornerRadius = 1
        self.passwordTextField.textColor = UIColor(red: 0.3137, green: 0.549, blue: 0.3098, alpha: 1.0)
        self.passwordTextField.placeholder = "password"
        self.passwordTextField.font = UIFont(name: "OpenSans-Regular", size: 17)
        self.passwordTextField.autocapitalizationType = UITextAutocapitalizationType.None
        self.passwordTextField.backgroundColor = UIColor.whiteColor()
        self.passwordTextField.secureTextEntry = true
        self.passwordTextField.clearButtonMode = UITextFieldViewMode.WhileEditing
        self.passwordTextField.tintColor = UIColor(red: 0.3137, green: 0.549, blue: 0.3098, alpha: 1.0)
        self.passwordTextField.delegate = self
        backgroundView.addSubview(self.passwordTextField)
    
        // password padding
        let paddingView2 = UIView(frame: CGRectMake(0, 0, 15, self.passwordTextField.frame.height))
        passwordTextField.leftView = paddingView2
        passwordTextField.leftViewMode = UITextFieldViewMode.Always
        
//MARK: Login
        let loginButton = UIButton(frame: CGRectMake(20, self.passwordTextField.frame.origin.y + 70, self.view.frame.width - 40, 50))
        loginButton.backgroundColor = UIColor.clearColor()
        loginButton.titleLabel!.font = UIFont(name: "OpenSans-SemiBold", size: 17)
        loginButton.layer.cornerRadius = 3
        loginButton.setTitle("LOGIN", forState: .Normal)
        loginButton.addTarget(self, action: "onLogin", forControlEvents: .TouchUpInside)
        backgroundView.addSubview(loginButton)
    }
    
    override func viewWillAppear(animated: Bool) {
        self.navigationController?.navigationBarHidden = true
        SocketHandler.sharedSocket.delegate = self
        self.checkLoginInfo()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

extension LoginViewController {
    
//MARK: SocketHandlerDelegate Method
    func socketHandlerDidConnect() {
        
    }
    
    func socketHandlerDidFailToConnect() {
        self.dismissHUD(false)
        self.promptAlertWith("Could not connect to Node server", style: UIAlertActionStyle.Cancel)
    }
    
    func socketHandlerDidAuthenticate() {
// TODO: check if connected already. if yes, don't prompt alert...
//            self.promptAlertWith("Authentication Succeeded", style: UIAlertActionStyle.Default)
            
        self.dismissHUD(true)
        NSTimer.scheduledTimerWithTimeInterval(1.5, target: self, selector: "presentHomepageWithDelay", userInfo: nil, repeats: false)
    }

    func socketHandlerDidFailToAuthenticate() {
        self.dismissHUD(false)
        NSTimer.scheduledTimerWithTimeInterval(1.5, target: self, selector: "promptAlertWithDelay", userInfo: nil, repeats: false)
    }
    
    func socketHandlerDidDisconnect() {
        
    }
    
    func promptAlertWithDelay() {
        self.promptAlertWith("Authentication Failed", style: UIAlertActionStyle.Cancel)
    }
    
    func presentHomepageWithDelay() {
        let navC = UINavigationController.init(rootViewController: OrderListViewController())
        self.navigationController?.presentViewController(navC, animated: true, completion: nil)
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
    
//MARK: Login
    func checkLoginInfo() {
        // check if logged in user, if not reset textfields
        if NSUserDefaults.standardUserDefaults().objectForKey("username") == nil {
            NSUserDefaults.standardUserDefaults().setObject("", forKey: "username")
            NSUserDefaults.standardUserDefaults().setObject("", forKey: "password")
        }
        
        // set textfield text -> either empty strings to username and password
        self.usernameTextField.text = NSUserDefaults.standardUserDefaults().objectForKey("username") as? String
        self.passwordTextField.text = NSUserDefaults.standardUserDefaults().objectForKey("password") as? String
    }
    
    func onLogin() {
        if self.usernameTextField.text == "" || self.passwordTextField.text == "" {
            // username and password fields empty
            self.promptAlertWith("Please enter both your username and password", style: .Cancel)
            return
        }
        
        self.showHUD()
        
        User.currentUser.login(self.usernameTextField.text!, password: self.passwordTextField.text!)
    }
    
//MARK: UITextfieldDelegate
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.usernameTextField.resignFirstResponder()
        self.passwordTextField.resignFirstResponder()
        return true;
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.view.endEditing(true)
    }
    
//MARK: HUD
    func showHUD() {
        PKHUD.sharedHUD.contentView = PKHUDProgressView()
        PKHUD.sharedHUD.dimsBackground = true
        PKHUD.sharedHUD.userInteractionOnUnderlyingViewsEnabled = false
        PKHUD.sharedHUD.show()
    }
    
    func dismissHUD(success: Bool) {
        if success == true {
            PKHUD.sharedHUD.contentView = PKHUDSuccessView()
        }
        else {
            PKHUD.sharedHUD.contentView = PKHUDErrorView()
        }
        
        PKHUD.sharedHUD.hide(afterDelay: 1)
    }
}
