//
//  SocketHandler.swift
//  BentoDriver
//
//  Created by Joseph Lau on 10/9/15.
//  Copyright © 2015 Joseph Lau. All rights reserved.
//

import Foundation
import CoreLocation
import AVFoundation
import Socket_IO_Client_Swift
import SwiftyJSON

protocol SocketHandlerDelegate {
    func socketHandlerDidConnect(connected: Bool)
    func socketHandlerDidDisconnect()
    func socketHandlerDidAuthenticate(authenticated: Bool)
    func socketHandlerDidRecievePushNotification(push: Push)
}

public class SocketHandler {
    static let sharedSocket = SocketHandler() // singleton
    var delegate: SocketHandlerDelegate? // delegate
    let socket = SocketIOClient(socketURL: "http://54.191.141.101:8081", opts: nil) // API to connect to Node
    var json: JSON?
    var audioPlayer: AVAudioPlayer!
}

extension SocketHandler {
    
    public func connectAndAuthenticateWith(username: String, password: String) {
        
        // 1) connect to node
        self.socket.on("connect") {data, ack in
            print("socket connected")
            self.delegate?.socketHandlerDidConnect(true)
            
            // 2) authenticate
            self.socket.emitWithAck("get", "/api/authenticate?username=\(username)&password=\(password)&type=driver")(timeoutAfter: 0) {data in
                
                // check data for type String, then cast as String if exists
                if let jsonString = data[0] as? String {
                    // get data from jsonString
                    if let dataFromString = jsonString.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false) {
                        self.json = JSON(data: dataFromString)
                        
                        /*
                        ‘{“code”:1,”msg”:”Bad authentication credentials”,”ret”:null}’
                        ‘{“code”:0,”msg”:”OK”,”ret”:{“uid”:”d-8”,”token”:”123ABC”}}’
                        */
                        
                        let ret: JSON
                        if self.json?["ret"] != nil {
                            ret = self.json!["ret"]
                            
                            let token = ret["token"]
                                
                            // save token to device
                            User.currentUser.token = token.stringValue
                            print(token)
                        }
                    
                        let code = self.json?["code"]
                        if code == 0 {
                            self.delegate?.socketHandlerDidAuthenticate(true)
                        }
                        else {
                            self.delegate?.socketHandlerDidAuthenticate(false)
                        }
                        
                        // 3) Emit location to loc channel
                        let lat = NSUserDefaults.standardUserDefaults().objectForKey("lat")!
                        let long = NSUserDefaults.standardUserDefaults().objectForKey("long")!
                        self.socket.emit("loc", ["lat": lat, "lng": long])

                        // 4) Listen for push notifications
                        self.socket.on("push", callback: { (data, ack) -> Void in
                            // check data for type String, then cast as String if exists
                            if let jsonStr = data[0] as? String {
                                // get data from jsonString
                                if let dataFromStr = jsonStr.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false) {
                                    let json2 = JSON(data: dataFromStr)

                                    let push = Push(json: json2)
                                    self.delegate?.socketHandlerDidRecievePushNotification(push)
                                    
                                    print(push.bodyArray)
                                }
                            }
                        })
                    }
                }
            }
        }
        
        self.socket.connect(timeoutAfter: 1) { () -> Void in
            // connection failed
            self.delegate?.socketHandlerDidConnect(false)
        }
    }
    
    @objc func promptLocalNotification() {
        let localNotification = UILocalNotification()
        localNotification.fireDate = NSDate(timeIntervalSinceNow: 0)
        localNotification.alertBody = "New Order!"
        localNotification.soundName = "new_order.wav"
        localNotification.timeZone = NSTimeZone.defaultTimeZone()
        localNotification.applicationIconBadgeNumber = UIApplication.sharedApplication().applicationIconBadgeNumber + 1
        
        UIApplication.sharedApplication().scheduleLocalNotification(localNotification)
    }
}


//
//interface ISocketHandler {
//    public func onPushNotification(push: Push)->()
//    public func onLocationUpdate(lat: Long, lng: Long)->()
//    ...
//}
//
//class SocketConnection {
//    var WebSocket socket;
//    
//    func init() {
//        // Initalize
//    }
//    
//    func login(username: String, password: String)) {
//        // connect & authenticate
//    }
//    
//    static func registerEventHandler(handler: ) {
//        socket.on("push", () -> {
//            // Deserialize
//            handler.onPush
//        })
//        
//        socket.on("loc", () -> {
//            // Deserialize or whatever
//            handler.onLocationUpdate(lat, lng)
//        })
//    }
//}
//
//class MyController implement ISocketHandler {
//    
//    //static var socket: SocketConnection = new SocketConnection("marc@bentonow.com", "password");
//    
//    public func onPushNotification()-> {
//        // do stuff with push
//    }
//    
//    public func onLocationUpdate()-> {
//        // update Map
//    }
//    
//    socket.registerEventHandler(self)
//    
//    
//}
//
//
//class LoginController {
//    var controller = new MyController();
//    var conn = new SocketConnection();
//    
//    conn.connect("mdoan", "passrod")
//    conn.registerEventHandler(controller)
//    self.navigationcontroller.pushviewcontroller(controller)
//}

























// get from ping channel
//            self.socket.on("ping", callback: { (data, ack) -> Void in
//            })

// send through pong channel
//            self.socket.emit("pong", data)
//            self.socket.emit("pong", "Time remaining - \(UIApplication.sharedApplication().backgroundTimeRemaining)")
//
//            let lat = NSUserDefaults.standardUserDefaults().objectForKey("lat")!
//            let long = NSUserDefaults.standardUserDefaults().objectForKey("long")!
//
//            // would be a good idea to check for nil data first
//            self.socket.emit("pong", "lat: \(lat), long: \(long)")
//
//            self.socket.emitWithAck("get", "/api/uloc?token=d-8-test?lat=90.0&lng=78.90")(timeoutAfter: 0) { data in
//                // don't really need to use data returned here, just handle any errors
//            }
//
//            self.invokeLocalNotification()
//
//            let soundPath = NSBundle.mainBundle().pathForResource("new_order.wav", ofType: nil)!
//            let soundURL = NSURL(fileURLWithPath: soundPath)
//
//            // play audio
//            do {
//                let sound = try AVAudioPlayer(contentsOfURL: soundURL)
//                self.audioPlayer = sound
//                sound.play()
//            } catch {
//                // couldn't load file, handle error
//            }

// stop audio
//                if self.audioPlayer != nil {
//                    self.audioPlayer.stop()
//                    self.audioPlayer = nil
//                }
