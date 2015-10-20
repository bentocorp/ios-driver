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

class OrderListViewController: UIViewController, SocketHandlerDelegate, UITableViewDataSource, UITableViewDelegate {

    var ordersArray: Array<Order> = []
    var orderListTableView: UITableView?
    var noTasksLabel: UILabel = UILabel(frame: CGRectMake(0, 0, 100, 20))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Navigation Controller
        let backButton = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.Plain, target: navigationController, action: nil)
        navigationItem.leftBarButtonItem = backButton
        
        let logOutButton = UIBarButtonItem(title: "Log out", style: UIBarButtonItemStyle.Plain, target: self, action: "onLogout")
        navigationItem.rightBarButtonItem = logOutButton

        // Title
        self.title = "Tasks"
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
        self.orderListTableView = UITableView(frame: CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height))
        self.orderListTableView!.delegate = self
        self.orderListTableView!.dataSource = self
        
        // remove empty cells
        let backgroundView = UIView(frame: CGRectZero)
        self.orderListTableView!.tableFooterView = backgroundView
        
        self.view.addSubview(self.orderListTableView!)
        
        // No Tasks Label
        self.noTasksLabel.text = "No Tasks"
        self.noTasksLabel.center = self.view.center
        self.noTasksLabel.textColor = UIColor.lightGrayColor()
        self.view.addSubview(noTasksLabel)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
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
                
                for orderJSON in ret {
                    let order: Order = Order.init(json: orderJSON)
                    print(order.id)
                    
                    self.ordersArray.append(order)
                }
                
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.orderListTableView?.reloadData()
                    
                    // no tasks - TODO: refactor duplicate
                    if self.ordersArray.count == 0 {
                        self.noTasksLabel.hidden = false
                    }
                    else {
                        self.noTasksLabel.hidden = true
                    }
                })
                
                print("getAllAssigned - \(self.ordersArray)")
            })
    }
    
    func socketHandlerDidConnect(connected: Bool) {
        // handle connect...
    }
    
    func socketHandlerDidDisconnect() {
        // handle disconnect...
        self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func socketHandlerDidAuthenticate(authenticated: Bool) {
        // handle authenticate...
    }
    
    func socketHandlerDidRecievePushNotification(push: Push) {
        // handle push...
        
        // check if body order assign or body string
        if push.bodyOrderAction != nil {
            // handle body order assign...
            if push.bodyOrderAction?.type == PushType.ASSIGN {
                // add Order to ordersArray...
                self.ordersArray.append(push.bodyOrderAction!.order!)
            }
            // handle body order unassign
            else if push.bodyOrderAction?.type == PushType.UNASSIGN {
                // loop through all ordersArray to find corresponding Order...
                for (index, order) in self.ordersArray.enumerate() {
                    // match found -> remove that order from ordersArray
                    if order.id == push.bodyOrderAction?.order?.id {
                        self.ordersArray.removeAtIndex(index)
                    }
                }
            }
            
            // no tasks - TODO: refactor duplicate
            if self.ordersArray.count == 0 {
                self.noTasksLabel.hidden = false
            }
            else {
                self.noTasksLabel.hidden = true
            }
        }
        else {
            // handle body string...
        }
        
        self.orderListTableView?.reloadData()
    }
    
    func onLogout() {
        self.confirmLogout()
    }
    
    func confirmLogout() {
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
    
//MARK: Table View
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
        cell?.createdAtLabel.text = "0:00 PM"
        
        print(cell?.frame.width) // i think the last cell is stuck at 320pt...wtf?
        
        return cell!
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        // go to detail screen
        let orderDetailViewController = OrderDetailViewController()
        orderDetailViewController.order = self.ordersArray[indexPath.row]

        self.navigationController?.pushViewController(orderDetailViewController, animated: true)
    }
}





