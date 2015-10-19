//
//  Push.swift
//  BentoDriver
//
//  Created by Joseph Lau on 10/16/15.
//  Copyright © 2015 Joseph Lau. All rights reserved.
//

import Foundation
import SwiftyJSON

public class Push {
    public var rid: String // unused for now
    public var from: String // unused for now
    public var driverId: Int // unused for now
    
    public var to: String
    public var subject: String
    public var createdAt: String
    public var type: String
    public var after: Int
    
    // these two should be generic (body)
    public var bodyOrder: Order?
    public var bodyString: String?
    
    init(json: JSON) {
        self.rid = json["rid"].stringValue // unused for now
        self.from = json["from"].stringValue // unused for now
        self.driverId = json["driverId"].intValue // unused for now
        
        self.to = json["to"].stringValue
        self.subject = json["subject"].stringValue
        self.createdAt = json["timeStamp"].stringValue
        self.type = json["type"].stringValue
        self.after = json["after"].intValue
        
        if self.subject == "order_action" {
            self.bodyOrder = Order(json: json["body"]["order"])
        }
        else {
            self.bodyString = json["body"]["order"].stringValue
        }
    }
}
