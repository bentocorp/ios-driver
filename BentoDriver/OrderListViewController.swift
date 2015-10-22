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
import PKHUD

class OrderListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, SocketHandlerDelegate, OrderDetailViewControllerDelegate {
    
    let notification = CWStatusBarNotification()
    var orderListTableView: UITableView?
    var noTasksLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UIApplication.sharedApplication().idleTimerDisabled = true // lock screen once logged in

        // Navigation Bar
        self.view.backgroundColor = UIColor(red: 0.0392, green: 0.1373, blue: 0.1765, alpha: 1.0) /* #0a232d */
        self.title = "Tasks"
        self.navigationController?.navigationBar.barTintColor = UIColor(red: 0.0392, green: 0.1373, blue: 0.1765, alpha: 1.0) /* #0a232d */
        self.navigationController?.navigationBar.titleTextAttributes = [NSFontAttributeName: UIFont(name: "OpenSans-Bold", size: 17)!]
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        
        // Navigation Bar Item
        let backButton = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.Plain, target: navigationController, action: nil)
        navigationItem.leftBarButtonItem = backButton
        
        // Log out
        let logOutButton = UIBarButtonItem(title: "Log out", style: UIBarButtonItemStyle.Plain, target: self, action: "onLogout")
        logOutButton.setTitleTextAttributes([NSFontAttributeName: UIFont(name: "OpenSans-SemiBold", size: 14)!], forState: .Normal)
        navigationItem.rightBarButtonItem = logOutButton
        
        // Get orders
        self.pullOrders()
        
        // Table View
        self.orderListTableView = UITableView(frame: CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height))
        self.orderListTableView!.delegate = self
        self.orderListTableView!.dataSource = self
        let backgroundView = UIView(frame: CGRectZero) // remove empty cells
        self.orderListTableView!.tableFooterView = backgroundView // remove empty cells
        self.orderListTableView!.backgroundColor = UIColor.clearColor()
        self.view.addSubview(self.orderListTableView!)
        
        // No Tasks Label
        self.noTasksLabel = UILabel(frame: CGRectMake(self.view.frame.width/2 - 50, self.view.frame.height/2 - 10, 100, 20))
        self.noTasksLabel.text = "No Tasks"
        self.noTasksLabel.textAlignment = .Center
        self.noTasksLabel.font = UIFont(name: "OpenSans-SemiBold", size: 17)
        self.noTasksLabel.textColor = UIColor.darkGrayColor()
        self.noTasksLabel.hidden = true
        self.view.addSubview(noTasksLabel)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(animated: Bool) {
        SocketHandler.sharedSocket.delegate = self // Delegate
        self.updateUI()
    }
    
//MARK: Status Bar
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
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
                            OrderList.sharedInstance.orderArray.append(order)
                        }
                    }
                    
                    PKHUD.sharedHUD.contentView = PKHUDSuccessView()
                    PKHUD.sharedHUD.hide(afterDelay: 0)
                    
                    self.updateUI()
                })
                
                print("getAllAssigned count - \(OrderList.sharedInstance.orderArray.count)")
                print("getAllAssigned - \(OrderList.sharedInstance.orderArray)")
            })
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
        return 100
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return OrderList.sharedInstance.orderArray.count
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {

    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cellId = "Cell"
        
        var cell = tableView.dequeueReusableCellWithIdentifier(cellId) as? OrderListCell
        
        if cell == nil {
            cell = OrderListCell(style: UITableViewCellStyle.Default, reuseIdentifier: cellId)
        }
        
        let order = OrderList.sharedInstance.orderArray[indexPath.row]
        
        cell?.addressLabel.text = "\(order.street)\n\(order.city)"
        cell?.nameLabel.text = order.name
        
        switch order.status{
        case .Accepted:
            cell?.circleImageView.image = UIImage(named: "green-moon-64")
        case .Rejected:
            cell?.circleImageView.image = UIImage(named: "red-moon-64")
        default:
            cell?.circleImageView.image = UIImage(named: "yellow-moon-64")
        }
        
        // fade in cell
        cell?.alpha = 0
        UIView.animateWithDuration(0.5, animations: { cell?.alpha = 1 })
        
        print(cell?.frame.width) // cell is stuck at 320pt...wtf?
        
        return cell!
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        // go to detail screen
        let orderDetailViewController = OrderDetailViewController()
        orderDetailViewController.delegate = self
        orderDetailViewController.order = OrderList.sharedInstance.orderArray[indexPath.row]

        self.navigationController?.pushViewController(orderDetailViewController, animated: true)
    }
    
//MARK: SocketHandlerDelegate
    func socketHandlerDidDisconnect() {
        self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func socketHandlerDidAssignOrder(assignedOrder: Order) {
        // add order to list
        OrderList.sharedInstance.orderArray.append(assignedOrder)
        
        SocketHandler.sharedSocket.promptLocalNotification("assigned")
        self.taskHasBeenAssignedOrUnassigned("A new task has been assigned!")
        
        self.updateUI()
    }
    
    func socketHandlerDidUnassignOrder(unassignedOrder: Order) {
        // loop through all ordersArray to find corresponding Order...
        for (index, order) in OrderList.sharedInstance.orderArray.enumerate() {
            // once found, remove
            if order.id == unassignedOrder.id {
                OrderList.sharedInstance.orderArray.removeAtIndex(index)
            }
        }
        
        SocketHandler.sharedSocket.promptLocalNotification("unassigned")
        self.taskHasBeenAssignedOrUnassigned("A task has been unassigned!")
        self.updateUI()
    }
    
//MARK: OrderDetailViewControllerDelegate
    func didAcceptOrder(orderId: String) {
        // search for order then reset status
        for (index, order) in OrderList.sharedInstance.orderArray.enumerate() {
            if order.id == orderId {
                OrderList.sharedInstance.orderArray[index].status = .Accepted
            }
        }
        self.updateUI()
    }
    
    func didCompleteOrder(orderId: String) {
        self.removeOrder(orderId)
        self.updateUI()
    }
    
    func didRejectOrder(orderId: String) {
        self.removeOrder(orderId)
        self.updateUI()
    }

//MARK: Remove Order
    func removeOrder(orderId: String) {
        // remove a specific order
        for (index, order) in OrderList.sharedInstance.orderArray.enumerate() {
            if order.id == orderId {
                OrderList.sharedInstance.orderArray.removeAtIndex(index)
            }
        }
    }
    
//MARK: Status Bar Notification
    func taskHasBeenAssignedOrUnassigned(task: String) {
        self.notification.notificationStyle = .NavigationBarNotification
        self.notification.notificationAnimationInStyle = .Left
        self.notification.notificationAnimationOutStyle = .Right
        self.notification.notificationLabelFont = UIFont(name: "OpenSans-Bold", size: 17)!
        self.notification.notificationLabelTextColor = UIColor.whiteColor()
        self.notification.notificationLabelBackgroundColor = UIColor(red: 0.4902, green: 0.3137, blue: 0.651, alpha: 1.0) /* #7d50a6 */
        self.notification.displayNotificationWithMessage(task, forDuration: 2.0)
    }
    
//MARK: Update UI
    func showOrHideNoTasksLabel() {
        if OrderList.sharedInstance.orderArray.count == 0 {
            self.noTasksLabel.hidden = false
        }
        else {
            self.noTasksLabel.hidden = true
        }
    }
    
    func updateUI() {
        self.showOrHideNoTasksLabel()
        self.orderListTableView?.reloadData()
    }
    
//MARK: Go To Accepted Task
    
    @objc func didTapOnGoToAcceptedTask(orderInSession: Order) {
        // go to task in session...
        let orderDetailViewController = OrderDetailViewController()
        orderDetailViewController.delegate = self
        orderDetailViewController.order = orderInSession
        
        self.navigationController?.pushViewController(orderDetailViewController, animated: true)
    }
}
