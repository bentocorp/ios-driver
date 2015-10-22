//
//  OrderDetailViewController.swift
//  BentoDriver
//
//  Created by Joseph Lau on 10/9/15.
//  Copyright © 2015 Joseph Lau. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import Alamofire_SwiftyJSON
import PKHUD

@objc protocol OrderDetailViewControllerDelegate {
    func didRejectOrder(orderId: String)
    func didAcceptOrder(orderId: String)
    func didCompleteOrder(orderId: String)
    optional func didTapOnGoToAcceptedTask(orderInSession: Order)
}

class OrderDetailViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, SocketHandlerDelegate {

//MARK: Properties
    var order: Order!
    
    var api: String!
    var parameters : [String : AnyObject]!
    
    var rejectButton: UIButton!
    var acceptButton: UIButton!
    var arrivedAndCompleteButton: UIButton!
    
    var bentoTableView: UITableView!
    
    var delegate: OrderDetailViewControllerDelegate?
    
    var messageComposer: MessageComposer!
    
    let notification = CWStatusBarNotification()

    var indexOfOrderThatHasAlreadyBeenAccepted: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = self.order.name
        self.view.backgroundColor = UIColor(red: 0.0392, green: 0.1373, blue: 0.1765, alpha: 1.0) /* #0a232d */

//MARK: API & Parameters
        self.api = "http://52.11.208.197:8081/api"
        self.parameters = ["token": User.currentUser.token!, "orderId": self.order.id]
        
//MARK: Socket Handler
        let socket = SocketHandler.sharedSocket
        socket.delegate = self;
        
//MARK: Customer Info
        // View
        let infoView = UIView(frame: CGRectMake(0, 64, self.view.frame.width, 80))
        self.view.addSubview(infoView)
        
        // text
        let textButton = UIButton(frame: CGRectMake(self.view.frame.width/4 - 40, 20, 40, 40))
        textButton.setImage(UIImage(named: "green-bubble-64"), forState: .Normal)
        textButton.addTarget(self, action: "onText", forControlEvents: .TouchUpInside)
        infoView.addSubview(textButton)
        
        // phone
        let phoneButton = UIButton(frame: CGRectMake(self.view.frame.width/2 - 20, 20, 40, 40))
        phoneButton.setImage(UIImage(named: "green-phone-64"), forState: .Normal)
        phoneButton.addTarget(self, action: "onPhone", forControlEvents: .TouchUpInside)
        infoView.addSubview(phoneButton)
        
        // location
        let locationButton = UIButton(frame: CGRectMake(self.view.frame.width/1.25 - 10, 20, 40, 40))
        locationButton.setImage(UIImage(named: "green-map-64"), forState: .Normal)
        locationButton.addTarget(self, action: "onLocation", forControlEvents: .TouchUpInside)
        infoView.addSubview(locationButton)
        
        // status
        
        // separator
        let lineSeparator = UIView(frame: CGRectMake(0, 64 + infoView.frame.height, self.view.frame.width, 2))
        lineSeparator.backgroundColor = UIColor(red: 0.1765, green: 0.2431, blue: 0.2706, alpha: 1.0) /* #2d3e45 the lighter version without trans*/
        self.view.addSubview(lineSeparator)
        
//MARK: TableView
        self.bentoTableView = UITableView(frame: CGRectMake(0, 64 + infoView.frame.height, self.view.frame.width, (self.view.frame.height - 80) - (64 + infoView.frame.height - 10)))
        self.bentoTableView.delegate = self
        self.bentoTableView.dataSource = self
        let backgroundView = UIView(frame: CGRectZero)
        backgroundView.backgroundColor = UIColor(red: 0.0392, green: 0.1373, blue: 0.1765, alpha: 1.0) /* #0a232d */
        self.bentoTableView.tableFooterView = backgroundView
        self.bentoTableView.backgroundColor = UIColor.clearColor()
        if self.order.itemArray.count != 0 {
            self.view.addSubview(self.bentoTableView)
        }
        
//MARK: Task
        let itemStringTextView = UITextView(frame: CGRectMake(20, 64 + infoView.frame.height + lineSeparator.frame.height + 20, self.view.frame.width - 40, self.view.frame.height - (64 + infoView.frame.height + 20 + backgroundView.frame.height + 90)))
        itemStringTextView.textColor = UIColor.whiteColor()
        itemStringTextView.backgroundColor = UIColor.clearColor()
        itemStringTextView.font = UIFont(name: "OpenSans-SemiBold", size: 17)
        itemStringTextView.userInteractionEnabled = false
        if self.order.itemString != nil {
            itemStringTextView.text = order.itemString
            self.view.addSubview(itemStringTextView)
        }
        
//MARK: Actions
        // View
        let userActionView = UIView(frame: CGRectMake(0, self.view.frame.height - 70, self.view.frame.width, 70))
        userActionView.backgroundColor = UIColor(red: 0.1765, green: 0.2431, blue: 0.2706, alpha: 1.0) /* #2d3e45 the lighter version without trans*/
        self.view.addSubview(userActionView)
        
        // Reject
        self.rejectButton = UIButton(frame: CGRectMake(5, 10, self.view.frame.width / 2 - 10, 50))
        self.rejectButton.backgroundColor = UIColor(red: 0.8039, green: 0.2863, blue: 0.2235, alpha: 1.0) /* #cd4939 */
        self.rejectButton.layer.cornerRadius = 3
        self.rejectButton.setTitle("REJECT", forState: .Normal)
        self.rejectButton.titleLabel?.font = UIFont(name: "OpenSans-Bold", size: 21)
        self.rejectButton.titleLabel?.textColor = UIColor.whiteColor()
        self.rejectButton.addTarget(self, action: "onOrderAction:", forControlEvents: .TouchUpInside)
        userActionView.addSubview(self.rejectButton)
        
        // Accept
        self.acceptButton = UIButton(frame: CGRectMake(self.view.frame.width / 2 + 5, 10, self.view.frame.width / 2 - 10, 50))
        self.acceptButton.backgroundColor = UIColor(red: 0.2275, green: 0.5255, blue: 0.8118, alpha: 1.0) /* #3a86cf */
        self.acceptButton.layer.cornerRadius = 3
        self.acceptButton.setTitle("ACCEPT", forState: .Normal)
        self.acceptButton.titleLabel?.font = UIFont(name: "OpenSans-Bold", size: 21)
        self.acceptButton.titleLabel?.textColor = UIColor.whiteColor()
        self.acceptButton.addTarget(self, action: "onOrderAction:", forControlEvents: .TouchUpInside)
        userActionView.addSubview(self.acceptButton)
        
        // Arrived/Complete
        self.arrivedAndCompleteButton = UIButton(frame: CGRectMake(5, 10, self.view.frame.width-10, 50))
        self.arrivedAndCompleteButton.layer.cornerRadius = 3
        self.arrivedAndCompleteButton.titleLabel?.font = UIFont(name: "OpenSans-Bold", size: 21)
        self.arrivedAndCompleteButton.titleLabel?.textColor = UIColor.whiteColor()
        self.arrivedAndCompleteButton.addTarget(self, action: "onOrderAction:", forControlEvents: .TouchUpInside)
        userActionView.addSubview(self.arrivedAndCompleteButton)
        
        // acceppted
        if self.order.status == .Accepted {
            // flag to check if arrived has been tapped on, reset to nil once order is complete
            if NSUserDefaults.standardUserDefaults().boolForKey("arrivedWasTapped") == false {
                self.arrivedAndCompleteButton.backgroundColor = UIColor(red: 0.8196, green: 0.4392, blue: 0.1686, alpha: 1.0) /* #d1702b */
                self.arrivedAndCompleteButton.setTitle("ARRIVED", forState: .Normal)
            }
            else {
                self.arrivedAndCompleteButton.backgroundColor = UIColor(red: 0.2784, green: 0.6588, blue: 0.5333, alpha: 1.0) /* #47a888 */
                self.arrivedAndCompleteButton.setTitle("COMPLETE", forState: .Normal)
            }
        }
        
        // check if order is accepted and show/hide buttons accordingly
        self.showHideButtons()
        
//MARK: Message Composer
        self.messageComposer = MessageComposer(phoneString: self.order.phone)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
//MARK: Show/Hide Buttons
    func showHideButtons() {
        // order has already been accepted
        if order.status == .Accepted {
            self.rejectButton.hidden = true
            self.acceptButton.hidden = true
            self.arrivedAndCompleteButton.hidden = false
        }
        else {
            self.rejectButton.hidden = false
            self.acceptButton.hidden = false
            self.arrivedAndCompleteButton.hidden = true
        }
    }
    
//MARK: TableView
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.order.itemArray.count // box count
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        // Header view
        let headerView = UIView()
        headerView.backgroundColor = UIColor(red: 0.1765, green: 0.2431, blue: 0.2706, alpha: 1.0) /* #2d3e45 the lighter version without trans*/
        
        // Title label
        let headerTitleLabel = UILabel(frame: CGRectMake(10, 5, self.view.frame.width - 20, 30))
        headerTitleLabel.text = "Box \(section + 1)"
        headerTitleLabel.textColor = UIColor.whiteColor()
        headerTitleLabel.font = UIFont(name: "OpenSans-SemiBold", size: 21)
        headerView.addSubview(headerTitleLabel)
        
        return headerView
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 40
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.order.itemArray[0].items.count // dish count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellId = "Cell"
        
        var cell = tableView.dequeueReusableCellWithIdentifier(cellId)
        
        if cell == nil {
            cell = UITableViewCell(style: .Default, reuseIdentifier: cellId)
        }
        
        let itemNameString = (order.itemArray[indexPath.section].items[indexPath.row].name)!
        let itemLabelString = (order.itemArray[indexPath.section].items[indexPath.row].label)!
        
        cell?.selectionStyle = .None
        cell?.textLabel?.textColor = UIColor.whiteColor()
        cell?.textLabel?.text = "  \(itemLabelString) - \(itemNameString)"
        cell?.textLabel?.font = UIFont(name: "OpenSans-Regular", size: 14)
        cell?.backgroundColor = UIColor(red: 0.0392, green: 0.1373, blue: 0.1765, alpha: 1.0) /* #0a232d */
        
        return cell!
    }
    
//MARK: On Location, Phone, and Text
    func onLocation() {
        let alertController = UIAlertController(title: "Address", message: "\(self.order.street)\n\(self.order.city), \(self.order.region)", preferredStyle: .Alert)
        
        alertController.addAction(UIAlertAction(title: "Let's go!", style: .Default, handler: { action in
            
            // street
            let streetArray = self.order.street.componentsSeparatedByString(" ")
            var newStreetArray: [String] = []
            for var i = 0; i < streetArray.count; i++ {
                newStreetArray.append("\(streetArray[i])%20")
            }
            let newStreetString = newStreetArray.joinWithSeparator("")
            
            // city
            let cityArray = self.order.city.componentsSeparatedByString(" ")
            var newCityArray: [String] = []
            for var k = 0; k < cityArray.count; k++ {
                if cityArray[k] != cityArray[cityArray.count-1] {
                    newCityArray.append("\(cityArray[k])%20")
                }
                else {
                    newCityArray.append("\(cityArray[k])") // don't add %20 at the end
                }
            }
            let newCityString = newCityArray.joinWithSeparator("")
            
            // open waze with URL scheme
            let addressForWazeSchemeString = "\(newStreetString)\(newCityString)"
            let url  = NSURL(string: "waze://?q=\(addressForWazeSchemeString)");
            if UIApplication.sharedApplication().canOpenURL(url!) == true {
                UIApplication.sharedApplication().openURL(url!)
            }
        }))
        
        alertController.addAction(UIAlertAction(title: "Copy to clipboard", style: .Default, handler: { action in
            let pasteboard = UIPasteboard.generalPasteboard()
            pasteboard.string = "\(self.order.street) \(self.order.city), \(self.order.region)"
        }))
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .Destructive, handler: nil))
        
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    func onPhone() {
        let alertController = UIAlertController(title: "Phone Number", message: "\(self.order.phone)", preferredStyle: .Alert)
        
        // get only digits from phone string
        let phoneArray = self.order.phone.componentsSeparatedByCharactersInSet(NSCharacterSet.decimalDigitCharacterSet().invertedSet)
        let phoneDigitsOnlyString = phoneArray.joinWithSeparator("")
        
        alertController.addAction(UIAlertAction(title: "Call", style: .Default, handler: { action in
            let url  = NSURL(string: "tel://\(phoneDigitsOnlyString)")
            if UIApplication.sharedApplication().canOpenURL(url!) == true {
                UIApplication.sharedApplication().openURL(url!)
            }
        }))
        
        alertController.addAction(UIAlertAction(title: "Copy to clipboard", style: .Default, handler: { action in
            let pasteboard = UIPasteboard.generalPasteboard()
            pasteboard.string = "\(phoneDigitsOnlyString)"
        }))
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .Destructive, handler: nil))
        
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    func onText() {
        if (self.messageComposer.canSendText()) {
            let messageComposerVC = self.messageComposer.configuredMessageComposeViewController()
            
            // dismissal handled by the messageComposer instance -> contains the delegate call-back
            presentViewController(messageComposerVC, animated: true, completion: nil)
        }
        else {
            // handle error...
            let alertController = UIAlertController(title: "", message: "Your device is unable to send text messages.", preferredStyle: .Alert)
            
            alertController.addAction(UIAlertAction(title: "OK", style: .Cancel, handler: nil))
            
            self.presentViewController(alertController, animated: true, completion: nil)
        }
    }


//MARK: On Order Action -> Confirm Order Action
    func onOrderAction(sender: UIButton) {
        
        // get button title and make it lowercase
        if let action = sender.titleLabel?.text {
            let actionLowercaseString = action.lowercaseString
            
            // tapped on accepted
            if actionLowercaseString == "accept" {
                // there's already an accepted order
                if self.isThereAlreadyAnAcceptedOrder() == true {
                    
                    self.showHoldYourHorsesAlert()
                    
                    return
                }
            }
            
            // no order has already been accepted, continue down...
            
            // tapped on arrive
            if actionLowercaseString == "arrived" {
                self.arrivedOrder()
            }
            // tapped on either reject, accept, or complete
            else {
                self.showActionConfirmationAlert(actionLowercaseString)
            }
        }
    }
    
    func isThereAlreadyAnAcceptedOrder() -> Bool {
        // check if there are any other accepted order already
        for var i = 0; i < OrderList.sharedInstance.orderArray.count; i++ {
            
            // already has an accepted order...
            if OrderList.sharedInstance.orderArray[i].status == .Accepted {
                
                self.indexOfOrderThatHasAlreadyBeenAccepted = i
                
                return true
            }
        }
        
        return false
    }
    
    func showHoldYourHorsesAlert() {
        // prevent accepting
        let alertController = UIAlertController(title: "Hold your horses!", message: "You already have a task in session. Please finish that first, then try again later.", preferredStyle: .Alert)
        
        // action 1
        alertController.addAction(UIAlertAction(title: "Go to task", style: .Default, handler: { action in
            
            self.navigationController?.popViewControllerAnimated(true)
            
            self.delegate?.didTapOnGoToAcceptedTask!(OrderList.sharedInstance.orderArray[self.indexOfOrderThatHasAlreadyBeenAccepted!])
        }))
        
        // action 2
        alertController.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
        
        // show alert
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    func showActionConfirmationAlert(actionString: String) {
        let alertController = UIAlertController(title: "\(actionString.firstCharacterUpperCase()) Task?", message: "Are you sure you want to \(actionString) task?", preferredStyle: .Alert)
        
        alertController.addAction(UIAlertAction(title: actionString.firstCharacterUpperCase(), style: .Default, handler: { action in
            
            switch actionString {
            case "reject":
                self.rejectOrder()
            case "accept":
                self.acceptOrder()
            default:
                self.completeOrder()
            }
        }))
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
        
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
//MARK: Commit Action
    func rejectOrder() {
        self.callHouston(self.api + "/order/reject" , parameters: self.parameters, task: "reject")
    }
    
    func acceptOrder() {
        self.callHouston(self.api + "/order/accept" , parameters: self.parameters, task: "accept")
    }
    
    func arrivedOrder() {
        self.callHouston(self.api + "/sms/bento-here", parameters: self.parameters, task: "arrived")
    }
    
    func completeOrder() {
        self.callHouston(self.api + "/order/complete" , parameters: self.parameters, task: "complete")
    }
    
//MARK: Commit By Calling Houston
    func callHouston(apiString: String, parameters: [String: AnyObject], task: String) {
        
        self.showHUD()
        
        Alamofire.request(.GET, apiString, parameters: parameters)
            .responseSwiftyJSON({ (request, response, json, error) in
            
            let code = json["code"]
            print("code: \(code)")
                
            let msg = json["msg"]
            print("msg = \(msg)")
                
            let ret = json["ret"].stringValue.lowercaseString // normalize ret to lowercase
            print("ret: \(ret)")
            
            // Handler error...
            if code != 0 {
                let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(2.0 * Double(NSEC_PER_SEC)))
                dispatch_after(delayTime, dispatch_get_main_queue()) {
                    self.dismissHUDWithSuccess(false)
                    // show complete button once HUD has been dismissed after 2 seconds...
                    NSTimer.scheduledTimerWithTimeInterval(2, target: self, selector: "showCompleteButton", userInfo: nil, repeats: true)
                }
                
                return
            }
            
            // No Error~
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                switch task {
                case "reject":
                    if ret == "ok" {
                        self.delegate?.didRejectOrder(self.order.id)
                        self.navigationController?.popViewControllerAnimated(true)
                    }
                case "accept":
                    if ret == "ok" {
                        // change the Order status in ordersArray in parent VC
                        self.delegate?.didAcceptOrder(self.order.id)
                        
                        // change buttons
                        self.rejectButton.hidden = true
                        self.acceptButton.hidden = true
                        self.arrivedAndCompleteButton.hidden = false
                        self.updateArrivedOrCompleteButtonState("arrived")
                        
                        self.setArrivedWasTapped(false)
                    }
                case "arrived":
                    if ret == "ok" {
                        // change arrived button to complete button
                        self.arrivedAndCompleteButton.backgroundColor = UIColor(red: 0.2784, green: 0.6588, blue: 0.5333, alpha: 1.0) /* #47a888 */
                        self.arrivedAndCompleteButton.setTitle("COMPLETE", forState: .Normal)
                        
                        self.setArrivedWasTapped(true)
                    }
                default: // complete
                    if ret == "ok" {
                        // change the Order status in ordersArray in parent VC
                        self.delegate?.didCompleteOrder(self.order.id)
                        
                        self.setArrivedWasTapped(false)

                        self.navigationController?.popViewControllerAnimated(true)
                    }
                }
                
                self.dismissHUDWithSuccess(true)
            })
        })
    }
    
    func showCompleteButton() {
        self.updateArrivedOrCompleteButtonState("complete")
        self.setArrivedWasTapped(true)
    }
    
    func setArrivedWasTapped(bool: Bool) {
        // flag to check if arrived has been tapped on, reset to false once order is complete
         NSUserDefaults.standardUserDefaults().setBool(bool, forKey: "arrivedWasTapped")
    }
    
    func updateArrivedOrCompleteButtonState(arrivedOrComplete: String) {
        if arrivedOrComplete == "arrived" {
            self.arrivedAndCompleteButton.backgroundColor = UIColor(red: 0.8196, green: 0.4392, blue: 0.1686, alpha: 1.0) /* #d1702b */
            self.arrivedAndCompleteButton.setTitle("ARRIVED", forState: .Normal)
        }
        else  if arrivedOrComplete == "complete" {
            self.arrivedAndCompleteButton.backgroundColor = UIColor(red: 0.2784, green: 0.6588, blue: 0.5333, alpha: 1.0) /* #47a888 */
            self.arrivedAndCompleteButton.setTitle("COMPLETE", forState: .Normal)
        }
    }
    
//MARK: SocketHandlerDelegate
    func socketHandlerDidAssignOrder(assignedOrder: Order) {
        // add order to list
        OrderList.sharedInstance.orderArray.append(assignedOrder)
        
        SocketHandler.sharedSocket.promptLocalNotification("assigned")
        self.taskHasBeenAssignedOrUnassigned("A new task has been assigned!")
    }
    
    func socketHandlerDidUnassignOrder(unassignedOrder: Order) {
        // remove order from OrderList
        for (index, order) in OrderList.sharedInstance.orderArray.enumerate() {
            // once found, remove
            if order.id == unassignedOrder.id {
                OrderList.sharedInstance.orderArray.removeAtIndex(index)
            }
        }
        
        // if current order is unassigned
        if unassignedOrder.id == self.order.id {
            self.taskHasBeenAssignedOrUnassigned("This task has been unassigned!")
        }
        else {
            self.taskHasBeenAssignedOrUnassigned("A task has been unassigned!")
        }
        
        SocketHandler.sharedSocket.promptLocalNotification("unassigned")
    }
    
    func socketHandlerDidDisconnect() {
        // handle disconnect
    }

//MARK: Status Bar Notification
    func taskHasBeenAssignedOrUnassigned(task: String) {
        
        let alertController = UIAlertController(title: task, message: "", preferredStyle: .Alert)
        
        let doesTaskRequireAction: Bool
        
        if task == "This task has been unassigned!" {
            doesTaskRequireAction = true
        }
        else {
            doesTaskRequireAction = false
            
            // status bar notification
            self.notification.notificationStyle = .NavigationBarNotification
            self.notification.notificationAnimationInStyle = .Left
            self.notification.notificationAnimationOutStyle = .Right
            self.notification.notificationLabelFont = UIFont(name: "OpenSans-Bold", size: 17)!
            self.notification.notificationLabelTextColor = UIColor.whiteColor()
            self.notification.notificationLabelBackgroundColor = UIColor(red: 0.4902, green: 0.3137, blue: 0.651, alpha: 1.0) /* #7d50a6 */
            self.notification.displayNotificationWithMessage(task, forDuration: 2.0)
        }
        
        if doesTaskRequireAction == true {
            alertController.addAction(UIAlertAction(title: "Roger that!", style: .Cancel, handler: { action in
                
                self.navigationController?.popViewControllerAnimated(true)
            }))
            
            self.presentViewController(alertController, animated: true, completion: nil)
        }
    }
    
//MARK: HUD
    func showHUD() {
        PKHUD.sharedHUD.contentView = PKHUDProgressView()
        PKHUD.sharedHUD.dimsBackground = true
        PKHUD.sharedHUD.userInteractionOnUnderlyingViewsEnabled = false
        PKHUD.sharedHUD.show()
    }
    
    func dismissHUDWithSuccess(success: Bool) {
        if success == true {
            PKHUD.sharedHUD.contentView = PKHUDSuccessView()
            PKHUD.sharedHUD.hide(afterDelay: 0)
        }
        else {
            PKHUD.sharedHUD.contentView = PKHUDErrorView()
            PKHUD.sharedHUD.hide(afterDelay: 2)
        }
    }
}
