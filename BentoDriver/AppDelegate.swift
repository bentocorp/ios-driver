//
//  AppDelegate.swift
//  BentoDriver
//
//  Created by Joseph Lau on 10/2/15.
//  Copyright © 2015 Joseph Lau. All rights reserved.
//

import UIKit
import CoreLocation
import Foundation
import PKHUD

@UIApplicationMain

class AppDelegate: UIResponder, UIApplicationDelegate, CLLocationManagerDelegate {

    var window: UIWindow?
    let locationManager = CLLocationManager()
    var reachability: Reachability!
    
    var isInForeground: Bool?
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        
        self.startReachability()
        
        self.window = UIWindow(frame: UIScreen.mainScreen().bounds)
        
        let orderListVC = LoginViewController()
        let navC = UINavigationController(rootViewController: orderListVC)
        
        self.window?.rootViewController = navC
        self.window?.makeKeyAndVisible()
        
        // Location Services
        self.initiateLocationManager()
        
        self.isInForeground = true
    
        return true
    }
    
    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
        
        // reset notification badge
        application.applicationIconBadgeNumber = 0
    }
    
    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        
        self.isInForeground = false
    }
    
    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
        
        self.isInForeground = true
        
        if self.isInForeground == true && NSUserDefaults.standardUserDefaults().boolForKey("didLoseInternetConnection") == true && NSUserDefaults.standardUserDefaults().boolForKey("isLoggedIn") == true {
            self.reconnect()
        }
        
        // let subscribers know of didEnterForeground
        NSNotificationCenter.defaultCenter().postNotificationName("didEnterForeground", object: nil)
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        
        // reset notification badge
        application.applicationIconBadgeNumber = 0
    }
    
    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        
        NSUserDefaults.standardUserDefaults().setBool(false, forKey: "isLoggedIn")
    }
}

extension AppDelegate {
    
//MARK: Location Services
    func initiateLocationManager() {
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.distanceFilter = kCLDistanceFilterNone
        self.locationManager.pausesLocationUpdatesAutomatically = false
        if #available(iOS 9.0, *) {
            self.locationManager.allowsBackgroundLocationUpdates = true
        } else {
            // Fallback on earlier versions
        }
        self.locationManager.requestAlwaysAuthorization()
        self.locationManager.startUpdatingLocation()
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print("Location update failed")
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        // check if local notification is enabled
        if UIApplication.sharedApplication().currentUserNotificationSettings()?.types == UIUserNotificationType.None {
            // if not, register for local notification
            if UIApplication.instancesRespondToSelector("registerUserNotificationSettings:") {
                UIApplication.sharedApplication().registerUserNotificationSettings(UIUserNotificationSettings(forTypes: [.Alert, .Badge, .Sound], categories: nil))
            }
        }
        
        // set coordinates to User
        User.currentUser.coordinates = manager.location?.coordinate
    }
    
//MARK: Reachability
    func startReachability() {
        do {
            self.reachability = try Reachability.reachabilityForInternetConnection()
        } catch {
            print("Unable to create Reachability")
        }
        
        self.reachability.whenReachable = { reachability in
            // this is called on a background thread, but UI updates must
            // be on the main thread, like this:
            
            dispatch_async(dispatch_get_main_queue()) {
                
                if self.isInForeground == true && NSUserDefaults.standardUserDefaults().boolForKey("didLoseInternetConnection") == true {
                    self.reconnect()
                }
            }
        }
        self.reachability.whenUnreachable = { reachability in
            // this is called on a background thread, but UI updates must
            // be on the main thread, like this:
            dispatch_async(dispatch_get_main_queue()) {
                print("Not reachable")
                
                NSUserDefaults.standardUserDefaults().setBool(true, forKey: "didLoseInternetConnection")
                self.disconnect()
            }
        }
        
        do {
            try self.reachability.startNotifier()
        } catch {
            print("Unable to start notifier")
        }
    }
    
    func disconnect() {
        // TODO: should probably put this is a new class
        let notification = CWStatusBarNotification()
        notification.notificationStyle = .NavigationBarNotification
        notification.notificationAnimationInStyle = .Left
        notification.notificationAnimationOutStyle = .Right
        notification.notificationLabelFont = UIFont(name: "OpenSans-Bold", size: 17)!
        notification.notificationLabelTextColor = UIColor.whiteColor()
        notification.notificationLabelBackgroundColor = UIColor(red: 0.9059, green: 0.298, blue: 0.2353, alpha: 1.0) /* #e74c3c red */
        notification.displayNotificationWithMessage("Lost Connection", forDuration: 2.0)
        
        showHUD()
        
        SocketHandler.sharedSocket.closeSocket(true) // to prevent multi handlers when reconnected to internet
    }
    
    func reconnect() {
        let notification = CWStatusBarNotification()
        notification.notificationStyle = .NavigationBarNotification
        notification.notificationAnimationInStyle = .Left
        notification.notificationAnimationOutStyle = .Right
        notification.notificationLabelFont = UIFont(name: "OpenSans-Bold", size: 17)!
        notification.notificationLabelTextColor = UIColor.whiteColor()
        notification.notificationLabelBackgroundColor = UIColor(red: 0.1804, green: 0.8, blue: 0.4431, alpha: 1.0) /* #2ecc71 green */
        notification.displayNotificationWithMessage("Established Connection", forDuration: 1)
        
        // reconnect
        NSTimer.scheduledTimerWithTimeInterval(1.75, target: self, selector: "delayReconnect", userInfo: nil, repeats: false)
    }
    
    func delayReconnect() {
        let username = NSUserDefaults.standardUserDefaults().objectForKey("username") as? String
        let password = NSUserDefaults.standardUserDefaults().objectForKey("password") as? String
        
        if reachability.isReachableViaWiFi() {
            
            if username != nil {
                User.currentUser.login(username!, password: password!)
            }
            
            print("Reachable via WiFi")
        } else {
            
            if NSUserDefaults.standardUserDefaults().objectForKey("username") != nil {
                User.currentUser.login(username!, password: password!)
            }
            
            print("Reachable via Cellular")
        }
        
        dismissHUD()
    }
    
    func showHUD() {
        PKHUD.sharedHUD.contentView = PKHUDProgressView()
        PKHUD.sharedHUD.dimsBackground = true
        PKHUD.sharedHUD.userInteractionOnUnderlyingViewsEnabled = false
        PKHUD.sharedHUD.show()
    }
    
    func dismissHUD() {
        PKHUD.sharedHUD.contentView = PKHUDSuccessView()
        PKHUD.sharedHUD.hide(afterDelay: 1)
    }
}

