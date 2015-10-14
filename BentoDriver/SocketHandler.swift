//
//  SocketHandler.swift
//  BentoDriver
//
//  Created by Joseph Lau on 10/9/15.
//  Copyright © 2015 Joseph Lau. All rights reserved.
//

import Foundation
import AVFoundation
import Socket_IO_Client_Swift
import SwiftyJSON


protocol SocketHandlerDelegate {
    func userConnected(connected: Bool)
    func userAuthenticated(authenticated: Bool)
}

public class SocketHandler {
    // make singleton
    static let sharedSocket = SocketHandler()
    
    let socket = SocketIOClient(socketURL: "http://54.191.141.101:8081", opts: nil)
    var delegate: SocketHandlerDelegate?
//    var audioPlayer: AVAudioPlayer!
    
    var json: JSON?
}

extension SocketHandler {
    
    public func loginToSocketConnection(username: String, password: String) {
        // connect to socket
        self.socket.on("connect") {data, ack in
            print("socket connected")
            self.delegate?.userConnected(true)
            
            // authenticate
            self.socket.emitWithAck("get", "/api/authenticate?username=\(username)&password=\(password)&type=driver")(timeoutAfter: 0) {data in
                
                // check data for type String, then cast as String if exists
                if let jsonString = data[0] as? String {
                    // get data from jsonString
                    if let dataFromString = jsonString.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false) {
                        self.json = JSON(data: dataFromString)
                        
                        /* 
                        
                        example:
                        
                        ‘{“code”:1,”msg”:”Bad authentication credentials”,”ret”:null}’
                        
                        ‘{“code”:0,”msg”:”OK”,”ret”:{“uid”:”d-8”,”token”:”123ABC”}}’

                        */
                        
                        let ret: JSON
                        if self.json?["ret"] != nil {
                            ret = self.json!["ret"]
                            
                            let token = ret["token"]
                                
                            // save token to device
                            NSUserDefaults.standardUserDefaults().setObject(String(token), forKey: "userToken")
                            print(token)
                        }
                    
                        let code = self.json?["code"]
                        // authenticated
                        if code == 0 {
                            self.delegate?.userAuthenticated(true)
                        }
                        // not authenticated
                        else {
                            self.delegate?.userAuthenticated(false)
                        }
                    }
                }
            }
            
//            // get from ping channel
//            self.socket.on("ping", callback: { (data, ack) -> Void in
            
//                // send through pong channel
//                self.socket.emit("pong", data)
//                self.socket.emit("pong", "Time remaining - \(UIApplication.sharedApplication().backgroundTimeRemaining)")
//
//                let lat = NSUserDefaults.standardUserDefaults().objectForKey("lat")!
//                let long = NSUserDefaults.standardUserDefaults().objectForKey("long")!
//                
//                // would be a good idea to check for nil data first
//                self.socket.emit("pong", "lat: \(lat), long: \(long)")
//                
//                self.socket.emitWithAck("get", "/api/uloc?token=d-8-test?lat=90.0&lng=78.90")(timeoutAfter: 0) { data in
//                    // don't really need to use data returned here, just handle any errors
//                }
                
//                self.invokeLocalNotification()
//                
//                let soundPath = NSBundle.mainBundle().pathForResource("new_order.wav", ofType: nil)!
//                let soundURL = NSURL(fileURLWithPath: soundPath)
//                
//                // play audio
//                do {
//                    let sound = try AVAudioPlayer(contentsOfURL: soundURL)
//                    self.audioPlayer = sound
//                    sound.play()
//                } catch {
//                    // couldn't load file, handle error
//                }
                
//                // stop audio
//                if self.audioPlayer != nil {
//                    self.audioPlayer.stop()
//                    self.audioPlayer = nil
//                }
//            })
        }
        
        self.socket.connect(timeoutAfter: 1) { () -> Void in
            // connection failed
            self.delegate?.userConnected(false)
        }
    }
    
//    @objc func invokeLocalNotification() {
//        let localNotification = UILocalNotification()
//        localNotification.fireDate = NSDate(timeIntervalSinceNow: 0)
//        localNotification.alertBody = "New Order!"
//        localNotification.soundName = "new_order.wav"
//        localNotification.timeZone = NSTimeZone.defaultTimeZone()
//        localNotification.applicationIconBadgeNumber = UIApplication.sharedApplication().applicationIconBadgeNumber + 1
//        
//        UIApplication.sharedApplication().scheduleLocalNotification(localNotification)
//    }
}