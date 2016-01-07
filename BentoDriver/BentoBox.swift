//
//  BentoBox.swift
//  BentoDriver
//
//  Created by Joseph Lau on 10/12/15.
//  Copyright © 2015 Joseph Lau. All rights reserved.
//

import Foundation
import SwiftyJSON

public enum ItemType {
    case BentoBox, Addon
    
    static func typeFromString(type: String)-> ItemType {
        
        let lowercaseString = type.lowercaseString
        
        switch lowercaseString {
        case "customerbentobox":
            return BentoBox
        default:
            return Addon
        }
    }
}

public class BentoBox {
    public var items: [DishInfo] = []
    public var itemType: ItemType?
    
    init(json: JSON) {
        for dishJSON in json["items"].arrayValue {
            items.append(DishInfo(json: dishJSON))
        }
        
        itemType = ItemType.typeFromString(json["item_type"].stringValue)
    }
}
