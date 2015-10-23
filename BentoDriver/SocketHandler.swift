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

//MARK: Protocol
@objc protocol SocketHandlerDelegate {
    optional func socketHandlerDidConnect(connected: Bool)
    optional func socketHandlerDidDisconnect()
    optional func socketHandlerDidAuthenticate(authenticated: Bool)
    optional func socketHandlerDidAssignOrder(assignedOrder: Order)
    optional func socketHandlerDidUnassignOrder(unassignedOrder: Order)
}

//MARK: Properties
public class SocketHandler: NSObject {
    static let sharedSocket = SocketHandler() // singleton
    var delegate: SocketHandlerDelegate? // delegate
    public var socket = SocketIOClient(socketURL: "http://54.191.141.101:8081", opts: nil) // Node API
    public var audioPlayer: AVAudioPlayer!
    public var emitLocationTimer: NSTimer?
}

//MARK: Methods
extension SocketHandler {
    
//MARK: Connect
    public func connectAndAuthenticateWith(username: String, password: String) {
        print("connectAndAuthenticate called")
        
        // 0) close and remove any preexisting handlers before trying to connect
        self.socket.disconnect()
        self.socket.close()
        self.socket.removeAllHandlers()
        
        // 1) connect
        self.socket.on("connect") {data, ack in
            print("socket connected")
            
            // call delegate method
            self.delegate?.socketHandlerDidConnect!(true)
            
            // 2) authenticate
            self.authenticateUser(username, password: password)
        }
        
        // connect to Node & handle error if any
        self.socket.connect(timeoutAfter: 10) { () -> Void in
            
            // remove previous handler to avoid multiple auto attempts to connect
            self.socket.removeAllHandlers()
            
            // call delegate method
            self.delegate?.socketHandlerDidConnect!(false)
        }
    }
    
//MARK: Authenticate
    func authenticateUser(username: String, password: String) {
        
        // authenticate and get token
        self.socket.emitWithAck("get", "/api/authenticate?username=\(username)&password=\(password)&type=driver")(timeoutAfter: 1) {data in
            
            // check data for type String, then cast as String if exists
            if let jsonString = data[0] as? String {
                
                // get data from jsonString
                if let dataFromString = jsonString.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false) {
                    
                    var json = JSON(data: dataFromString)
                    
                    /*
                    ‘{“code”:1,”msg”:”Bad authentication credentials”,”ret”:null}’
                    ‘{“code”:0,”msg”:”OK”,”ret”:{“uid”:”d-8”,”token”:”123ABC”}}’
                    */
                    
                    // check code (0 or 1), then call delegate method to let app know if authenticated
                    let token: String?
                    let code = json["code"]
                    if code == 0 {
                        // authentication succeeded
                        self.delegate?.socketHandlerDidAuthenticate!(true)
                        
                        // if authenticated, ret should not be nil, but check anyways
                        let ret: JSON
                        if json["ret"] != nil {
                            ret = json["ret"]
                            
                            token = ret["token"].stringValue
                            
                            // retrieve token and set to currentUser
                            User.currentUser.token = token
                            print("socket authenticated with token: \(token!)")
                            
                            // save user
                            NSUserDefaults.standardUserDefaults().setObject(User.currentUser.username, forKey: "username")
                            NSUserDefaults.standardUserDefaults().setObject(User.currentUser.password, forKey: "password")
                            NSUserDefaults.standardUserDefaults().synchronize()
                            
                            // 3) emit to "loc" channel every 5 seconds
                            self.emitLocationTimer = NSTimer.scheduledTimerWithTimeInterval(5, target: self, selector: "emitToLocChannel", userInfo: nil, repeats: true)
                            
                            // 4) listn to "push" channel
                            self.listenToPushChannel()
                        }
                    }
                    else {
                        // remove previous handler to avoid multiple auto attempts to connect
                        self.socket.removeAllHandlers()
                        
                        // authentication failed
                        self.delegate?.socketHandlerDidAuthenticate!(false)
                    }
                }
            }
        }
    }

//MARK: Emit & Listen
    func emitToLocChannel() {
        let lat = NSUserDefaults.standardUserDefaults().objectForKey("lat")!
        let long = NSUserDefaults.standardUserDefaults().objectForKey("long")!
        
        self.socket.emitWithAck("get", "/api/uloc?token=\(User.currentUser.token!)&lat=\(lat)&lng=\(long)")(timeoutAfter: 0) { data in
            // handle error if any
        }

        print("\(User.currentUser.token!) and \(lat) and \(long)")
    }
    
    func listenToPushChannel() {
        self.socket.on("push", callback: { (data, ack) -> Void in
            // check data for type String, then cast as String if exists
            if let jsonStr = data[0] as? String {
                // get data from jsonStr
                if let dataFromStr = jsonStr.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false) {
                    let json = JSON(data: dataFromStr)
                    print(json)
                    
                    let push = Push(json: json)
                    
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        // check if body order or body string
                        if push.bodyOrderAction != nil {
                            
                            // ASSIGNED
                            if push.bodyOrderAction?.type == PushType.ASSIGN {
                                self.delegate?.socketHandlerDidAssignOrder!(push.bodyOrderAction!.order)
                            }
                            //  UNASSIGNED
                            else if push.bodyOrderAction?.type == PushType.UNASSIGN {
                                self.delegate?.socketHandlerDidUnassignOrder!(push.bodyOrderAction!.order)
                            }
                        }
                        else {
                            // handle body string...
                        }
                    })
                }
            }
        })
    }
    
    func playInAppSound() {
        let soundPath = NSBundle.mainBundle().pathForResource("new_order.wav", ofType: nil)!
        let soundURL = NSURL(fileURLWithPath: soundPath)
        
        // play audio
        do {
            let sound = try AVAudioPlayer(contentsOfURL: soundURL)
            self.audioPlayer = sound
            sound.play()
        } catch {
            // couldn't load file, handle error
        }
    }
    
//MARK: Disconnect
    func closeSocket() {
        // disconnect socket
        self.socket.close()
        self.socket.disconnect()
        
        // remove previous handler to avoid multiple auto attempts to connect
        self.socket.removeAllHandlers()
        
        // stop timer to stop emiting location
        self.emitLocationTimer?.invalidate()
        
        // logout user
        User.currentUser.logout()
        
        // clear order list
        OrderList.sharedInstance.orderArray.removeAll()
        
        // set delegate method
        self.delegate?.socketHandlerDidDisconnect!()
        
        //
        print("socket closed")
    }

//MARK: Local Notification
    public func promptLocalNotification(sound: String) {
        let localNotification = UILocalNotification()
        localNotification.fireDate = NSDate(timeIntervalSinceNow: 0)
        
        var alertBody: String

        if sound == "assigned" {
            alertBody = "A new task has been assigned!"
        }
        else {
            alertBody = "A task has been unassigned!"
        }
        
        localNotification.soundName = UILocalNotificationDefaultSoundName
        localNotification.alertBody = alertBody
        localNotification.timeZone = NSTimeZone.defaultTimeZone()
        localNotification.applicationIconBadgeNumber = UIApplication.sharedApplication().applicationIconBadgeNumber + 1
        
        UIApplication.sharedApplication().scheduleLocalNotification(localNotification)
    }
}

