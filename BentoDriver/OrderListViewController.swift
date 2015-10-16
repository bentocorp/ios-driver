//
//  OrderListViewController.swift
//  BentoDriver
//
//  Created by Joseph Lau on 10/9/15.
//  Copyright © 2015 Joseph Lau. All rights reserved.
//

import UIKit
import CoreLocation
import Alamofire
import Alamofire_SwiftyJSON
import SwiftyJSON

class OrderListViewController: UIViewController {

    var ordersArray: Array<Order> = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Navigation Controller
        self.navigationController?.navigationBarHidden = false
        
        let backButton = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.Plain, target: navigationController, action: nil)
        navigationItem.leftBarButtonItem = backButton
        
        let logOutButton = UIBarButtonItem(title: "Log out", style: UIBarButtonItemStyle.Plain, target: navigationController, action: nil)
        navigationItem.rightBarButtonItem = logOutButton
        
        // Background Color
        self.view.backgroundColor = UIColor.whiteColor()
        
        // Title
        self.title = "Order List"
        
        // User Info
        let connectedAsLabel = UILabel(frame: CGRectMake(20, 80, 110, 30))
        connectedAsLabel.text = "Logged in as:"
        self.view.addSubview(connectedAsLabel)
        
        let usernameLabel = UILabel(frame: CGRectMake((connectedAsLabel.frame.width + 25), 80, 200, 30))
        usernameLabel.text = User.currentUser.token
        self.view.addSubview(usernameLabel)
        
        // Get orders
        self.pullOrders()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func orderModelDidGetOrders(ordersArray: Array<Order>) {
        self.ordersArray = ordersArray
    }
    
    func pullOrders() {
        
        let token = User.currentUser.token
        
        // get all assigned orders
        Alamofire.request(.GET, "http://52.11.208.197:8081/api/order/getAllAssigned", parameters: ["token": token!])
            .responseSwiftyJSON({ (request, response, json, error) in
                
                let code = json["code"]
                let msg = json["msg"]
                
                print("code: \(code)")
                print("msg = \(msg)")
                
                if code != 0 {
                    print(msg)
                    return
                }
                
                let ret = json["ret"].arrayValue
                print("ret: \(ret)")
                
                for orderJSON in ret {
                    let order: Order = Order.init(json: orderJSON)
                    print(order.id)
                    
                    self.ordersArray.append(order)
                }
                
                print("hello marc - \(self.ordersArray)")
            })
    }
}
