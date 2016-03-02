//
//  OrderList.swift
//  BentoDriver
//
//  Created by Joseph Lau on 10/21/15.
//  Copyright © 2015 Joseph Lau. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON
import Alamofire_SwiftyJSON
import Mixpanel

public class OrderList {
    static let sharedInstance = OrderList() // singleton
    public var orderArray: [Order] = []
}

extension OrderList {
    public func pullOrders(completion: (result: JSON) -> Void) {
        
        // get all assigned orders
        Alamofire.request(.GET, "\(SocketHandler.sharedSocket.getHoustonAPI())/api/order/getAllAssigned", parameters: ["token": User.currentUser.token!]).validate().responseJSON { response in
            
            switch response.result {
            case .Success:
                if let value = response.result.value {

                    let json = JSON(value)
                    
                    let code = json["code"]
                    print("code: \(code)")
                    
                    let msg = json["msg"]
                    print("msg = \(msg)")
                    
                    let ret = json["ret"].arrayValue
                    print("ret: \(ret)")
                    
                    // Handle error...
                    if code != 0 {
                        print(msg)
                        
                        Mixpanel.sharedInstance().track("Called getAllAssigned", properties: [
                            "api": "\(SocketHandler.sharedSocket.getHoustonAPI())/api/order/getAllAssigned?token=\(User.currentUser.token!)",
                            "code": "\(code)",
                            "msg": "\(msg)",
                            "count": "N/A"
                            ]
                        )
                    }
                    else {
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            
                            // add orders to ordersArray
                            for orderJSON in ret {
                                let order: Order = Order.init(json: orderJSON)
                                print(order.id)
                                
                                self.orderArray.append(order)
                                print(order.status)
                            }
                            
                            completion(result: json)
                            
                            print("getAllAssigned count - \(self.orderArray.count)")
                            print("getAllAssigned - \(self.orderArray)")
                            
                            Mixpanel.sharedInstance().track("Called getAllAssigned", properties: [
                                "api": "\(SocketHandler.sharedSocket.getHoustonAPI())/api/order/getAllAssigned?token=\(User.currentUser.token!)",
                                "code": "\(code)",
                                "msg": "\(msg)",
                                "count": "\(self.orderArray.count)"
                                ]
                            )
                        })
                    }
                }
            case .Failure(let error):
                print(error)
                
                print("/getAllAssigned Error - \(error.debugDescription)")
                
                Mixpanel.sharedInstance().track("Called getAllAssigned", properties: [
                    "api": "\(SocketHandler.sharedSocket.getHoustonAPI())/api/order/getAllAssigned?token=\(User.currentUser.token!)",
                    "error": error.debugDescription
                    ]
                )
                
                completion(result: nil)
            }
        }
       
//        Alamofire.request(.GET, "\(SocketHandler.sharedSocket.getHoustonAPI())/api/order/getAllAssigned", parameters: ["token": User.currentUser.token!])
//            .responseSwiftyJSON({ (request, response, json, error) in
//                
//                print(response?.allHeaderFields)
//                
//                if error == nil {
//                    
//                    let code = json["code"]
//                    print("code: \(code)")
//                    
//                    let msg = json["msg"]
//                    print("msg = \(msg)")
//                    
//                    let ret = json["ret"].arrayValue
//                    print("ret: \(ret)")
//                
//                    // Handle error...
//                    if code != 0 {
//                        print(msg)
//                        
//                        Mixpanel.sharedInstance().track("Called getAllAssigned", properties: [
//                            "api": "\(SocketHandler.sharedSocket.getHoustonAPI())/api/order/getAllAssigned?token=\(User.currentUser.token!)",
//                            "code": "\(code)",
//                            "msg": "\(msg)",
//                            "count": "N/A"
//                            ]
//                        )
//                        
//                        // handler houston error
//                    }
//                    else {
//                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
//                            
//                            // add orders to ordersArray
//                            for orderJSON in ret {
//                                let order: Order = Order.init(json: orderJSON)
//                                print(order.id)
//                                
//                                self.orderArray.append(order)
//                                print(order.status)
//                            }
//                            
//                            completion(result: json)
//                            
//                            print("getAllAssigned count - \(self.orderArray.count)")
//                            print("getAllAssigned - \(self.orderArray)")
//                            
//                            Mixpanel.sharedInstance().track("Called getAllAssigned", properties: [
//                                "api": "\(SocketHandler.sharedSocket.getHoustonAPI())/api/order/getAllAssigned?token=\(User.currentUser.token!)",
//                                "code": "\(code)",
//                                "msg": "\(msg)",
//                                "count": "\(self.orderArray.count)"
//                                ]
//                            )
//                        })
//                    }
//                }
//                else {
//                    print("/getAllAssigned Error - \(error.debugDescription)")
//                    
//                    Mixpanel.sharedInstance().track("Called getAllAssigned", properties: [
//                        "api": "\(SocketHandler.sharedSocket.getHoustonAPI())/api/order/getAllAssigned?token=\(User.currentUser.token!)",
//                        "error": error.debugDescription
//                        ]
//                    )
//                    
//                    completion(result: json)
//                }
//            })
    }
    
    public func removeOrder(orderToRemove: Order) {
        // loop through all ordersArray to find corresponding Order, then remove it...
        for (index, order) in OrderList.sharedInstance.orderArray.enumerate() {
            // once found, remove
            if order.id == orderToRemove.id {
                orderArray.removeAtIndex(index)
            }
        }
    }
    
    public func reprioritizeOrder(orderToReprioritize: Order, afterId: String?) {
        
        // remove reproritized order...
        removeOrder(orderToReprioritize)
        
        if afterId == "" { // null
            // add to last index of array
            orderArray.append(orderToReprioritize)
        }
        else {
            // loop through order list
            let initialCount = orderArray.count
            for var i = 0; i < initialCount; i++ {
                
                print("id in array: \(orderArray[i].id)")
                print("after id: \(afterId)")
                
                // search for the order id that matches with "after: id" (insertBeforeOrderId)
                if orderArray[i].id == afterId {
                    
                    // reinsert reprioritize order in front of insertBeforeOrderId
                    orderArray.insert(orderToReprioritize, atIndex: i)
                    break
                }
            }
        }
    }
    
    public func modifyOrder(orderToModify: Order) {
        for (index, order) in OrderList.sharedInstance.orderArray.enumerate() {
            if order.id == orderToModify.id {
                
                if orderToModify.id == orderArray[0].id {
                    orderArray.removeAtIndex(index)
                    orderArray.insert(orderToModify, atIndex: 0)
                }
                else {
                    orderArray.removeAtIndex(index)
                    orderArray.insert(orderToModify, atIndex: index)
                }
            }
        }
    }
}







