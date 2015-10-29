//
//  SocketHandler.swift
//  BentoDriver
//
//  Created by Joseph Lau on 10/9/15.
//  Copyright © 2015 Joseph Lau. All rights reserved.
//

import Foundation
import CoreLocation
import Socket_IO_Client_Swift
import SwiftyJSON
import PKHUD

//MARK: Protocol
@objc protocol SocketHandlerDelegate {
    // connect
    optional func socketHandlerDidConnect()
    optional func socketHandlerDidFailToConnect()
    // authenticate
    optional func socketHandlerDidAuthenticate()
    optional func socketHandlerDidFailToAuthenticate()
    // disconnect
    optional func socketHandlerDidDisconnect()
    // Push Type: assign/unassign/reprioritize
    optional func socketHandlerDidAssignOrder(assignedOrder: Order)
    optional func socketHandlerDidUnassignOrder(unassignedOrder: Order)
    optional func socketHandlerDidReprioritizeOrder()
}

//MARK: Properties
public class SocketHandler: NSObject {
    static let sharedSocket = SocketHandler() // singleton
    var delegate: SocketHandlerDelegate! // delegate
    public var socket = SocketIOClient(socketURL: "http://54.191.141.101:8081", opts: nil) // Node API
    public var emitLocationTimer: NSTimer?
    let notification = CWStatusBarNotification()
    
    var tryToConnect: Bool? // prevent timeout "failed to connect" message
}

//MARK: Methods
extension SocketHandler {
    
    public func connectAndAuthenticateWith(username: String, password: String) {
        print("connectAndAuthenticate called")
        
        tryToConnect = true // ok to show timeout "failed to connect" message
        
        self.showHUD()

        // close and remove any preexisting handlers before trying to connect
        self.socket.disconnect()
        self.socket.removeAllHandlers()
        
        // connect
        self.connectUser(username, password: password)
    }
    
//MARK: Connect
    func connectUser(username: String, password: String) {
        // 1) connect
        self.socket.on("connect") {data, ack in
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.delegate.socketHandlerDidConnect!()
                print("socket did connect")
            })
            
            // 2) authenticate
            self.authenticateUser(username, password: password)
        }
        
        // connect to Node & handle error if any
        self.socket.connect(timeoutAfter: 5) { () -> Void in
        
            if self.tryToConnect == true {
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    
                    self.tryToConnect = false // prevent timeout "failed to connect" message
                    
                    self.dismissHUD(false, message: "Failed to connect!")
                    
                    self.delegate.socketHandlerDidFailToConnect!()
                    print("socket did fail to connect")
                    
                    self.closeSocket(false)
                })
            }
        }
    }
    
//MARK: Authenticate
    func authenticateUser(username: String, password: String) {
        
        // authenticate and get token
        self.socket.emitWithAck("get", "/api/authenticate?username=\(username)&password=\(password)&type=driver")(timeoutAfter: 1) { data in
            
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
                    let code = json["code"]
                    
                    if code == 0 {
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            self.dismissHUD(true, message: "Authenticated")
                            
                            self.delegate.socketHandlerDidAuthenticate!()
                            print("socket did authenticate")
                        })
                        
                        // if authenticated, ret should not be nil, but check anyways
                        let ret: JSON
                        if json["ret"] != nil {
                            
                            ret = json["ret"]
                            
                            // retrieve token and set to currentUser
                            let token = ret["token"].stringValue
                            User.currentUser.token = token
                            
                            // save user info
                            NSUserDefaults.standardUserDefaults().setObject(User.currentUser.username, forKey: "username")
                            NSUserDefaults.standardUserDefaults().setObject(User.currentUser.password, forKey: "password")
                            
                            // reset didLoseInternetConnection
                            NSUserDefaults.standardUserDefaults().setBool(false, forKey: "didLoseInternetConnection")
                            
                            // 3) emit to "loc"
                            self.emitLocationTimer = NSTimer.scheduledTimerWithTimeInterval(2, target: self, selector: "emitToLocChannel", userInfo: nil, repeats: true)
                            
                            // 4) listn to "push"
                            self.listenToPushChannel()
                        }
                    }
                    else {
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            self.dismissHUD(false, message: "Failed to authenticate")
                            
                            self.delegate.socketHandlerDidFailToAuthenticate!()
                            print("socket did fail to authenticate")
                        })
                        
                        self.closeSocket(false)
                    }
                }
            }
        }
    }

//MARK: Emit
    func emitToLocChannel() {
        
        let token = User.currentUser.token!
        let lat = User.currentUser.coordinates!.latitude
        let long = User.currentUser.coordinates!.longitude
        
        self.socket.emitWithAck("get", "/api/uloc?token=\(token)&lat=\(lat)&lng=\(long)")(timeoutAfter: 0) { data in
            // handle error if needed...
        }

        print("emitting user \(token) coordinates: \(lat) and \(long)")
    }
    
//MARK: Listen To
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
                            
                            switch push.bodyOrderAction!.type! {
                            case .ASSIGN:
                                self.delegate.socketHandlerDidAssignOrder!(push.bodyOrderAction!.order)
                            case .UNASSIGN:
                                OrderList.sharedInstance.removeOrder(push.bodyOrderAction!.order)
                                self.delegate.socketHandlerDidUnassignOrder!(push.bodyOrderAction!.order)
                            case .REPRIORITIZE:
                                OrderList.sharedInstance.reprioritizeOrder(push.bodyOrderAction!.order, afterId: push.bodyOrderAction!.after)
                                self.delegate.socketHandlerDidReprioritizeOrder!()
                            default: ()
                            }
                        }
                        else {
                            // handle body string...?
                        }
                    })
                }
            }
        })
    }
    
//MARK: Disconnect
    func closeSocket(lostConnection: Bool) {
        
        self.tryToConnect = false // prevent timeout "failed to connect" message
        
        self.socket.disconnect()
        self.socket.removeAllHandlers()
        
        // stop timer to stop emiting location
        self.emitLocationTimer?.invalidate()
        
        // don't trigger delegate method is lostConnection is true (ie. triggered by disconnected internet connection)
        if lostConnection == false {
            // clear order list
            OrderList.sharedInstance.orderArray.removeAll()
            
            // logout user
            User.currentUser.logout()
            
            self.delegate.socketHandlerDidDisconnect!()
        }
        
        print("socket closed")
    }
    
//MARK: HUD
    func showHUD() {
        PKHUD.sharedHUD.contentView = PKHUDProgressView()
        PKHUD.sharedHUD.dimsBackground = true
        PKHUD.sharedHUD.userInteractionOnUnderlyingViewsEnabled = false
        PKHUD.sharedHUD.show()
    }
    
    func dismissHUD(success: Bool, message: String) {
        let notification = CWStatusBarNotification()
        notification.notificationStyle = .NavigationBarNotification
        notification.notificationAnimationInStyle = .Left
        notification.notificationAnimationOutStyle = .Right
        notification.notificationLabelFont = UIFont(name: "OpenSans-Bold", size: 17)!
        notification.notificationLabelTextColor = UIColor.whiteColor()
        
        if success == true {
            notification.notificationLabelBackgroundColor = UIColor(red: 0.1804, green: 0.8, blue: 0.4431, alpha: 1.0) /* #2ecc71 */
            PKHUD.sharedHUD.contentView = PKHUDSuccessView()
        }
        else {
            notification.notificationLabelBackgroundColor = UIColor(red: 0.9059, green: 0.298, blue: 0.2353, alpha: 1.0) /* #e74c3c */
            PKHUD.sharedHUD.contentView = PKHUDErrorView()
        }
        
        notification.displayNotificationWithMessage(message, forDuration: 1.0)
        PKHUD.sharedHUD.hide(afterDelay: 1)
    }

//MARK: Local Notification
    public func promptLocalNotification(task: String) {
        let localNotification = UILocalNotification()
        localNotification.fireDate = NSDate(timeIntervalSinceNow: 0)
        
        let alertBody = "A task has been \(task)!"

//        if task == "assigned" {
//            alertBody = "A new task has been assigned!"
//            localNotification.soundName = "new_task.wav"
//        }
//        else {
//            alertBody = "A task has been unassigned!"
//            localNotification.soundName = "task_removed.wav"
//        }
        
        switch task {
        case "assigned":
            localNotification.soundName = "new_task.wav"
        case "unassigned":
            localNotification.soundName = "task_removed.wav"
        case "reprioritized":
//            localNotification.soundName = 
            print("should play reprioritized sound")
        default: ()
        }
        
        
        localNotification.alertBody = alertBody
        localNotification.timeZone = NSTimeZone.defaultTimeZone()
        localNotification.applicationIconBadgeNumber = UIApplication.sharedApplication().applicationIconBadgeNumber + 1
        
        UIApplication.sharedApplication().scheduleLocalNotification(localNotification)
    }
}

