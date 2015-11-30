//
//  SessionDelegate.swift
//  BentoDriver
//
//  Created by Joseph Lau on 11/30/15.
//  Copyright © 2015 Joseph Lau. All rights reserved.
//

import Foundation

public class SessionDelegate: NSURLSession, NSURLSessionDelegate {
    
    public func URLSession(session: NSURLSession, didReceiveChallenge challenge: NSURLAuthenticationChallenge, completionHandler: (NSURLSessionAuthChallengeDisposition, NSURLCredential?) -> Void) {
        completionHandler(.UseCredential, NSURLCredential(trust: challenge.protectionSpace.serverTrust!))
    }
}
