//
//  DishInfo.swift
//  BentoDriver
//
//  Created by Joseph Lau on 10/16/15.
//  Copyright © 2015 Joseph Lau. All rights reserved.
//

import Foundation
import SwiftyJSON

public enum Type {
    case Main, Side, AddOn
    
    static func typeFromString(typeString: String) -> Type {
        
        let lowercaseString = typeString.lowercaseString
        
        switch lowercaseString {
        case "main":
            return Main
        case "side":
            return Side
        default:
            return AddOn
        }
    }
}

public class DishInfo {
    public var id: Int?
    public var name: String?
    public var type: Type?
    
    public var label: String?
    public var qty: Int?
    
    init (json: JSON) {
        id = json["id"].intValue
        name = json["name"].stringValue
        type = Type.typeFromString(json["type"].stringValue)
        
        if json["qty"] != nil {
            qty = json["qty"].intValue
        }
        else {
            label = json["label"].stringValue
        }
    }
}
