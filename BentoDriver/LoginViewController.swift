//
//  LoginViewController.swift
//  BentoDriver
//
//  Created by Joseph Lau on 10/9/15.
//  Copyright © 2015 Joseph Lau. All rights reserved.
//

import UIKit
import CoreLocation

class LoginViewController: UIViewController, CLLocationManagerDelegate {

//    var locationManager: CLLocationManager?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.whiteColor()
        
        let loginButton = UIButton(frame: CGRectMake(100, 100, 100, 100))
        loginButton.backgroundColor = UIColor.greenColor()
        loginButton.setTitle("Login", forState: .Normal)
        loginButton.addTarget(self, action: "onLogin", forControlEvents: .TouchUpInside)
        self.view.addSubview(loginButton)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func onLogin() {
        User.login("marc@bentonow.com", password: "wordpass")
        
        // location manager
//        self.locationManager = CLLocationManager()
//        self.locationManager!.delegate = self
//        self.locationManager!.desiredAccuracy = kCLLocationAccuracyBest
//        self.locationManager!.distanceFilter = kCLDistanceFilterNone
//        self.locationManager!.pausesLocationUpdatesAutomatically = false
//        self.locationManager!.allowsBackgroundLocationUpdates = true
//        self.locationManager!.requestAlwaysAuthorization()
//        self.locationManager!.startUpdatingLocation()
    }
    
//    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
//        print("Location failed")
//    }
//    
//    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//        print("Time remaining - \(UIApplication.sharedApplication().backgroundTimeRemaining)")
//    }
}
