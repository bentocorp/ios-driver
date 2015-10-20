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
    
    public var rid: String
    public var from: String
    public var driverId: Int
    public var to: String
    public var subject: String
    public var createdAt: String
    
    // body - should be generic
    public var bodyOrderAction: OrderAction?
    public var bodyString: String?
    
    init(json: JSON) {
        self.rid = json["rid"].stringValue
        self.from = json["from"].stringValue
        self.driverId = json["driverId"].intValue
        self.to = json["to"].stringValue
        self.subject = json["subject"].stringValue
        self.createdAt = json["timeStamp"].stringValue
        
        if self.subject == "order_action" {
            self.bodyOrderAction = OrderAction(bodyJSON: json["body"])
        }
        else {
            self.bodyString = json["body"]["order"].stringValue
        }
    }
}
