//
//  OrderList.swift
//  BentoDriver
//
//  Created by Joseph Lau on 10/21/15.
//  Copyright © 2015 Joseph Lau. All rights reserved.
//

import Foundation

public class OrderList {
    static let sharedInstance = OrderList() // singleton
    public var orderArray: [Order] = []
}
