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
import Mixpanel

class OrderListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, SocketHandlerDelegate, OrderDetailViewControllerDelegate {
    
    let notification = CWStatusBarNotification()
    var orderListTableView: UITableView!
    var noTasksLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//MARK: Check/Enforce Map Preference
        checkMapSettings()
        
        UIApplication.sharedApplication().idleTimerDisabled = false // ok to lock screen

//MARK: Navigation Bar
        view.backgroundColor = UIColor(red: 0.0392, green: 0.1373, blue: 0.1765, alpha: 1.0) /* #0a232d */
        title = "Tasks"
        navigationController?.navigationBar.barTintColor = UIColor(red: 0.0392, green: 0.1373, blue: 0.1765, alpha: 1.0) /* #0a232d */
        navigationController?.navigationBar.titleTextAttributes = [NSFontAttributeName: UIFont(name: "OpenSans-Bold", size: 17)!]
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        
//MARK: Settings
        let mapSettingsButton = UIButton(frame: CGRect(x: 0, y: 0, width: 22, height: 22))
        mapSettingsButton.setImage(UIImage(named: "map-100"), forState: UIControlState.Normal)
        mapSettingsButton.addTarget(navigationController?.topViewController, action: Selector("manuallyPromptMapSettings"), forControlEvents:  UIControlEvents.TouchUpInside)
        
        let settingsItem = UIBarButtonItem(customView: mapSettingsButton)
        navigationItem.leftBarButtonItem = settingsItem
        
//MARK: Log out
        let logoutButton = UIButton(frame: CGRect(x: 0, y: 0, width: 22, height: 22))
        logoutButton.setImage(UIImage(named: "exit-100"), forState: UIControlState.Normal)
        logoutButton.addTarget(navigationController?.topViewController, action: Selector("onLogout"), forControlEvents:  UIControlEvents.TouchUpInside)
        
        let logoutItem = UIBarButtonItem(customView: logoutButton)
        navigationItem.rightBarButtonItem = logoutItem
        
//MARK: Table View
        orderListTableView = UITableView(frame: CGRectMake(0, 0, view.bounds.size.width, view.bounds.size.height))
        orderListTableView.delegate = self
        orderListTableView.dataSource = self
        let backgroundView = UIView(frame: CGRectZero) // remove empty cells
        orderListTableView.tableFooterView = backgroundView // remove empty cells
        orderListTableView.backgroundColor = UIColor.clearColor()
        orderListTableView.separatorColor = UIColor(red: 0.1765, green: 0.2431, blue: 0.2706, alpha: 1.0) // #2d3e45
        view.addSubview(orderListTableView)
        
//MARK: No Tasks Label
        noTasksLabel = UILabel(frame: CGRectMake(view.frame.width/2 - 50, view.frame.height/2 - 10, 100, 20))
        noTasksLabel.text = "No Tasks"
        noTasksLabel.textAlignment = .Center
        noTasksLabel.font = UIFont(name: "OpenSans-SemiBold", size: 17)
        noTasksLabel.textColor = UIColor(red: 0.1765, green: 0.2431, blue: 0.2706, alpha: 1.0) // #2d3e45
        view.addSubview(noTasksLabel)
        
//MARK: Pull Orders
        OrderList.sharedInstance.pullOrders { (result) -> Void in
            print("result: \(result)")
            self.dismissHUD()
            self.updateUI()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(animated: Bool) {
        // Add Observer
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "checkMapSettings", name: "didEnterForeground", object: nil)
        
        NSUserDefaults.standardUserDefaults().setBool(true, forKey: "isLoggedIn") // TODO: consider adding to User class
        NSUserDefaults.standardUserDefaults().setObject("list", forKey: "currentScreen")
        SocketHandler.sharedSocket.delegate = self
        updateUI()
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

//MARK: Log Out
    func onLogout() {
        promptLogoutConfirmationAlert()
    }
    
    func promptLogoutConfirmationAlert() {
        let alertController = UIAlertController(title: "", message: "Save login info?", preferredStyle: .Alert)
        
        alertController.addAction(UIAlertAction(title: "Yes", style: .Default, handler: { action in
            SocketHandler.sharedSocket.closeSocket(true)
            Mixpanel.sharedInstance().reset()
        }))
        
        alertController.addAction(UIAlertAction(title: "No", style: .Default, handler: { action in
            SocketHandler.sharedSocket.closeSocket(true)
            Mixpanel.sharedInstance().reset()
            
            NSUserDefaults.standardUserDefaults().setObject("", forKey: "username")
            NSUserDefaults.standardUserDefaults().setObject("", forKey: "password")
        }))
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .Destructive, handler: nil))
        
        presentViewController(alertController, animated: true, completion: nil)
    }
    
//MARK: Map Settings //TODO: Figure out how to put all of map settings in MapSettings.Swift
    func promptMapSettings(isManualPrompt: Bool) {
        let alertController = UIAlertController(title: "Map Setting", message: "Current Setting: \(MapSetting.sharedMapSetting.getCurrentMapSetting())", preferredStyle: .Alert)
        
        alertController.addAction(UIAlertAction(title: "Waze", style: .Default, handler: { action in
            if isManualPrompt && MapSetting.sharedMapSetting.isWazeInstalled() {
                self.showHUD()
            }
            
            if MapSetting.sharedMapSetting.isWazeInstalled() {
                MapSetting.sharedMapSetting.setWaze()
                self.statusBarNotification("Waze saved!")
                NSTimer.scheduledTimerWithTimeInterval(2, target: self, selector: "dismissHUD", userInfo: nil, repeats: false)
            }
            else {
                MapSetting.sharedMapSetting.gotoAppStoreWaze()
            }
        }))
        
        alertController.addAction(UIAlertAction(title: "Google Maps", style: .Default, handler: { action in
            if isManualPrompt && MapSetting.sharedMapSetting.isGoogleMapsInstalled() {
                self.showHUD()
            }
            
            if MapSetting.sharedMapSetting.isGoogleMapsInstalled() {
                MapSetting.sharedMapSetting.setGoogleMaps()
                self.statusBarNotification("Google Maps saved!")
                NSTimer.scheduledTimerWithTimeInterval(2, target: self, selector: "dismissHUD", userInfo: nil, repeats: false)
            }
            else {
                MapSetting.sharedMapSetting.gotoAppStoreGoogleMaps()
            }
        }))
        
        if isManualPrompt {
            alertController.addAction(UIAlertAction(title: "Cancel", style: .Destructive, handler: nil))
        }
        
        presentViewController(alertController, animated: true, completion: nil)
    }
    
    func checkMapSettings() {
        
        let currentMapSetting = NSUserDefaults.standardUserDefaults().objectForKey("map") as? String
        
        if MapSetting.sharedMapSetting.isWazeInstalled() && currentMapSetting == "Waze" {
            MapSetting.sharedMapSetting.setWaze()
            return
        }
        else if MapSetting.sharedMapSetting.isGoogleMapsInstalled() && currentMapSetting == "Google Maps"{
            MapSetting.sharedMapSetting.setGoogleMaps()
            return
        }
        else {
            if MapSetting.sharedMapSetting.isWazeInstalled() {
                MapSetting.sharedMapSetting.setWaze()
                return
            }
            else if MapSetting.sharedMapSetting.isGoogleMapsInstalled() {
                MapSetting.sharedMapSetting.setGoogleMaps()
                return
            }
            else {
                MapSetting.sharedMapSetting.setToNone()
                promptMapSettings(false)
            }
        }
    }
    
    func manuallyPromptMapSettings() {
        promptMapSettings(true)
    }
    
//MARK: Table View Datasource
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        // edit: just return the first index so drivers won't feel too anxious with a list of orders
        if OrderList.sharedInstance.orderArray.count == 0 {
            return 0
        }
        else {
            return 1;
        }
        
//        return OrderList.sharedInstance.orderArray.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cellId = "Cell"
        
        var cell = tableView.dequeueReusableCellWithIdentifier(cellId) as? OrderListCell
        
        if cell == nil {
            cell = OrderListCell(style: UITableViewCellStyle.Default, reuseIdentifier: cellId)
        }
        
        if OrderList.sharedInstance.orderArray.count != 0 {
        
            let order = OrderList.sharedInstance.orderArray[indexPath.row]
            
            cell?.addressLabel.text = "\(order.street)\n\(order.city)"
            cell?.nameLabel.text = order.name
            
            switch order.status{
            case .Accepted:
                cell?.circleImageView.image = UIImage(named: "blue-moon-64")
            case .Rejected:
                cell?.circleImageView.image = UIImage(named: "red-moon-64")
            default:
                cell?.circleImageView.image = UIImage(named: "yellow-moon-64")
            }
            
            // fade in cell
            cell?.alpha = 0
            UIView.animateWithDuration(0.5, animations: { cell?.alpha = 1 })
            
            print(cell?.frame.width) // cell is stuck at 320pt...wtf?
        }
        
        return cell!
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        // go to detail screen
        let orderDetailViewController = OrderDetailViewController()
        orderDetailViewController.delegate = self
        orderDetailViewController.order = OrderList.sharedInstance.orderArray[indexPath.row]

        navigationController?.pushViewController(orderDetailViewController, animated: true)
    }
    
//MARK: SocketHandlerDelegate
    func socketHandlerDidConnect() {
        
    }
    
    func socketHandlerDidFailToConnect() {
        
    }
    
    func socketHandlerDidAuthenticate() {
        // remove any preexisting orders
        if OrderList.sharedInstance.orderArray.count != 0 {
            OrderList.sharedInstance.orderArray.removeAll()
        }
        
        // pull orders from houston
        OrderList.sharedInstance.pullOrders { (result) -> Void in
            
            print("result: \(result)")
            self.dismissHUD()
            self.updateUI()
        }
    }
    
    func socketHandlerDidFailToAuthenticate() {
        
    }
    
    func socketHandlerDidDisconnect() {
        navigationController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func socketHandlerDidAssignOrder(assignedOrder: Order) {
        
        // add order to list...
//        OrderList.sharedInstance.orderArray.append(assignedOrder)
        
        // no preexisting orders
        if OrderList.sharedInstance.orderArray.count <= 1 { // 1 is current just added, so no prexisting
            
            // first in list
            if assignedOrder.id == OrderList.sharedInstance.orderArray[0].id {
                SocketHandler.sharedSocket.promptLocalNotification("assigned")
                SoundEffect.sharedPlayer.playSound("new_task")
                statusBarNotification("Task assigned!")
                updateUI()
            }
        }
        // order(s) preexist
        else {
            if assignedOrder.id == OrderList.sharedInstance.orderArray[0].id {
                SocketHandler.sharedSocket.promptLocalNotification("switched")
                SoundEffect.sharedPlayer.playSound("task_switched")
                statusBarNotification("Task switched!")
                updateUI()
            }
        }
    }
    
    func socketHandlerDidUnassignOrder(unassignedOrder: Order, isCurrentTask: Bool) {
        
        if isCurrentTask == true {
            
            if OrderList.sharedInstance.orderArray.count != 0 {
                SocketHandler.sharedSocket.promptLocalNotification("switched")
                SoundEffect.sharedPlayer.playSound("task_switched")
                statusBarNotification("Task switched!")
                updateUI()
            }
            else {
                SocketHandler.sharedSocket.promptLocalNotification("unassigned")
                SoundEffect.sharedPlayer.playSound("task_removed")
                statusBarNotification("Task removed!")
                updateUI()
            }
        }
        else {
            if unassignedOrder.id == OrderList.sharedInstance.orderArray[0].id {
                SocketHandler.sharedSocket.promptLocalNotification("switched")
                SoundEffect.sharedPlayer.playSound("task_switched")
                statusBarNotification("Task switched!")
                updateUI()
            }
        }
    }
    
    func socketHandlerDidReprioritizeOrder(reprioritized: Order, isCurrentTask: Bool) {
        
        // reprioritized order became first on list
        if reprioritized.id == OrderList.sharedInstance.orderArray[0].id ||
            // the first on list was reprioritized down
            (reprioritized.id != OrderList.sharedInstance.orderArray[0].id && isCurrentTask == true) {
                
            SocketHandler.sharedSocket.promptLocalNotification("switched")
            SoundEffect.sharedPlayer.playSound("task_switched")
                statusBarNotification("Task switched!")
                updateUI()
        }
        
//        SocketHandler.sharedSocket.promptLocalNotification("reprioritized")
//        taskHasBeenAssignedOrUnassigned("A task has been reprioritized!")
//        updateUI()
    }
    
    func socketHandlerDidModifyOrder(modifiedOrder: Order, isCurrentTask: Bool) {
        if isCurrentTask == true {
            SocketHandler.sharedSocket.promptLocalNotification("modified")
            SoundEffect.sharedPlayer.playSound("task_modified")
            statusBarNotification("Task modified!")
            updateUI()
        }
    }
    
//MARK: OrderDetailViewControllerDelegate
    func didRejectOrder(orderId: String) {
        changeOrderStatus(orderId, status: .Rejected)
        updateUI()
    }
    
    func didAcceptOrder(orderId: String) {
        changeOrderStatus(orderId, status: .Accepted)
        updateUI()
    }
    
    func didCompleteOrder(orderId: String) {
        removeOrder(orderId)
        updateUI()
    }
    
    func didModifyOrder(orderInSession: Order) {
        didTapOnGoToAcceptedTask(orderInSession)
    }
    
//MARK:
    func changeOrderStatus(id: String, status: OrderStatus) {
        // search for order then reset status
        for (index, order) in OrderList.sharedInstance.orderArray.enumerate() {
            if order.id == id {
                OrderList.sharedInstance.orderArray[index].status = status
            }
        }
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
    func statusBarNotification(task: String) {
        notification.notificationStyle = .NavigationBarNotification
        notification.notificationAnimationInStyle = .Left
        notification.notificationAnimationOutStyle = .Right
        notification.notificationLabelFont = UIFont(name: "OpenSans-Bold", size: 17)!
        notification.notificationLabelTextColor = UIColor.whiteColor()
        notification.notificationLabelBackgroundColor = UIColor(red: 0.4902, green: 0.3137, blue: 0.651, alpha: 1.0) /* #7d50a6 */
        notification.displayNotificationWithMessage(task, forDuration: 2.0)
    }
    
//MARK: Update UI
    func showOrHideNoTasksLabel() {
        if OrderList.sharedInstance.orderArray.count == 0 {
            noTasksLabel.hidden = false
        }
        else {
            noTasksLabel.hidden = true
        }
    }
    
    func updateUI() {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.showOrHideNoTasksLabel()
    //        sortList()
            self.orderListTableView.reloadData()
        })
    }
    
//    func sortList() {
//        var acceptedList: [Order] = []
//        var pendingList: [Order] = []
//        var rejectedList: [Order] = []
//        
//        // loop through order list
//        for var i = 0; i < OrderList.sharedInstance.orderArray.count; i++ {
//            
//            let status = OrderList.sharedInstance.orderArray[i].status
//            let order = OrderList.sharedInstance.orderArray[i]
//            
//            switch status {
//            case .Accepted:
//                acceptedList.append(order)
//            case .Pending:
//                pendingList.append(order)
//            case .Rejected:
//                rejectedList.append(order)
//            default: ()
//            }
//        }
//        
//        OrderList.sharedInstance.orderArray = acceptedList + pendingList + rejectedList
        
//        orderListTableView.reloadData()
//    }
    
//MARK: Go To Accepted Task
    @objc func didTapOnGoToAcceptedTask(orderInSession: Order) {
        // go to task in session...
        let orderDetailViewController = OrderDetailViewController()
        orderDetailViewController.delegate = self
        orderDetailViewController.order = orderInSession
        
        navigationController?.pushViewController(orderDetailViewController, animated: true)
    }
    
//MARK: HUD
    func showHUD() {
        PKHUD.sharedHUD.contentView = PKHUDProgressView()
        PKHUD.sharedHUD.dimsBackground = true
        PKHUD.sharedHUD.userInteractionOnUnderlyingViewsEnabled = false
        PKHUD.sharedHUD.show()
    }
    
    func dismissHUD() {
        PKHUD.sharedHUD.contentView = PKHUDSuccessView()
        PKHUD.sharedHUD.hide(afterDelay: 0)
    }
    
//MARK: Status Bar
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
}

