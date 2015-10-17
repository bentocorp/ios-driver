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
    
    public var itemClass: String
    // public body: T
    public var bodyOrder: Order?
    public var bodyString: String?
    
    public var createdAt: String
    
    init(json: JSON) {
        self.rid = json["rid"].stringValue // don't need to use for now
        self.from = json["from"].stringValue // don't need to use for now
        self.to = json["to"].stringValue
        self.subject = json["subject"].stringValue
//        self.body = json["body"]
        
        self.itemClass = json["@class"].stringValue
        
        if self.itemClass == "org.bentocorp.Bento" {
            self.bodyOrder = Order(json: json["item"])
        }
        else if self.itemClass == "java.lang.String" {
            self.bodyString = json["item"].stringValue
        }
        
        self.createdAt = json["timeStamp"].stringValue
    }
}
