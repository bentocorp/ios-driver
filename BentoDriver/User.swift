//
//  User.swift
//  BentoDriver
//
//  Created by Joseph Lau on 10/9/15.
//  Copyright © 2015 Joseph Lau. All rights reserved.
//

import Foundation
import CoreLocation

public class User {
    static let currentUser = User() // singleton
    public var username: String?
    public var password: String?
    public var token: String?
    public var coordinates: CLLocationCoordinate2D?
}

extension User {
    
    public func login(username: String, password: String) {
        
        self.username = username
        self.password = password
        
        // connect to Node
        SocketHandler.sharedSocket.connectAndAuthenticateWith(username, password: password)
    }
    
    public func logout() {
        self.username = nil
        self.password = nil
        self.token = nil
    }
    
    public func isLoggedIn() -> Bool {
        return NSUserDefaults.standardUserDefaults().boolForKey("isLoggedIn")
    }
}
