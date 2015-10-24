//
//  LoginView.swift
//  BentoDriver
//
//  Created by Joseph Lau on 10/24/15.
//  Copyright © 2015 Joseph Lau. All rights reserved.
//

import UIKit

class LoginView: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


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
