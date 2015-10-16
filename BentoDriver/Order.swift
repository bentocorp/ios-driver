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

public class Order<T> {
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
    public var item: T
    
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
        self.item = json["item"].arrayValue
    }
}
