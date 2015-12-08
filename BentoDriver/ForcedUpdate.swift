//
//  ForcedUpdate.swift
//  BentoDriver
//
//  Created by Joseph Lau on 12/4/15.
//  Copyright © 2015 Joseph Lau. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON
import Alamofire_SwiftyJSON

public class ForcedUpdate {
    static let sharedInstance = ForcedUpdate()
    
    var iOSMinVersion: Double?
    var iOSMinVersionURL: String?
    
    public func getForcedUpdateInfo(completion:(success: Bool) -> Void) {
        
        Alamofire.request(.GET, "\(SocketHandler.sharedSocket.getHoustonAPI())/admin/getForcedUpdateInfo?device_id=ios")
            .responseSwiftyJSON({ (request, response, json, error) in
                
            let code = json["code"]
            print("getForcedUpdate code: \(code)")
            
            let msg = json["msg"]
            print("getForcedUpdate msg = \(msg)")
            
            let ret = json["ret"]
            print("getForcedUpdate ret: \(ret)")
            
            if code != 0 {
                // error...
                completion(success: false)
                print("getForcedUpdateInfo: success = false")
            }
            else {
                self.iOSMinVersion = ret["min_version"].doubleValue
                self.iOSMinVersionURL = ret["min_version_url"].stringValue
                
                completion(success: true)
                print("getForcedUpdateInfo: success = true")
            }
        })
    }
    
    public func isUpToDate() -> Bool {
        if getCurrentiOSVersion() < getiOSMinVersion() {
            return false
        }
        return true
    }
    
    public func getCurrentiOSVersion() -> Double {
        return Double(NSBundle.mainBundle().objectForInfoDictionaryKey("CFBundleShortVersionString") as! String)!
    }
    
    public func getiOSMinVersion() -> Double? {
        return iOSMinVersion
    }
    
    public func getiOSMinVersionURL() -> String? {
        return iOSMinVersionURL
    }
}
