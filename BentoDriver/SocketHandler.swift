//
//  SocketHandler.swift
//  BentoDriver
//
//  Created by Joseph Lau on 10/9/15.
//  Copyright © 2015 Joseph Lau. All rights reserved.
//

import Foundation
import Socket_IO_Client_Swift
import SwiftyJSON

public class SocketHandler {
    static let sharedSocket = SocketHandler()
    let socket = SocketIOClient(socketURL: "http://54.191.141.101:8081", opts: nil)
}

extension SocketHandler {
    
    public func loginToSocketConnection(username: String, password: String) {
        // connect to socket
        self.socket.on("connect") {data, ack in
            print("socket connected")
            
            // authenticate
            self.socket.emitWithAck("get", "/api/authenticate?username=\(username)&password=\(password)&type=driver")(timeoutAfter: 0) {data in
                print("socket authenticated")
                
                // check data for type String, then cast as String if exists
                if let jsonString = data[0] as? String {
                    // get data from jsonString
                    if let dataFromString = jsonString.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false) {
                        let json = JSON(data: dataFromString)
                        let ret = json["ret"]
                        let token = ret["token"]
                        
                        
                        // save token to device
                        NSUserDefaults.standardUserDefaults().setObject(String(token), forKey: "userToken")
                        
//                        Order.pullOrders()
                    }
                }
            }
            
            // listen to push channel from marc
            self.socket.on("ping", callback: { (data, ack) -> Void in
                print(data)
            })
            
            // send to him pong msgs
            NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "update", userInfo: nil, repeats: true)
        }
        
        socket.connect()
    }
    
    func update() {
        let timestamp = NSDateFormatter.localizedStringFromDate(NSDate(), dateStyle: .MediumStyle, timeStyle: .MediumStyle)
        print(timestamp)
        self.socket.emit("pong", timestamp)
    }
}