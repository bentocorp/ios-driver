//
//  MapSetting.swift
//  BentoDriver
//
//  Created by Joseph Lau on 12/2/15.
//  Copyright © 2015 Joseph Lau. All rights reserved.
//

import Foundation
import UIKit

public class MapSetting {
    static let sharedMapSetting = MapSetting()
    
    public func isWazeInstalled() -> Bool {
        if UIApplication.sharedApplication().canOpenURL(NSURL(string: "waze://")!) == true {
            return true
        }
        
        return false
    }
    
    public func isGoogleMapsInstalled() -> Bool {
        if UIApplication.sharedApplication().canOpenURL(NSURL(string: "comgooglemaps://")!) == true {
            return true
        }
        
        return false
    }
    
    public func setWaze() {
        NSUserDefaults.standardUserDefaults().setObject("Waze", forKey: "map")
    }
    
    public func setGoogleMaps() {
        NSUserDefaults.standardUserDefaults().setObject("Google Maps", forKey: "map")
    }
    
    public func setToNone() {
        NSUserDefaults.standardUserDefaults().setObject("None", forKey: "map")
    }
    
    public func getCurrentMapSetting() -> String {
        let currentMapSetting = NSUserDefaults.standardUserDefaults().objectForKey("map") as? String
        
        if currentMapSetting == "Waze" {
            return "Waze"
        }
        else if currentMapSetting == "Google Maps" {
            return "Google Maps"
        }
        
        return "None"
    }
    
    public func gotoAppStoreWaze() {
        UIApplication.sharedApplication().openURL(NSURL(string: "http://itunes.apple.com/us/app/id323229106")!)
    }
    
    public func gotoAppStoreGoogleMaps() {
        UIApplication.sharedApplication().openURL(NSURL(string: "https://itunes.apple.com/us/app/google-maps/id585027354?mt=8")!)
    }
}
