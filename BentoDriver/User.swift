//
//  User.swift
//  BentoDriver
//
//  Created by Joseph Lau on 10/9/15.
//  Copyright © 2015 Joseph Lau. All rights reserved.
//

import Foundation

public class User {
    // Properties
    private static var cUser: User?
    public var username: String?
    public var password: String?
}

// Methods
extension User {
    
    // Log In
    public static func login(username: String, password: String) {
        
        // set username and password
        self.cUser?.username = username
        self.cUser?.password = password
        
        // if no currentUser, try to connect to socket
        if cUser == nil {
            SocketHandler.sharedSocket.loginToSocketConnection(username, password: password)
        }
    }
    
    // Get current user
    public static func currentUser() -> User {
        login((self.cUser?.username)!, password: (self.cUser?.password)!)
        
        return self.cUser!
    }
}