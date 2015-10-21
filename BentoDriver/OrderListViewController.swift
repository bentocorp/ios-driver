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
import SwiftyJSON
import Alamofire_SwiftyJSON

class OrderListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, SocketHandlerDelegate, OrderDetailViewControllerDelegate {

    var ordersArray: Array<Order> = []
    var orderListTableView: UITableView?
    var noTasksLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = UIColor.lightGrayColor()
        
        // Navigation Controller
        let backButton = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.Plain, target: navigationController, action: nil)
        navigationItem.leftBarButtonItem = backButton
        
        let logOutButton = UIBarButtonItem(title: "Log out", style: UIBarButtonItemStyle.Plain, target: self, action: "onLogout")
        navigationItem.rightBarButtonItem = logOutButton

        // Title
        self.title = "Tasks"
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
//        self.navigationController?.navigationBar.barTintColor = UIColor.magentaColor()
        self.navigationController?.navigationBar.barStyle = .Black
        
        // Delegate
        let socket = SocketHandler.sharedSocket
        socket.delegate = self;
        
        // Get orders
        self.pullOrders()
        
        // Table View
        self.orderListTableView = UITableView(frame: CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height))
        self.orderListTableView!.delegate = self
        self.orderListTableView!.dataSource = self
        // remove empty cells
        let backgroundView = UIView(frame: CGRectZero)
        self.orderListTableView!.tableFooterView = backgroundView
        self.orderListTableView!.backgroundColor = UIColor.clearColor()
        self.view.addSubview(self.orderListTableView!)
        
        // No Tasks Label
        self.noTasksLabel = UILabel(frame: CGRectMake(self.view.frame.width/2 - 50, self.view.frame.height/2 - 10, 100, 20))
        self.noTasksLabel.text = "No Tasks"
        self.noTasksLabel.textAlignment = .Center
        self.noTasksLabel.font = UIFont(name: "OpenSans-SemiBold", size: 17)
        self.noTasksLabel.textColor = UIColor.grayColor()
        self.noTasksLabel.hidden = true
        self.view.addSubview(noTasksLabel)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(animated: Bool) {
//        self.orderListTableView?.reloadData()
    }

//MARK: Houston - getAllAssigned
    func pullOrders() {
        
        // get all assigned orders
        Alamofire.request(.GET, "http://52.11.208.197:8081/api/order/getAllAssigned", parameters: ["token": User.currentUser.token!])
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
                
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    
                    // add orders to ordersArray
                    for orderJSON in ret {
                        let order: Order = Order.init(json: orderJSON)
                        print(order.id)
                        
                        // filter out rejected orders
                        if order.status != .Rejected {
                            self.ordersArray.append(order)
                        }
                    }
                    
                    
                    self.orderListTableView?.reloadData()
                    self.showOrHideNoTasksLabel()
                })
                
                print("getAllAssigned - \(self.ordersArray)")
            })
    }
    
    func showOrHideNoTasksLabel() {
        if self.ordersArray.count == 0 {
            self.noTasksLabel.hidden = false
        }
        else {
            self.noTasksLabel.hidden = true
        }
    }

//MARK: Log Out
    func onLogout() {
        self.promptLogoutConfirmationAlert()
    }
    
    func promptLogoutConfirmationAlert() {
        let alertController = UIAlertController(title: "", message: "Save login info?", preferredStyle: .Alert)
        
        alertController.addAction(UIAlertAction(title: "Yes", style: .Default, handler: { action in
            SocketHandler.sharedSocket.closeSocket()
        }))
        
        alertController.addAction(UIAlertAction(title: "No", style: .Default, handler: { action in
            SocketHandler.sharedSocket.closeSocket()
            
            NSUserDefaults.standardUserDefaults().setObject("", forKey: "username")
            NSUserDefaults.standardUserDefaults().setObject("", forKey: "password")
            NSUserDefaults.standardUserDefaults().synchronize()
        }))
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .Destructive, handler: nil))
        
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
//MARK: Table View Datasource
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.ordersArray.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cellId = "Cell"
        
        var cell = tableView.dequeueReusableCellWithIdentifier(cellId) as? OrderListCell
        
        if cell == nil {
            cell = OrderListCell(style: UITableViewCellStyle.Default, reuseIdentifier: cellId)
        }
        
        let order = self.ordersArray[indexPath.row]
        
        cell?.addressLabel.text = "\(order.street)\n\(order.city)"
        cell?.nameLabel.text = order.name
        cell?.circleImageView.image = UIImage(named: "yellow-circle-64")
        cell?.createdAtLabel.text = "0:00 PM"
        
        print(cell?.frame.width) // i think the last cell is stuck at 320pt...wtf?
        
        return cell!
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        // go to detail screen
        let orderDetailViewController = OrderDetailViewController()
        orderDetailViewController.delegate = self
        orderDetailViewController.order = self.ordersArray[indexPath.row]

        self.navigationController?.pushViewController(orderDetailViewController, animated: true)
    }
    
//MARK: SocketHandlerDelegate
    func socketHandlerDidDisconnect() {
        // handle disconnect...
        self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func socketHandlerDidAssignOrder(assignedOrder: Order) {
        // handler assigned order...
        self.ordersArray.append(assignedOrder)
        
        SocketHandler.sharedSocket.promptLocalNotification("assigned")
        self.showOrHideNoTasksLabel()
        self.orderListTableView?.reloadData()
    }
    
    func socketHandlerDidUnassignOrder(unassignedOrder: Order) {
        // handle unassigned order...
        // loop through all ordersArray to find corresponding Order...
        for (index, order) in self.ordersArray.enumerate() {
            // once found, remove
            if order.id == unassignedOrder.id {
                self.ordersArray.removeAtIndex(index)
            }
        }
        
        SocketHandler.sharedSocket.promptLocalNotification("unassigned")
        self.showOrHideNoTasksLabel()
        self.orderListTableView?.reloadData()
    }
    
//MARK: OrderDetailViewControllerDelegate
    func didAcceptOrder(orderId: String) {
        // handle accepted order...
        
        for (index, order) in self.ordersArray.enumerate() {
            if order.id == orderId {
                self.ordersArray[index].status = .Accepted
            }
        }
        
        self.orderListTableView?.reloadData()
        self.showOrHideNoTasksLabel()
    }
    
    func didCompleteOrder(orderId: String) {
        // handle completed order...
        self.removeOrder(orderId)
        
        self.orderListTableView?.reloadData()
        self.showOrHideNoTasksLabel()
    }
    
    func didRejectOrder(orderId: String) {
        // handle rejected order...
        self.removeOrder(orderId)
        
        self.orderListTableView?.reloadData()
        self.showOrHideNoTasksLabel()
    }
    
    func removeOrder(orderId: String) {
        for (index, order) in self.ordersArray.enumerate() {
            if order.id == orderId {
                self.ordersArray.removeAtIndex(index)
            }
        }
    }
}
