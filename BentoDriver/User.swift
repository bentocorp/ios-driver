//
//  User.swift
//  BentoDriver
//
//  Created by Joseph Lau on 10/9/15.
//  Copyright © 2015 Joseph Lau. All rights reserved.
//

import Foundation

public class User {
    static let currentUser = User() // singleton
    public var username: String?
    public var password: String?
    public var token: String?
}

extension User {
    public func login(username: String, password: String) {
        
        // set username and password
        self.username = username
        self.password = password
        
        // connect to Node
        SocketHandler.sharedSocket.connectAndAuthenticateWith(username, password: password)
    }
}
