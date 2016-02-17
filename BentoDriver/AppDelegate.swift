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
import Fabric
import Crashlytics
import Mixpanel

@UIApplicationMain

class AppDelegate: UIResponder, UIApplicationDelegate, CLLocationManagerDelegate {

    var window: UIWindow?
    let locationManager = CLLocationManager()
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        
        // FABRIC
        Fabric.sharedSDK().debug = true // for answers
        Fabric.with([Crashlytics.self]) // for crash reports
        
        // MIXPANEL
        #if DEBUG
        #else
            Mixpanel.sharedInstanceWithToken("f2923ee2de657a03cb959ee13c216ac2")
        #endif
        
        self.window = UIWindow(frame: UIScreen.mainScreen().bounds)
        
        let orderListVC = LoginViewController()
        let navC = UINavigationController(rootViewController: orderListVC)
        
        self.window?.rootViewController = navC
        self.window?.makeKeyAndVisible()
        
        // Location Services
        self.initiateLocationManager()
    
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
        
        Mixpanel.sharedInstance().track("applicationDidEnterBackground")
    }
    
    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
        
        // let subscribers know of didEnterForeground
        NSNotificationCenter.defaultCenter().postNotificationName("didEnterForeground", object: nil)
        
        Mixpanel.sharedInstance().track("applicationWillEnterForeground")
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        
        // reset notification badge
        application.applicationIconBadgeNumber = 0
    }
    
    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        
        NSUserDefaults.standardUserDefaults().setBool(false, forKey: "isLoggedIn")
        
        Mixpanel.sharedInstance().track("applicationWillTerminate")
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
}

