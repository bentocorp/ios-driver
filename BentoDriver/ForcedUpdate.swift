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
    
    public func isUpToDate() -> Bool {
        
        var isUpToDate = true
        
        Alamofire.request(.GET, "\(SocketHandler.sharedSocket.getHoustonAPI())/order/getForcedUpdate")
            .responseSwiftyJSON({ (request, response, json, error) in
                
                let code = json["code"]
                print("getForcedUpdate code: \(code)")
                
                let msg = json["msg"]
                print("getForcedUpdate msg = \(msg)")
                
                let ret = json["ret"]
                print("getForcedUpdate ret: \(ret)")
                
                if code != 0 {
                    let iOSMinVersion = ret[""].stringValue
                    
                    if let currentVersion = NSBundle.mainBundle().infoDictionary!["CFBundleVersion"] as? String {
                        if currentVersion != iOSMinVersion {
                            isUpToDate = false
                        }
                    }
                }
        })
        
        return isUpToDate
    }
}
