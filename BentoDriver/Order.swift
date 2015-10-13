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
import Alamofire_SwiftyJSON
import SwiftyJSON

public enum OrderStatus {
    case Pending
    case Rejected
    case Completed
    
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
    // address
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
    
//    func convertJSONStringToDictionary(jsonString: String) -> [String: String]? {
//        if let data = jsonString.dataUsingEncoding(NSUTF8StringEncoding) {
//
//            let json = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions(rawValue: 0)) as? [String: String]
//            if error != nil {
//                print(error)
//            }
//            return json
//        }
//        return nil
//    }
    
    public class func pullOrders() {
        let userToken = NSUserDefaults.standardUserDefaults().objectForKey("userToken")
        
        Alamofire.request(.GET, "http://52.11.208.197:8081/api/order/getAllAssigned", parameters: ["token": userToken!])
            .responseSwiftyJSON({ (request, response, json, error) in
                
                let ret = json["ret"]
                
//                self.convertJSONStringToDictionary(ret)
                
                print("ret: \(ret)")
//                print(json)
//                print(error)
        })
    }
}















