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
    
    public var orderString: String
    
    public var status: OrderStatus
    // public var item: T
    public var itemArray: [BentoBox] = [] // to do
    public var itemString: String?
    
    init(json: JSON) {
        self.driverId = json["driverId"].intValue
        self.id = json["id"].stringValue
        self.name = json["name"].stringValue
        self.phone = json["phone"].stringValue
        
        // address
        var address = json["address"]
        self.street = address["street"].stringValue
        self.residence = address["residence"].stringValue
        self.city = address["city"].stringValue
        self.region = address["region"].stringValue
        self.zipCode = address["zipCode"].stringValue
        self.country = address["country"].stringValue
        self.coordinates = CLLocationCoordinate2DMake(address["lat"].doubleValue, address["lng"].doubleValue)

        self.orderString = json["orderString"].stringValue
        
        self.status = OrderStatus.statusFromString(json["status"].stringValue)
        
        // check first letter in Order.id
        let firstCharInString = self.id[self.id.startIndex]
        
        if firstCharInString == "o" {
            for items in json["item"].arrayValue {
                self.itemArray.append(BentoBox(json: items))
            }
        }
        else if firstCharInString == "g" {
            self.itemString = json["item"].stringValue
        }
    }
}
