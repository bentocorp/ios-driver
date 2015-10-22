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
    public var label: String?
    public var name: String?
    public var type: Type?
    
    init (json: JSON) {
        self.id = json["id"].intValue
        self.label = json["label"].stringValue
        self.name = json["name"].stringValue
        self.type = Type.typeFromString(json["type"].stringValue)
    }
}
