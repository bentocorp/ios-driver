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

class OrderListViewController: UIViewController, SocketHandlerDelegate, UITableViewDataSource, UITableViewDelegate {

    var ordersArray: Array<Order> = []
    var orderListTableView: UITableView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Navigation Controller
        let backButton = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.Plain, target: navigationController, action: nil)
        navigationItem.leftBarButtonItem = backButton
        
        let logOutButton = UIBarButtonItem(title: "Log out", style: UIBarButtonItemStyle.Plain, target: self, action: "onLogout")
        navigationItem.rightBarButtonItem = logOutButton

        // Title
        self.title = "Orders"
        self.navigationController?.navigationBar.tintColor = UIColor.darkGrayColor()
        
        // User Info
//        let connectedAsLabel = UILabel(frame: CGRectMake(20, 80, 110, 30))
//        connectedAsLabel.text = "Logged in as:"
//        self.view.addSubview(connectedAsLabel)
//        
//        let usernameLabel = UILabel(frame: CGRectMake((connectedAsLabel.frame.width + 25), 80, 200, 30))
//        usernameLabel.text = User.currentUser.token
//        self.view.addSubview(usernameLabel)
        
        let socket = SocketHandler.sharedSocket
        socket.delegate = self;
        
        // Get orders
        self.pullOrders()
        
        // Table View
        self.orderListTableView = UITableView(frame: CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height))
        self.orderListTableView!.delegate = self
        self.orderListTableView!.dataSource = self
        
        // remove empty cells
        let backgroundView = UIView(frame: CGRectZero)
        self.orderListTableView!.tableFooterView = backgroundView
        
        self.view.addSubview(self.orderListTableView!)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
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
                
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.orderListTableView?.reloadData()
                })
                
                print("getAllAssigned - \(self.ordersArray)")
            })
    }
    
    func socketHandlerDidConnect(connected: Bool) {
        // handle connect
    }
    
    func socketHandlerDidDisconnect() {
        // handle disconnect
        self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func socketHandlerDidAuthenticate(authenticated: Bool) {
        // handle authenticate
    }
    
    func socketHandlerDidRecievePushNotification(push: Push) {
        // handle push
        ordersArray.append(push.body!) // if Order is bentosArray
        self.orderListTableView?.reloadData()
    }
    
    func onLogout() {
        self.confirmLogout()
    }
    
    func confirmLogout() {
        let alertController = UIAlertController(title: "", message: "Are you sure you want to log out?", preferredStyle: .Alert)
        
        // ok
        alertController.addAction(UIAlertAction(title: "OK", style: .Default, handler: { action in
            // close socket
            SocketHandler.sharedSocket.closeSocket()
        }))
        
        // cancel
        alertController.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
        
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
//MARK: Table View
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 75
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.ordersArray.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cellId = "Cell"
        
        var cell = tableView.dequeueReusableCellWithIdentifier(cellId)
        
        if cell == nil {
            cell = UITableViewCell(style: .Default, reuseIdentifier: cellId)
        }
        let order = ordersArray[indexPath.row]
        
        cell?.textLabel!.text = order.name
        cell?.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
        
        return cell!
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        // go to detail screen
        let orderDetailViewController = OrderDetailViewController()
        orderDetailViewController.title = self.ordersArray[indexPath.row].name

        self.navigationController?.pushViewController(orderDetailViewController, animated: true)
    }
}





