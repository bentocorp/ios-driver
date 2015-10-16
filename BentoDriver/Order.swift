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
}

public class Order {
    public var id: Int
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
    public var itemClass: String
    // public var item: T
    public var itemArray: [BentoBox]?
    public var itemString: String?
    
    init(json: JSON) {
        self.id = json["id"].intValue
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

        self.status = OrderStatus.statusFromString(json["status"].stringValue)
        
        self.itemClass = json["@class"].stringValue
        if self.itemClass == "org.bentocorp.Bento" {
            for items in json["item"].arrayValue {
                self.itemArray!.append(BentoBox(json: items))
            }
        }
        else if self.itemClass == "java.lang.String" {
            self.itemString = json["item"].stringValue
        }
        
        // check item type
//        if self.itemClass == "org.bentocorp.Bento" {
//            var bentosArray: [BentoBox] = []
//            for items in json["item"].arrayValue { // json["item"].arrayValue is the bentosArray in JSON, we need to deserialize it into array first
//                bentosArray.append(BentoBox(json: items))
//            }
//            self.item = bentosArray
//        }
//        else if self.itemClass == "java.lang.String" {
//            self.item = json["item"].stringValue
//        }
    }
}
