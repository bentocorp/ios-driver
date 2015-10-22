//
//  OrderList.swift
//  BentoDriver
//
//  Created by Joseph Lau on 10/21/15.
//  Copyright © 2015 Joseph Lau. All rights reserved.
//

import Foundation

//public class OrderList: SocketHandlerDelegate, OrderDetailViewControllerDelegate {
public class OrderList {
    static let sharedInstance = OrderList() // singleton
    public var orderArray: [Order] = []
    public var taskInSession: Bool?
//    
//    init() {
//        // Set delegates
//        SocketHandler.sharedSocket.delegate = self
//        OrderDetailViewController().delegate = self
//    }
//    
////MARK: SocketHandlerDelegate
//    @objc func socketHandlerDidAssignOrder(assignedOrder: Order) {
//        // add order to list
//        OrderList.sharedInstance.orderArray.append(assignedOrder)
//        
//        SocketHandler.sharedSocket.promptLocalNotification("assigned")
//    }
//    
//    @objc func socketHandlerDidUnassignOrder(unassignedOrder: Order) {
//        // loop through all ordersArray to find corresponding Order...
//        for (index, order) in OrderList.sharedInstance.orderArray.enumerate() {
//            // once found, remove
//            if order.id == unassignedOrder.id {
//                OrderList.sharedInstance.orderArray.removeAtIndex(index)
//            }
//        }
//        
//        SocketHandler.sharedSocket.promptLocalNotification("unassigned")
//    }
//    
////MARK: OrderDetailViewControllerDelegate
//    
//    func didRejectOrder(orderId: String) {
//        // handle rejected order...
//        self.removeOrder(orderId)
//    }
//    
//    func didAcceptOrder(orderId: String) {
//        // handle accepted order...
//        
//        // search for order then reset status
//        for (index, order) in OrderList.sharedInstance.orderArray.enumerate() {
//            if order.id == orderId {
//                OrderList.sharedInstance.orderArray[index].status = .Accepted
//            }
//        }
//    }
//    
//    func didCompleteOrder(orderId: String) {
//        // handle completed order...
//        self.removeOrder(orderId)
//    }
//    
////MARK: Remove Order (reject, complete)
//    func removeOrder(orderId: String) {
//        // remove a specific order
//        for (index, order) in OrderList.sharedInstance.orderArray.enumerate() {
//            if order.id == orderId {
//                OrderList.sharedInstance.orderArray.removeAtIndex(index)
//            }
//        }
//    }
}
