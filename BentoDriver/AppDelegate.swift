//
//  AppDelegate.swift
//  BentoDriver
//
//  Created by Joseph Lau on 10/2/15.
//  Copyright © 2015 Joseph Lau. All rights reserved.
//

import UIKit
import CoreLocation

@UIApplicationMain

class AppDelegate: UIResponder, UIApplicationDelegate, CLLocationManagerDelegate {

    var window: UIWindow?
    
//    var backgroundUpdateTask: UIBackgroundTaskIdentifier = 0 // a unique token requesting to run task in background
    var timer = NSTimer() // to invoke startUpdatingLocation every 2.0 seconds
    var locationManager = CLLocationManager() // to update coordinates
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.

        self.window = UIWindow(frame: UIScreen.mainScreen().bounds)
        self.window?.rootViewController = LoginViewController()
        self.window?.makeKeyAndVisible()
        
        // Location Manager
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.distanceFilter = kCLDistanceFilterNone
        self.locationManager.pausesLocationUpdatesAutomatically = false
        self.locationManager.allowsBackgroundLocationUpdates = true
        self.locationManager.requestAlwaysAuthorization()
        self.locationManager.startUpdatingLocation()
        
//        self.timer = NSTimer.scheduledTimerWithTimeInterval(60, target: self, selector: "generateLowMemory", userInfo: nil, repeats: true)
        
        return true
    }
    
//    func generateLowMemory() {
//        UIApplication.sharedApplication().performSelector("_performMemoryWarning")
//    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        
//        self.beginBackgroundUpdateTask()
    }
    
    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
        
//        self.endBackgroundUpdateTask()
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
//MARK: LOCATION SERVICES
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print("Location update failed")
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("Location is updating")
        

        
        NSUserDefaults.standardUserDefaults().setObject(manager.location?.coordinate.latitude, forKey: "lat")
        NSUserDefaults.standardUserDefaults().setObject(manager.location?.coordinate.latitude, forKey: "long")
        NSUserDefaults.standardUserDefaults().synchronize()
        
        let lat = NSUserDefaults.standardUserDefaults().objectForKey("lat")!
        let long = NSUserDefaults.standardUserDefaults().objectForKey("long")!
        
        print("lat: \(lat), long: \(long)")
    }
    
//MARK: BACKGROUND EXECUTION
//    func endBackgroundUpdateTask() {
//        UIApplication.sharedApplication().endBackgroundTask(self.backgroundUpdateTask)
//        self.backgroundUpdateTask = UIBackgroundTaskInvalid
//    }
//    
//    func beginBackgroundUpdateTask() {
//        self.backgroundUpdateTask = UIApplication.sharedApplication().beginBackgroundTaskWithExpirationHandler({
//            self.endBackgroundUpdateTask()
//            self.backgroundUpdateTask = UIBackgroundTaskInvalid
//        })
//        
//        // call startUpdatingLocation every 2.0 seconds
//        self.timer = NSTimer.scheduledTimerWithTimeInterval(2.0, target: self.locationManager, selector: "startUpdatingLocation", userInfo: nil, repeats: true)
//    }
}

