//
//  OrderAction.swift
//  BentoDriver
//
//  Created by Joseph Lau on 10/19/15.
//  Copyright © 2015 Joseph Lau. All rights reserved.
//

import Foundation
import SwiftyJSON

/*
case Pending
case Rejected
case Completed

static func statusFromString(statusString: String)-> OrderStatus {
switch statusString {
case "PENDING":
return Pending
case "REJECTED":
return Rejected
default:
return Completed
}
}

*/

public enum PushType {
    case CREATE, ASSIGN, REPRIORITIZE, UNASSIGN, UPDATE_STATUS
    
    static func pushTypeFromString(pushTypeString: String) -> PushType {
        switch pushTypeString {
        case "CREATE":
            return CREATE
        case "ASSIGN":
            return ASSIGN
        case "REPRIORITIZE":
            return REPRIORITIZE
        case "UNASSIGN":
            return UNASSIGN
        default:
            return UPDATE_STATUS
        }
    }
}

public class OrderAction {
    public var order: Order?
    public var type: PushType?
    public var after: Int?
    
    // unused for now
//    public var driverId: Int?
    
    init(bodyJSON: JSON) {
        self.order = Order(json: bodyJSON["order"])
        self.type = PushType.pushTypeFromString(bodyJSON["type"].stringValue)
        self.after = bodyJSON["after"].intValue
        
        // unused for now
//        self.driverId = bodyJSON["driverId"].intValue
    }
}

