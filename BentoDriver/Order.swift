//
//  Order.swift
//  BentoDriver
//
//  Created by Joseph Lau on 10/8/15.
//  Copyright © 2015 Joseph Lau. All rights reserved.
//

import Foundation
import CoreLocation
import SwiftyJSON

public enum OrderStatus {
    case Pending, Rejected, Accepted, Completed
    
    static func statusFromString(statusString: String)-> OrderStatus {
        
        let lowercaseString = statusString.lowercaseString
        
        switch lowercaseString {
            case "pending":
                return Pending
            case "rejected":
                return Rejected
            case "accepted":
                return Accepted
            default:
                return Completed
        }
    }
}

public class Order: NSObject {
    public var driverId: Int
    public var id: String // either g-424 or b-324, g is generic -> string, b is array for bentos
    public var name: String
    public var phone: String

    /*-Address (Dictionary)-*/
    public var street: String
    public var residence: String?
    public var city: String
    public var region: String
    public var zipCode: String
    public var country: String
    public var coordinates: CLLocationCoordinate2D
    
    public var status: OrderStatus
    // public var item: T
    public var itemArray: [BentoBox] = [] // to do
    public var itemString: String?
    
    public var orderString: String
    
    init(json: JSON) {
        driverId = json["driverId"].intValue
        id = json["id"].stringValue
        name = json["name"].stringValue
        phone = json["phone"].stringValue
        
        // address
        var address = json["address"]
        street = address["street"].stringValue
        residence = address["residence"].stringValue
        city = address["city"].stringValue
        region = address["region"].stringValue
        zipCode = address["zipCode"].stringValue
        country = address["country"].stringValue
        coordinates = CLLocationCoordinate2DMake(address["lat"].doubleValue, address["lng"].doubleValue)
        
        status = OrderStatus.statusFromString(json["status"].stringValue)
        
        // check first letter in Order.id
        let firstCharInString = id[id.startIndex]
        
        if firstCharInString == "o" {
            for itemType in json["item"].arrayValue {
                itemArray.append(BentoBox(json: itemType))
            }
        }
        else if firstCharInString == "g" {
            itemString = json["item"].stringValue
        }
        
        orderString = json["orderString"].stringValue
    }
}
