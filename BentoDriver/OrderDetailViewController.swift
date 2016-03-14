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
import Mixpanel

@objc protocol OrderDetailViewControllerDelegate {
    func didRejectOrder(orderId: String)
    func didAcceptOrder(orderId: String)
    func didCompleteOrder(orderId: String)
    optional func didTapOnGoToAcceptedTask(orderInSession: Order)
    optional func didModifyOrder(orderInSession: Order)
}

class OrderDetailViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, SocketHandlerDelegate {

//MARK: Properties
    var order: Order!
    
    var api: String!
    var parameters : [String : AnyObject]!
    
    var alamofireManager : Alamofire.Manager?
    
    var userActionView: UIView!
    var rejectButton: UIButton!
    var acceptButton: UIButton!
    var arrivedAndCompleteButton: UIButton!
    
    var bentoTableView: UITableView!

    var delegate: OrderDetailViewControllerDelegate?
    
    var messageComposer: MessageComposer!
    
    let notification = CWStatusBarNotification()

    var indexOfOrderThatHasAlreadyBeenAccepted: Int?
    
    var itemStringTextView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NSUserDefaults.standardUserDefaults().setObject("detail", forKey: "currentScreen")
        
        UIApplication.sharedApplication().idleTimerDisabled = true // prevent lock screen only when viewing orders
        
        title = self.order.name
        view.backgroundColor = UIColor(red: 0.0392, green: 0.1373, blue: 0.1765, alpha: 1.0) /* #0a232d */

//MARK: API & Parameters
        api = "\(SocketHandler.sharedSocket.getHoustonAPI())/api"
        parameters = ["token": User.currentUser.token!, "orderId": self.order.id]
        
//MARK: Socket Handler
        let socket = SocketHandler.sharedSocket
        socket.delegate = self;
        
//MARK: Customer Info
        // View
        let infoView = UIView(frame: CGRectMake(0, 64, view.frame.width, 80))
        view.addSubview(infoView)
        
        // text
        let textButton = UIButton(frame: CGRectMake(view.frame.width/4 - 40, 20, 40, 40))
        textButton.setImage(UIImage(named: "green-bubble-64"), forState: .Normal)
        textButton.addTarget(self, action: "onText", forControlEvents: .TouchUpInside)
        infoView.addSubview(textButton)
        
        // phone
        let phoneButton = UIButton(frame: CGRectMake(view.frame.width/2 - 20, 20, 40, 40))
        phoneButton.setImage(UIImage(named: "green-phone-64"), forState: .Normal)
        phoneButton.addTarget(self, action: "onPhone", forControlEvents: .TouchUpInside)
        infoView.addSubview(phoneButton)
        
        // location
        let locationButton = UIButton(frame: CGRectMake(view.frame.width/1.25 - 10, 20, 40, 40))
        locationButton.setImage(UIImage(named: "green-map-64"), forState: .Normal)
        locationButton.addTarget(self, action: "onLocation", forControlEvents: .TouchUpInside)
        infoView.addSubview(locationButton)
        
        // separator
        let lineSeparator = UIView(frame: CGRectMake(0, 64 + infoView.frame.height, view.frame.width, 2))
        lineSeparator.backgroundColor = UIColor(red: 0.1765, green: 0.2431, blue: 0.2706, alpha: 1.0) /* #2d3e45 the lighter version without trans*/
        self.view.addSubview(lineSeparator)
        
//MARK: TableView
        bentoTableView = UITableView(frame: CGRectMake(0, 64 + infoView.frame.height, view.frame.width, (view.frame.height - 80) - (64 + infoView.frame.height - 10)))
        bentoTableView.delegate = self
        bentoTableView.dataSource = self
        let backgroundView = UIView(frame: CGRectZero)
        backgroundView.backgroundColor = UIColor(red: 0.0392, green: 0.1373, blue: 0.1765, alpha: 1.0) /* #0a232d */
        bentoTableView.tableFooterView = backgroundView
        bentoTableView.backgroundColor = UIColor.clearColor()
        bentoTableView.separatorColor = UIColor(red: 0.1765, green: 0.2431, blue: 0.2706, alpha: 1.0) // #2d3e45
        if order.itemArray.count != 0 {
            self.view.addSubview(bentoTableView)
        }
        
//MARK: Task
        itemStringTextView = UITextView(frame: CGRectMake(20, 64 + infoView.frame.height + lineSeparator.frame.height + 20, self.view.frame.width - 40, self.view.frame.height - (64 + infoView.frame.height + 20 + backgroundView.frame.height + 90)))
        itemStringTextView.textColor = UIColor.whiteColor()
        itemStringTextView.backgroundColor = UIColor.clearColor()
        itemStringTextView.font = UIFont(name: "OpenSans-SemiBold", size: 17)
        itemStringTextView.userInteractionEnabled = true
        
        
        // comment this out to test item instead
        if order.orderString.isEmpty == true {
            // if there is a string message
            if order.itemString != nil {
                // display string message
                itemStringTextView.text = order.itemString
                view.addSubview(itemStringTextView)
            }
        }
        else {
            // display orderString
            itemStringTextView.text = order.orderString.stringByReplacingOccurrencesOfString("\\n", withString: "\n")
            view.addSubview(itemStringTextView)
        }
        
//MARK: Actions
        // View
        userActionView = UIView(frame: CGRectMake(0, view.frame.height - 70, view.frame.width, 70))
        userActionView.backgroundColor = UIColor(red: 0.1765, green: 0.2431, blue: 0.2706, alpha: 1.0) /* #2d3e45 the lighter version without trans*/
        view.addSubview(userActionView)
        
        // Reject
        rejectButton = UIButton(frame: CGRectMake(5, 10, view.frame.width / 2 - 10, 50))
        rejectButton.backgroundColor = UIColor(red: 0.8039, green: 0.2863, blue: 0.2235, alpha: 1.0) /* #cd4939 */
        rejectButton.layer.cornerRadius = 3
        rejectButton.setTitle("REJECT", forState: .Normal)
        rejectButton.titleLabel?.font = UIFont(name: "OpenSans-Bold", size: 21)
        rejectButton.titleLabel?.textColor = UIColor.whiteColor()
        rejectButton.addTarget(self, action: "onOrderAction:", forControlEvents: .TouchUpInside)
        userActionView.addSubview(rejectButton)
        
        // Accept
        acceptButton = UIButton(frame: CGRectMake(view.frame.width / 2 + 5, 10, view.frame.width / 2 - 10, 50))
        acceptButton.backgroundColor = UIColor(red: 0.2275, green: 0.5255, blue: 0.8118, alpha: 1.0) /* #3a86cf */
        acceptButton.layer.cornerRadius = 3
        acceptButton.setTitle("ACCEPT", forState: .Normal)
        acceptButton.titleLabel?.font = UIFont(name: "OpenSans-Bold", size: 21)
        acceptButton.titleLabel?.textColor = UIColor.whiteColor()
        acceptButton.addTarget(self, action: "onOrderAction:", forControlEvents: .TouchUpInside)
        userActionView.addSubview(acceptButton)
        
        // Arrived/Complete
        arrivedAndCompleteButton = UIButton(frame: CGRectMake(5, 10, view.frame.width-10, 50))
        arrivedAndCompleteButton.layer.cornerRadius = 3
        arrivedAndCompleteButton.titleLabel?.font = UIFont(name: "OpenSans-Bold", size: 21)
        arrivedAndCompleteButton.titleLabel?.textColor = UIColor.whiteColor()
        arrivedAndCompleteButton.addTarget(self, action: "onOrderAction:", forControlEvents: .TouchUpInside)
        userActionView.addSubview(arrivedAndCompleteButton)
        
        // acceppted
        if self.order.status == .Accepted {
            // flag to check if arrived has been tapped on, reset to nil once order is complete
            if NSUserDefaults.standardUserDefaults().boolForKey("arrivedWasTapped") == false {
                arrivedAndCompleteButton.backgroundColor = UIColor(red: 0.8196, green: 0.4392, blue: 0.1686, alpha: 1.0) /* #d1702b */
                arrivedAndCompleteButton.setTitle("ALERT CUSTOMER", forState: .Normal)
            }
            else {
                arrivedAndCompleteButton.backgroundColor = UIColor(red: 0.2784, green: 0.6588, blue: 0.5333, alpha: 1.0) /* #47a888 */
                arrivedAndCompleteButton.setTitle("COMPLETE", forState: .Normal)
            }
        }
        
        // check if order is accepted and show/hide buttons accordingly
        showHideButtons()
        
//MARK: Message Composer
        messageComposer = MessageComposer(phoneString: order.phone)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
//MARK: Show/Hide Buttons
    func showHideButtons() {
        if order.status == .Rejected {
            rejectButton.hidden = true
            acceptButton.hidden = true
            arrivedAndCompleteButton.hidden = true
            
            let rejectedLabel = UILabel(frame: CGRectMake(self.view.frame.width/2 - 100, userActionView.frame.height/2 - 25, 200, 50))
            rejectedLabel.font = UIFont(name: "OpenSans-Bold", size: 30)
            rejectedLabel.textColor = UIColor(red: 0.0392, green: 0.1373, blue: 0.1765, alpha: 1.0) /* #0a232d */
            rejectedLabel.textAlignment = .Center
            rejectedLabel.text = "REJECTED"
            userActionView.addSubview(rejectedLabel)
        }
        else if order.status == .Accepted {
            rejectButton.hidden = true
            acceptButton.hidden = true
            arrivedAndCompleteButton.hidden = false
        }
        else {
            rejectButton.hidden = false
            acceptButton.hidden = false
            arrivedAndCompleteButton.hidden = true
        }
    }
    
//MARK: TableView
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        if order.orderString.isEmpty { // comment out this conditional to test item mode instead
            return order.itemArray.count
        }
    
        return 0
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        // Header view
        let headerView = UIView()
        headerView.backgroundColor = UIColor(red: 0.1765, green: 0.2431, blue: 0.2706, alpha: 1.0) /* #2d3e45 the lighter version without trans*/
        
        // Title label
        let headerTitleLabel = UILabel(frame: CGRectMake(10, 5, view.frame.width - 20, 30))
        
        if order.itemArray[section].itemType == ItemType.BentoBox {
            headerTitleLabel.text = "Box \(section + 1)"
        }
        else {
            headerTitleLabel.text = "Add-ons"
        }
        
        headerTitleLabel.textColor = UIColor.whiteColor()
        headerTitleLabel.font = UIFont(name: "OpenSans-SemiBold", size: 21)
        headerView.addSubview(headerTitleLabel)
        
        return headerView
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 40
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return order.itemArray[0].items.count // dish count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellId = "Cell"
        
        var cell = tableView.dequeueReusableCellWithIdentifier(cellId)
        
        if cell == nil {
            cell = UITableViewCell(style: .Default, reuseIdentifier: cellId)
        }
        
        let itemLabelString = (order.itemArray[indexPath.section].items[indexPath.row].label)!
        let itemNameString = (order.itemArray[indexPath.section].items[indexPath.row].name)!
        
        cell?.textLabel?.text = "  \(itemLabelString) - \(itemNameString)"
        cell?.selectionStyle = .None
        cell?.textLabel?.textColor = UIColor.whiteColor()
        cell?.textLabel?.font = UIFont(name: "OpenSans-Regular", size: 14)
        cell?.backgroundColor = UIColor(red: 0.0392, green: 0.1373, blue: 0.1765, alpha: 1.0) /* #0a232d */
        
        return cell!
    }
    
    //MARK: Map URL
    func getMapURL(currentMapSetting: String, spaceFiller: String) -> NSURL {
        
        // filter out diacritics (symbols above letters)
        let streetString = self.order.street.stringByFoldingWithOptions(.DiacriticInsensitiveSearch, locale: NSLocale.currentLocale())
        let cityString = self.order.city.stringByFoldingWithOptions(.DiacriticInsensitiveSearch, locale: NSLocale.currentLocale())
        
        // street
        let streetArray = streetString.componentsSeparatedByString(" ")
        var newStreetArray: [String] = []
        for var i = 0; i < streetArray.count; i++ {
            newStreetArray.append("\(streetArray[i])\(spaceFiller)")
        }
        let newStreetString = newStreetArray.joinWithSeparator("")
        
        // city
        let cityArray = cityString.componentsSeparatedByString(" ")
        var newCityArray: [String] = []
        for var k = 0; k < cityArray.count; k++ {
            if cityArray[k] != cityArray[cityArray.count-1] {
                newCityArray.append("\(cityArray[k])\(spaceFiller)")
            }
            else {
                newCityArray.append("\(cityArray[k])") // don't add %20 at the end
            }
        }
        let newCityString = newCityArray.joinWithSeparator("")
        
        let addressForSchemeString = "\(newStreetString)\(newCityString)"
        
        // Waze
        if currentMapSetting == "Waze" {
            return NSURL(string: "waze://?q=\(addressForSchemeString)")!
        }
        
        // Google Maps
        return NSURL(string: "comgooglemaps://?saddr=&daddr=\(addressForSchemeString)&directionsmode=driving")!
    }
    
//MARK: On Location, Phone, and Text
    func onLocation() {
        let alertController = UIAlertController(title: "Address", message: "\(order.street)\n\(order.city), \(order.region)", preferredStyle: .Alert)
        
        alertController.addAction(UIAlertAction(title: "Let's go!", style: .Default, handler: { action in
            
            if let currentMapSetting = NSUserDefaults.standardUserDefaults().objectForKey("map") as? String {
                
                var url: NSURL!
                
                // Waze
                if currentMapSetting == "Waze" {
                    url = self.getMapURL(currentMapSetting, spaceFiller: "%20")
                }
                // Google Maps
                else {
                    url = self.getMapURL(currentMapSetting, spaceFiller: "+")
                }
                
                if UIApplication.sharedApplication().canOpenURL(url!) == true {
                    UIApplication.sharedApplication().openURL(url!)
                }
            }
        }))
        
        alertController.addAction(UIAlertAction(title: "Copy to clipboard", style: .Default, handler: { action in
            let pasteboard = UIPasteboard.generalPasteboard()
            pasteboard.string = "\(self.order.street) \(self.order.city), \(self.order.region)"
        }))
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .Destructive, handler: nil))
        
        presentViewController(alertController, animated: true, completion: nil)
    }
    
    func onPhone() {
        let alertController = UIAlertController(title: "Phone Number", message: "\(order.phone)", preferredStyle: .Alert)
        
        // get only digits from phone string
        let phoneArray = order.phone.componentsSeparatedByCharactersInSet(NSCharacterSet.decimalDigitCharacterSet().invertedSet)
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
        
        presentViewController(alertController, animated: true, completion: nil)
    }
    
    func onText() {
        if (messageComposer.canSendText()) {
            let messageComposerVC = messageComposer.configuredMessageComposeViewController()
            
            // dismissal handled by the messageComposer instance -> contains the delegate call-back
            presentViewController(messageComposerVC, animated: true, completion: nil)
        }
        else {
            // handle error...
            let alertController = UIAlertController(title: "", message: "Your device is unable to send text messages.", preferredStyle: .Alert)
            
            alertController.addAction(UIAlertAction(title: "OK", style: .Cancel, handler: nil))
            
            presentViewController(alertController, animated: true, completion: nil)
        }
    }

//MARK: On Order Action -> Confirm Order Action
    func onOrderAction(sender: UIButton) {
        
        // get button title and make it lowercase
        if let action = sender.titleLabel?.text {
            let actionLowercaseString = action.lowercaseString
            
//            // tapped on accepted
//            if actionLowercaseString == "accept" {
//                // there's already an accepted order
//                if isThereAlreadyAnAcceptedOrder() == true {
//                    showHoldYourHorsesAlert()
//                    return
//                }
//            }
//            
//          // no order has already been accepted, continue down...
            
            // tapped on arrive
            if actionLowercaseString == "alert customer" {
                arrivedOrder()
            }
            // tapped on either reject, accept, or complete
            else {
                showActionConfirmationAlert(actionLowercaseString)
            }
        }
    }
    
    func isThereAlreadyAnAcceptedOrder() -> Bool {
        // check if there are any other accepted order already
        for var i = 0; i < OrderList.sharedInstance.orderArray.count; i++ {
            
            // already has an accepted order...
            if OrderList.sharedInstance.orderArray[i].status == .Accepted {
                indexOfOrderThatHasAlreadyBeenAccepted = i
                return true
            }
        }
        
        return false
    }
    
//    func showHoldYourHorsesAlert() {
//        SoundEffect.sharedPlayer.playSound("horses")
//        
//        // prevent accepting
//        let alertController = UIAlertController(title: "Hold your horses!", message: "You already have a task in session. You must finish that first before accepting a new task.", preferredStyle: .Alert)
//        
//        // action 1
//        alertController.addAction(UIAlertAction(title: "Go to task", style: .Default, handler: { action in
//            
//            self.navigationController?.popViewControllerAnimated(true)
//            
//            self.delegate?.didTapOnGoToAcceptedTask!(OrderList.sharedInstance.orderArray[self.indexOfOrderThatHasAlreadyBeenAccepted!])
//        }))
//        
//        // action 2
//        alertController.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
//        
//        // show alert
//        self.presentViewController(alertController, animated: true, completion: nil)
//    }
    
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
        callHouston(api + "/order/reject" , parameters: parameters, task: "reject")
    }
    
    func acceptOrder() {
        callHouston(api + "/order/accept" , parameters: parameters, task: "accept")
    }
    
    func arrivedOrder() {
        callHouston(api + "/sms/bento-here", parameters: parameters, task: "alert customer")
    }
    
    func completeOrder() {
        callHouston(api + "/order/complete" , parameters: parameters, task: "complete")
    }
    
//MARK: Commit By Calling Houston
    func callHouston(apiString: String, parameters: [String: AnyObject], task: String) {
        
        showHUD()
        
        var paramsStr: String = ""
        for (key, value) in parameters {
            if let valStr = value as? String {
                paramsStr += (key + "=" + valStr + "&")
            }
        }
        
        // set custom timeout interval
        let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
        configuration.timeoutIntervalForRequest = 5
        configuration.timeoutIntervalForResource = 5
        alamofireManager = Alamofire.Manager(configuration: configuration)
        
        alamofireManager!.request(.GET, apiString, parameters: parameters).validate().responseJSON { response in
            
            switch response.result {
                
            case .Success:
                if let value = response.result.value {
                    
                    let json = JSON(value)
                    
                    let code = json["code"]
                    print("code: \(code)")
                    
                    let msg = json["msg"]
                    print("msg = \(msg)")
                    
                    let ret = json["ret"].stringValue.lowercaseString // normalize ret to lowercase
                    print("ret: \(ret)")
                    
                    Mixpanel.sharedInstance().track("Called \(apiString)", properties: [
                        "api": "\(apiString)?\(paramsStr)",
                        "code": "\(code)",
                        "msg": "\(msg)",
                        "ret": "\(ret)"
                        ]
                    )
                    
                    // Handle error...
                    if code != 0 {
                        let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(2.0 * Double(NSEC_PER_SEC)))
                        dispatch_after(delayTime, dispatch_get_main_queue()) {
                            self.dismissHUDWithSuccess(false)
                            
                            if code == 1 {
                                self.showOtherError("\(msg)")
                                return
                            }
                            else if code == 2 {
                                self.alertInvalidPhoneNumber()
                            }
                            
                            // continue with order accept
                            if task == "accept" {
                                self.delegate?.didAcceptOrder(self.order.id)
                                self.showHideButtons()
                                self.updateArrivedOrCompleteButtonState("alert customer")
                                self.setArrivedWasTapped(false)
                                SoundEffect.sharedPlayer.playSound("lets_drive")
                                return
                            }
                            
                            // show complete button once HUD has been dismissed after 2 seconds...
                            NSTimer.scheduledTimerWithTimeInterval(2, target: self, selector: "showCompleteButton", userInfo: nil, repeats: false)
                        }
                        
                        return
                    }
                    
                    // No Error
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        switch task {
                        case "reject":
                            if ret == "ok" {
                                self.delegate?.didRejectOrder(self.order.id)
                                
                                self.showHideButtons()
                                
                                NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "popViewController", userInfo: nil, repeats: false)
                            }
                        case "accept":
                            if ret == "ok" {
                                self.delegate?.didAcceptOrder(self.order.id)
                                
                                self.showHideButtons()
                                
                                self.updateArrivedOrCompleteButtonState("alert customer")
                                
                                self.setArrivedWasTapped(false)
                                
                                SoundEffect.sharedPlayer.playSound("lets_drive")
                            }
                        case "alert customer":
                            if ret == "ok" {
                                self.updateArrivedOrCompleteButtonState("complete")
                                
                                self.setArrivedWasTapped(true)
                                
                                SoundEffect.sharedPlayer.playSound("notified")
                            }
                        default: // complete
                            if ret == "ok" {
                                self.delegate?.didCompleteOrder(self.order.id)
                                
                                self.setArrivedWasTapped(false)
                                
                                SoundEffect.sharedPlayer.playSound("good_job")
                                
                                NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "popViewController", userInfo: nil, repeats: false)
                            }
                        }
                        
                        self.dismissHUDWithSuccess(true)
                    })
                }
            case .Failure(let error):
                print("API String - \(apiString), Error String - \(error.debugDescription)")
                
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    
                    self.dismissHUDWithSuccess(false)
                    
                    // error alert
                    let alertController = UIAlertController(title: "Error", message: "Failed to connect. Please try again.\n---\n\n\(error.debugDescription)", preferredStyle: .Alert)
                    
                    alertController.addAction(UIAlertAction(title: "OK", style: .Cancel, handler: nil))
                    
                    self.presentViewController(alertController, animated: true, completion: nil)
                    
                })
                
                Mixpanel.sharedInstance().track("Called \(apiString)", properties: [
                    "api": "\(apiString)\(paramsStr)",
                    "error": error.debugDescription
                    ]
                )
            }
        }
    }
    
    func popViewController() {
        navigationController?.popViewControllerAnimated(true)
    }
    
    func showCompleteButton() {
        updateArrivedOrCompleteButtonState("complete")
        setArrivedWasTapped(true)
    }
    
    func setArrivedWasTapped(bool: Bool) {
        // flag to check if arrived has been tapped on, reset to false once order is complete
         NSUserDefaults.standardUserDefaults().setBool(bool, forKey: "arrivedWasTapped")
    }
    
    func updateArrivedOrCompleteButtonState(arrivedOrComplete: String) {
        if arrivedOrComplete == "alert customer" {
            arrivedAndCompleteButton.backgroundColor = UIColor(red: 0.8196, green: 0.4392, blue: 0.1686, alpha: 1.0) /* #d1702b */
            arrivedAndCompleteButton.setTitle("ALERT CUSTOMER", forState: .Normal)
        }
        else if arrivedOrComplete == "complete" {
            arrivedAndCompleteButton.backgroundColor = UIColor(red: 0.2784, green: 0.6588, blue: 0.5333, alpha: 1.0) /* #47a888 */
            arrivedAndCompleteButton.setTitle("COMPLETE", forState: .Normal)
        }
    }
    
//MARK: SocketHandlerDelegate
    
    // this would only be called if internet had disconnected and reconnected again. in that case, check if any Orders were unassigned while disconnected
    func socketHandlerDidAuthenticate() {
        
        OrderList.sharedInstance.orderArray.removeAll()
        
        OrderList.sharedInstance.pullOrders { (result) -> Void in
            print("result: \(result)")
        }
    }
    
    func socketHandlerDidDisconnect() {
        // handle disconnect
        
        // dismiss multiple view (UNTESTED)
        (presentingViewController as! UINavigationController).popToRootViewControllerAnimated(false)
        dismissViewControllerAnimated(true, completion: nil)
        navigationController?.popToRootViewControllerAnimated(true)
    }
    
    func socketHandlerDidAssignOrder(assignedOrder: Order) {

        if assignedOrder.id == OrderList.sharedInstance.orderArray[0].id {
            statusBarNotification("Task switched!", taskMessage: "", success: true)
        }
        
//        OrderList.sharedInstance.orderArray.append(assignedOrder)
//        
//        self.taskHasBeenAssignedOrUnassigned("Task assigned!", taskMessage: "", success: true)
    }
    
    func socketHandlerDidUnassignOrder(unassignedOrder: Order, isCurrentTask: Bool) {

        if isCurrentTask == true {
            if OrderList.sharedInstance.orderArray.count != 0 {
                statusBarNotification("Task switched!", taskMessage: "", success: true)
            }
            else {
                statusBarNotification("Task removed!", taskMessage: "", success: true)
            }
        }
        
//        if unassignedOrder.id == self.order.id {
//            self.taskHasBeenAssignedOrUnassigned("This task has been unassigned!", taskMessage: "", success: true)
//        }
//        else {
//            self.taskHasBeenAssignedOrUnassigned("A task has been unassigned!", taskMessage: "", success: true)
//        }
    }
    
    func socketHandlerDidModifyOrder(modifiedOrder: Order, isCurrentTask: Bool) {
        if isCurrentTask == true {
            statusBarNotification("Task modified!", taskMessage: "", success: true)
            self.order = modifiedOrder;
        }
    }
    
    func socketHandlerDidReprioritizeOrder(reprioritized: Order, isCurrentTask: Bool) {
        
        // reprioritized order became first on list
        if reprioritized.id == OrderList.sharedInstance.orderArray[0].id ||
            // the first on list was reprioritized down
            (reprioritized.id != OrderList.sharedInstance.orderArray[0].id && isCurrentTask == true) {
         
                statusBarNotification("Task switched!", taskMessage: "", success: true)
        }
    }

//MARK: Invalid Phone
    func alertInvalidPhoneNumber() {
        let alertController = UIAlertController(title: "Invalid Phone Number", message: "SMS was not sent! Please inform dispatcher.", preferredStyle: .Alert)
        
        alertController.addAction(UIAlertAction(title: "Roger that!", style: .Cancel, handler: nil))
        
        presentViewController(alertController, animated: true, completion: nil)
    }
    
    
//MARK: Alert Error
    func showOtherError(errorMessage: String) {
        let alertController = UIAlertController(title: "Error", message: errorMessage, preferredStyle: .Alert)
        
        alertController.addAction(UIAlertAction(title: "OK", style: .Cancel, handler: nil))
        
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
                self.statusBarNotification("Waze saved!", taskMessage: "", success: true)
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
                self.statusBarNotification("Google Maps saved!", taskMessage: "", success: true)
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
            MapSetting.sharedMapSetting.setToNone()
            promptMapSettings(false)
        }
    }
    
    func manuallyPromptMapSettings() {
        promptMapSettings(true)
    }

//MARK: Status Bar Notification
    func statusBarNotification(taskTitle: String, taskMessage: String, success: Bool) {
        
        let alertController = UIAlertController(title: taskTitle, message: taskMessage, preferredStyle: .Alert)
        
        var doesTaskRequireAction: Bool = false // initialize
        
        if taskTitle == "Task removed!" || taskTitle == "Task switched!" || taskTitle == "Task modified!" {
            doesTaskRequireAction = true
            
            switch taskTitle {
            case "Task removed!":
                SocketHandler.sharedSocket.promptLocalNotification("assigned")
                SoundEffect.sharedPlayer.playSound("task_removed")
            case "Task switched!":
                SocketHandler.sharedSocket.promptLocalNotification("assigned")
                SoundEffect.sharedPlayer.playSound("task_switched")
            case "Task modified!":
                SocketHandler.sharedSocket.promptLocalNotification("modified")
                SoundEffect.sharedPlayer.playSound("task_modified")
            default: ()
            }
        }
        else {
            doesTaskRequireAction = false
            
            // status bar notification
            notification.notificationStyle = .NavigationBarNotification
            notification.notificationAnimationInStyle = .Left
            notification.notificationAnimationOutStyle = .Right
            notification.notificationLabelFont = UIFont(name: "OpenSans-Bold", size: 17)!
            notification.notificationLabelTextColor = UIColor.whiteColor()
            if success == true {
                notification.notificationLabelBackgroundColor = UIColor(red: 0.4902, green: 0.3137, blue: 0.651, alpha: 1.0) /* #7d50a6 */
            }
            else {
                notification.notificationLabelBackgroundColor = UIColor(red: 0.9059, green: 0.298, blue: 0.2353, alpha: 1.0) /* #e74c3c */
            }
            notification.displayNotificationWithMessage(taskTitle, forDuration: 2.0)
        }
        
        if doesTaskRequireAction == true {
            alertController.addAction(UIAlertAction(title: "Roger that!", style: .Cancel, handler: { action in
                self.navigationController?.popViewControllerAnimated(true)
                
                if taskTitle == "Task modified!" {
                    self.delegate?.didModifyOrder!(self.order)
                }
            }))
            
            presentViewController(alertController, animated: true, completion: nil)
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
            PKHUD.sharedHUD.hide(afterDelay: 1)
        }
        else {
            PKHUD.sharedHUD.contentView = PKHUDErrorView()
            PKHUD.sharedHUD.hide(afterDelay: 2)
        }
    }
}
