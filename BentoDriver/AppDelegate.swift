//
//  AppDelegate.swift
//  BentoDriver
//
//  Created by Joseph Lau on 10/2/15.
//  Copyright © 2015 Joseph Lau. All rights reserved.
//

import UIKit
import Socket_IO_Client_Swift
import SwiftyJSON

@UIApplicationMain

class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    let socket = SocketIOClient(socketURL: "http://54.191.141.101:8081", opts: nil)
    var bgTask: UIBackgroundTaskIdentifier = 0
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        
        // connect to socket
        self.socket.on("connect") {data, ack in
            print("socket connected")
            
            // authenticate
            self.socket.emitWithAck("get", "/api/authenticate?username=marc@bentonow.com&password=wordpass&type=driver")(timeoutAfter: 0) {data in
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
            
            // listen to push channel
            self.socket.on("ping", callback: { (data, ack) -> Void in
                print(data)
            })
            
            NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "update", userInfo: nil, repeats: true)
        }
        
        self.socket.connect()
        
        return true
    }
    
    func update() {
        let timestamp = NSDateFormatter.localizedStringFromDate(NSDate(), dateStyle: .MediumStyle, timeStyle: .MediumStyle)
//        print(timestamp)
        self.socket.emit("pong", timestamp)
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        
        
        self.bgTask = application.beginBackgroundTaskWithExpirationHandler({ () -> Void in
            self.bgTask = UIBackgroundTaskInvalid
        })
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
        
        application.endBackgroundTask(self.bgTask)
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

