//
//  OrderAction.swift
//  BentoDriver
//
//  Created by Joseph Lau on 10/19/15.
//  Copyright © 2015 Joseph Lau. All rights reserved.
//

import Foundation
import SwiftyJSON

public enum PushType {
    case CREATE, ASSIGN, REPRIORITIZE, UNASSIGN, UPDATE_STATUS
    
    static func pushTypeFromString(pushTypeString: String) -> PushType {
        
        let lowercaseString = pushTypeString.lowercaseString
        
        switch lowercaseString {
        case "create":
            return CREATE
        case "assign":
            return ASSIGN
        case "reprioritize":
            return REPRIORITIZE
        case "unassign":
            return UNASSIGN
        default:
            return UPDATE_STATUS
        }
    }
}

public class OrderAction {
    public var order: Order
    public var type: PushType?
    public var after: String?
    public var driverId: Int?
    
    init(bodyJSON: JSON) {
        order = Order(json: bodyJSON["order"])
        type = PushType.pushTypeFromString(bodyJSON["type"].stringValue)
        after = bodyJSON["after"].stringValue
        driverId = bodyJSON["driverId"].intValue
    }
}

