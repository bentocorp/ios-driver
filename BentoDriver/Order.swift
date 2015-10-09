//
//  Order.swift
//  BentoDriver
//
//  Created by Joseph Lau on 10/8/15.
//  Copyright © 2015 Joseph Lau. All rights reserved.
//

import Foundation
import CoreLocation
import Alamofire

public enum OrderStatus {
    case Pending, Rejected, Completed
    
    func statusFromString(statusString: String)-> OrderStatus {
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
    public var orderId: Int
    public var customerName: String
    public var phoneNumber: String
    public var street: String
    public var residence: String?
    public var city: String
    public var region: String
    public var zipCode: String
    public var county: String
    public var coordinates: CLLocationCoordinate2D
    public var driverId: Int
    public var status: OrderStatus
    
    init(orderId: Int, customerName: String, phoneNumber: String, street: String, city: String, region: String, zipCode: String, country: String, coordinates: CLLocationCoordinate2D, driverId: Int, status: OrderStatus) {
        self.orderId = orderId
        self.customerName = customerName
        self.phoneNumber = phoneNumber
        self.street = street
        self.city = city
        self.region = region
        self.zipCode = zipCode
        self.county = country
        self.coordinates = coordinates
        self.driverId = driverId
        self.status = status
    }
}

//MARK: API
extension Order {
    public class func pullOrders() {
        Alamofire.request(.GET, "http://52.11.208.197:8081/api/order/getAllAssigned", parameters: ["token": "d-8-123ABC"]).responseJSON { response in
            print(response.result )
//            if let ret = response["ret"] {
//                if let dataFromString = ret.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false) {
//                    print(dataFromString)
//                }
//            }

            
            print(response)
        }
    }
}





