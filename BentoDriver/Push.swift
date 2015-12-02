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
    public var to: String
    public var subject: String
    public var createdAt: String
    
    // body - is it OrderAction or a String?
    public var bodyOrderAction: OrderAction?
    public var bodyString: String?
    
    init(json: JSON) {
        rid = json["rid"].stringValue
        from = json["from"].stringValue
        to = json["to"].stringValue
        subject = json["subject"].stringValue
        createdAt = json["timeStamp"].stringValue
        
        if subject == "order_action" {
            bodyOrderAction = OrderAction(bodyJSON: json["body"])
        }
        else {
            bodyString = json["body"]["order"].stringValue
        }
    }
}
