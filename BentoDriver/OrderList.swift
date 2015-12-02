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


public class OrderList {
    static let sharedInstance = OrderList() // singleton
    public var orderArray: [Order] = []
}

extension OrderList {
    public func pullOrders(completion: (result: JSON) -> Void) {
        
        // get all assigned orders
        Alamofire.request(.GET, "\(SocketHandler.sharedSocket.getHoustonAPI())/order/getAllAssigned", parameters: ["token": User.currentUser.token!])
            .responseSwiftyJSON({ (request, response, json, error) in
                
                let code = json["code"]
                print("code: \(code)")
                
                let msg = json["msg"]
                print("msg = \(msg)")
                
                let ret = json["ret"].arrayValue
                print("ret: \(ret)")
                
                // Handle error...
                if code != 0 {
                    print(msg)
                    return
                }
                
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    
                    // add orders to ordersArray
                    for orderJSON in ret {
                        let order: Order = Order.init(json: orderJSON)
                        print(order.id)
                        
                        self.orderArray.append(order)
                        print(order.status)
                    }
                    
                    completion(result: json)
                })
                
                print("getAllAssigned count - \(self.orderArray.count)")
                print("getAllAssigned - \(self.orderArray)")
            })
    }
    
    public func removeOrder(orderToRemove: Order) {
        // loop through all ordersArray to find corresponding Order, then remove it...
        for (index, order) in OrderList.sharedInstance.orderArray.enumerate() {
            // once found, remove
            if order.id == orderToRemove.id {
                OrderList.sharedInstance.orderArray.removeAtIndex(index)
            }
        }
    }
    
    public func reprioritizeOrder(orderToReprioritize: Order, afterId: String?) {
        
        // remove reproritized order...
        self.removeOrder(orderToReprioritize)
        
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
}
