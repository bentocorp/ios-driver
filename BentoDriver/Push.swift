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
    public var rid: String // don't need to use for now
    public var from: String // don't need to use for now
    public var to: String
    public var subject: String
    public var body: Order? // this might be a generic
    public var createdAt: String
    
    init(json: JSON) {

        print(json)
        
        self.rid = json["rid"].stringValue // don't need to use for now
        self.from = json["from"].stringValue // don't need to use for now
        self.to = json["to"].stringValue
        self.subject = json["subject"].stringValue
        
        if self.subject == "order_action" {
            self.body = Order(json: json["body"]["order"])
        }
        else {
            // if not order action
        }
        
        // todo: body has typ and order
        
        self.createdAt = json["timeStamp"].stringValue
    }
}
