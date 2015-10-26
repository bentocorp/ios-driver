////
////  LoginView.swift
////  BentoDriver
////
////  Created by Joseph Lau on 10/24/15.
////  Copyright © 2015 Joseph Lau. All rights reserved.
////
//
//import UIKit
//import PKHUD
//
//@objc protocol LoginViewDelegate {
//    func didSelectLogin()
//}
//
//class LoginView: UIView, UITextFieldDelegate {
//    
//    var delegate: LoginViewDelegate!
//    
//    //
//    var bgImageView: UIImageView
//        //
//    var platformView: UIView
//            //
//    var logoImageView: UIImageView
//    var usernameTextField: UITextField
//    var passwordTextField: UITextField
//    var textFieldPadding: UIView
//    var loginButton: UIButton
//    
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//        
//        self.addSubviews()
//    }
//
//    required init?(coder aDecoder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//}
//
//extension LoginView {
//    func addSubviews() {
//        // Add subviews
//        self.addSubview(self.bgImageView)
//        self.bgImageView.addSubview(self.platformView)
//        self.platformView.addSubview(self.logoImageView)
//        self.platformView.addSubview(self.usernameTextField)
//        self.platformView.addSubview(self.passwordTextField)
//        self.platformView.addSubview(self.loginButton)
//        
//        self.setupFrames()
//    }
//    
//    func setupFrames() {
//        self.bgImageView.frame = self.frame
//        self.platformView.frame = CGRectMake(0, 0, self.view.frame.width, 350)
//        self.logoImageView.frame = CGRectMake(20, 20, self.view.frame.width - 40, 100)
//        self.usernameTextField.frame = CGRectMake(20, 20 + 100 + 60, self.view.frame.width - 40, 50)
//        self.passwordTextField.frame = CGRectMake(20, self.usernameTextField.frame.origin.y + 51, self.view.frame.width - 40, 50)
//        self.textFieldPadding.frame = CGRectMake(0, 0, 15, self.usernameTextField.frame.height)
//        self.loginButton.frame = CGRectMake(20, self.passwordTextField.frame.origin.y + 70, self.view.frame.width - 40, 50)
//        
//        self.setupAttributes()
//    }
//    
//    func setupAttributes() {
//        // Background Image
//        backgroundImage.image = UIImage(named: "grass")
//        backgroundImage.contentMode = .ScaleAspectFill
//        
//        // Platform
//        platformView.center = self.view.center
//        
//        // Logo
//        logoImageView.contentMode = UIViewContentMode.ScaleAspectFit
//        logoImageView.image = UIImage(named: "logo")
//        
//        // Username
//        self.usernameTextField.layer.cornerRadius = 1
//        self.usernameTextField.textColor = UIColor(red: 0.3137, green: 0.549, blue: 0.3098, alpha: 1.0)
//        self.usernameTextField.placeholder = "username"
//        self.usernameTextField.font = UIFont(name: "OpenSans-Regular", size: 17)
//        self.usernameTextField.text!.lowercaseString
//        self.usernameTextField.autocapitalizationType = UITextAutocapitalizationType.None
//        self.usernameTextField.autocorrectionType = .No
//        self.usernameTextField.backgroundColor = UIColor.whiteColor()
//        self.usernameTextField.keyboardType = UIKeyboardType.EmailAddress
//        self.usernameTextField.clearButtonMode = UITextFieldViewMode.WhileEditing
//        self.usernameTextField.tintColor = UIColor(red: 0.3137, green: 0.549, blue: 0.3098, alpha: 1.0)
//        self.usernameTextField.leftView = self.paddingView
//        self.usernameTextField.leftViewMode = UITextFieldViewMode.Always
//        self.usernameTextField.delegate = self
//        
//        // Password
//        self.passwordTextField.layer.cornerRadius = 1
//        self.passwordTextField.textColor = UIColor(red: 0.3137, green: 0.549, blue: 0.3098, alpha: 1.0)
//        self.passwordTextField.placeholder = "password"
//        self.passwordTextField.font = UIFont(name: "OpenSans-Regular", size: 17)
//        self.passwordTextField.autocapitalizationType = UITextAutocapitalizationType.None
//        self.passwordTextField.backgroundColor = UIColor.whiteColor()
//        self.passwordTextField.secureTextEntry = true
//        self.passwordTextField.clearButtonMode = UITextFieldViewMode.WhileEditing
//        self.passwordTextField.tintColor = UIColor(red: 0.3137, green: 0.549, blue: 0.3098, alpha: 1.0)
//        self.passwordTextField.leftView = self.paddingView
//        self.passwordTextField.leftViewMode = UITextFieldViewMode.Always
//        self.passwordTextField.delegate = self
//        
//        // Login
//        loginButton.backgroundColor = UIColor.clearColor()
//        loginButton.titleLabel!.font = UIFont(name: "OpenSans-SemiBold", size: 17)
//        loginButton.layer.cornerRadius = 3
//        loginButton.setTitle("LOGIN", forState: .Normal)
//        loginButton.addTarget(self, action: "onLogin", forControlEvents: .TouchUpInside)
//    }
//}
//
//extension LoginView {
////MARK: UITextfieldDelegate
//    func textFieldShouldReturn(textField: UITextField) -> Bool {
//        self.usernameTextField.resignFirstResponder()
//        self.passwordTextField.resignFirstResponder()
//        return true;
//    }
//    
//    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
//        self.view.endEditing(true)
//    }
//    
////MARK: Alert
//    func promptAlertWith(messageString: String, style: UIAlertActionStyle) {
//        let alertController = UIAlertController(title: "", message: messageString, preferredStyle: .Alert)
//        alertController.addAction(UIAlertAction(title: "OK", style: .Default, handler: { action in
//            // go to Order List
//            if style == .Default {
//                let navC = UINavigationController.init(rootViewController: OrderListViewController())
//                self.navigationController?.presentViewController(navC, animated: true, completion: nil)
//            }
//        }))
//        self.presentViewController(alertController, animated: true, completion: nil)
//    }
//    
////MARK: HUD
//    func showHUD() {
//        PKHUD.sharedHUD.contentView = PKHUDProgressView()
//        PKHUD.sharedHUD.dimsBackground = true
//        PKHUD.sharedHUD.userInteractionOnUnderlyingViewsEnabled = false
//        PKHUD.sharedHUD.show()
//    }
//    
//    func dismissHUD() {
//        PKHUD.sharedHUD.contentView = PKHUDSuccessView()
//        PKHUD.sharedHUD.hide(afterDelay: 1)
//    }
//}
//
//
