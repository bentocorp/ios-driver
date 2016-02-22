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
import Mixpanel

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
    // Push Type: assign/unassign/reprioritize/modify
    optional func socketHandlerDidAssignOrder(assignedOrder: Order)
    optional func socketHandlerDidUnassignOrder(unassignedOrder: Order, isCurrentTask: Bool)
    optional func socketHandlerDidReprioritizeOrder(reprioritized: Order, isCurrentTask: Bool)
    optional func socketHandlerDidModifyOrder(modifiedOrder:Order, isCurrentTask: Bool)
    
    optional func socketConnectEventTriggered()
    optional func socketReconnectEventTriggered()
    optional func socketDisconnectEventTrigger()
}

//MARK: Properties
public class SocketHandler: NSObject {
    static let sharedSocket = SocketHandler()
    
    var delegate: SocketHandlerDelegate!
    
    public var socket: SocketIOClient?
    
    var emitLocationTimer: NSTimer?
    
    let notification = CWStatusBarNotification()
    
    var tryToConnect: Bool? // prevent timeout "failed to connect" message
//    var isAuthenticating: Bool = false
    
    var username: String?
    var password: String?
}

//MARK: Methods
extension SocketHandler {
    
    public func getHoustonAPI() -> String {
    #if DEBUG
        return "https://houston.dev.bentonow.com:8443"
    #else
        return "https://houston.bentonow.com:8443"
    #endif
    }
    
    public func connectAndAuthenticateWith(username: String, password: String) {
        print("connectAndAuthenticate called")
        
        self.username = username
        self.password = password
        
        tryToConnect = true // ok to show timeout "failed to connect" message
        
        showHUD()
        
        // connect
        connectUser()
    }
    
//MARK: Connect
    func connectUser() {
        
        #if DEBUG
            socket = SocketIOClient(socketURL: "https://node.dev.bentonow.com:8443", options: [.ReconnectWait(1)])
        #else
            socket = SocketIOClient(socketURL: "https://node.bentonow.com:8443", options: [.ReconnectWait(1)])
        #endif
        
        configureHandlers()
        
        self.socket?.connect(timeoutAfter: 10) { () -> Void in
            print("connect timed out")
            
            if self.tryToConnect == true {
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    
                    self.tryToConnect = false // prevent timeout "failed to connect" message
                    
                    self.dismissHUD(false, message: "Failed to connect!")
                    
                    self.delegate.socketHandlerDidFailToConnect?()
                    
                    if NSUserDefaults.standardUserDefaults().objectForKey("currentScreen") as? String == "login" {
                        self.closeSocket(false)
                    }
                })
            }
        }
    }
    
    func configureHandlers() {
        socket?.on("connect") {data, ack in
            print("connect triggered - \(data)")
            
            Mixpanel.sharedInstance().track("Connect Event Triggered", properties: ["data": "\(data)"])
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.delegate.socketHandlerDidConnect?()
                self.delegate.socketConnectEventTriggered?()
            })
            
//            if self.isAuthenticating == false {
//                self.isAuthenticating = true
                
                self.authenticateUser()
//            }
        }
        
        socket?.on("disconnect") { (data, ack) -> Void in
            print("disconnect triggered - \(data)")
            
            Mixpanel.sharedInstance().track("Disconnect Event Triggered", properties: ["data": "\(data)"])
            
            self.stopTimer()
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.delegate.socketDisconnectEventTrigger?()
            })
        }
        
        socket?.on("error") { (data, ack) -> Void in
            print("error triggered - \(data)")
            
            Mixpanel.sharedInstance().track("Error Event Triggered", properties: ["data": "\(data)"])
        }
        
        socket?.on("reconnect") { (data, ack) -> Void in
            print("reconnect triggered - \(data)")
            
            Mixpanel.sharedInstance().track("Reconnect Event Triggered", properties: ["data": "\(data)"])
            
            self.stopTimer()
            
            if NSUserDefaults.standardUserDefaults().objectForKey("currentScreen") as? String != "login" {
                self.showHUD()
            }
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.delegate.socketReconnectEventTriggered?()
            })
        }
        
        socket?.on("reconnectAttempt") { (data, ack) -> Void in
            print("reconnectAttempt triggered - \(data)")
        }
    }

//MARK: Authenticate
    func authenticateUser() {
        
        // authenticate and get token
        socket?.emitWithAck("get", "/api/authenticate?username=\(username!)&password=\(password!)&type=driver")(timeoutAfter: 1) { data in
            
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
                            self.tryToConnect = false
                            
                            self.delegate.socketHandlerDidAuthenticate?()
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
                            self.startTimer()
                            
                            // 4) listen to "push"
                            self.listenToPushChannel()
                        }
                    }
                    else {
                        print("socket did fail to authenticate")
                        
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            
                            if NSUserDefaults.standardUserDefaults().objectForKey("currentScreen") as? String == "login" {
                                self.dismissHUD(false, message: "Failed to authenticate")
                                self.closeSocket(false)
                            }
                            
                            self.delegate.socketHandlerDidFailToAuthenticate?()
                            
                        })
                    }
                    
//                    self.isAuthenticating = false
                }
            }
        }
    }

//MARK: Emit
    func emitToLocChannel() {
        let token = User.currentUser.token!
        let lat = User.currentUser.coordinates!.latitude
        let long = User.currentUser.coordinates!.longitude
        
        self.socket?.emitWithAck("get", "/api/uloc?token=\(token)&lat=\(lat)&lng=\(long)")(timeoutAfter: 0) { data in
            // handle error if needed...
        }

        print("emitting user \(token) coordinates: \(lat) and \(long)")
    }
    
//MARK: Listen To
    func listenToPushChannel() {
        
        socket?.on("push", callback: { (data, ack) -> Void in
            
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
                                OrderList.sharedInstance.reprioritizeOrder(push.bodyOrderAction!.order, afterId: push.bodyOrderAction!.after)
                                self.delegate.socketHandlerDidAssignOrder?(push.bodyOrderAction!.order)
                                
                            case .UNASSIGN:
                                var isCurrentTask = false
                                if OrderList.sharedInstance.orderArray.count != 0 {
                                    if push.bodyOrderAction!.order.id == OrderList.sharedInstance.orderArray[0].id {
                                        isCurrentTask = true
                                    }
                                }
                                
                                OrderList.sharedInstance.removeOrder(push.bodyOrderAction!.order)
                                self.delegate.socketHandlerDidUnassignOrder?(push.bodyOrderAction!.order, isCurrentTask: isCurrentTask)
                                
                            case .REPRIORITIZE:
                                var isCurrentTask = false
                                if push.bodyOrderAction!.order.id == OrderList.sharedInstance.orderArray[0].id {
                                    isCurrentTask = true
                                }
                                
                                OrderList.sharedInstance.reprioritizeOrder(push.bodyOrderAction!.order, afterId: push.bodyOrderAction!.after)
                                self.delegate.socketHandlerDidReprioritizeOrder?(push.bodyOrderAction!.order, isCurrentTask: isCurrentTask)
                                
                            case .MODIFY:
                                var isCurrentTask = false
                                if push.bodyOrderAction!.order.id == OrderList.sharedInstance.orderArray[0].id {
                                    isCurrentTask = true
                                }
                                
                                self.delegate.socketHandlerDidModifyOrder?(push.bodyOrderAction!.order, isCurrentTask: isCurrentTask)
                                OrderList.sharedInstance.modifyOrder(push.bodyOrderAction!.order)
                                
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
    
//MARK: Timer
    func startTimer() {
        if self.emitLocationTimer?.valid == false || self.emitLocationTimer == nil {
            print("start timer")
            self.emitLocationTimer = NSTimer.scheduledTimerWithTimeInterval(2, target: self, selector: "emitToLocChannel", userInfo: nil, repeats: true)
        }
    }
    
    func stopTimer() {
        if self.emitLocationTimer?.valid == true || self.emitLocationTimer != nil {
            print("stop timer")
            self.emitLocationTimer?.invalidate()
            self.emitLocationTimer = nil
        }
    }
    
//MARK: Disconnect
    func closeSocket(didDisconnectOnPurpose: Bool) {
        
        tryToConnect = false // prevent timeout "failed to connect" message
        
        stopTimer()
        
        socket?.disconnect()
        
        // don't trigger delegate method if lostConnection is true (ie. triggered by disconnected internet connection)
        if didDisconnectOnPurpose == true {
            
            socket?.removeAllHandlers()
            
            OrderList.sharedInstance.orderArray.removeAll()
            
            User.currentUser.logout()
            
            delegate.socketHandlerDidDisconnect?()
        }
        
        print("socket closed")
    }
    
//MARK: HUD
    func showHUD() {
//        if isReconnecting {
//            PKHUD.sharedHUD.contentView = PKHUDTextView(text: "Reestablishing connectivity...")
//        }
//        else {
            PKHUD.sharedHUD.contentView = PKHUDProgressView()
//        }
        
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
        localNotification.timeZone = NSTimeZone.defaultTimeZone()
        localNotification.fireDate = nil
        
        let alertBody = "A task has been \(task)!"
        
        switch task {
        case "assigned":
            localNotification.soundName = "new_task.wav"
        case "unassigned":
            localNotification.soundName = "task_removed.wav"
        case "switched":
            localNotification.soundName = "task_switched.wav"
        case "modified":
            localNotification.soundName = "task_modified.wav"
        default: ()
        }
        
        localNotification.alertBody = alertBody
        localNotification.applicationIconBadgeNumber = UIApplication.sharedApplication().applicationIconBadgeNumber + 1
        
        UIApplication.sharedApplication().scheduleLocalNotification(localNotification)
    }
}

