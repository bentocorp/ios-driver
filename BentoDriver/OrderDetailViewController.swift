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
import MessageUI

protocol OrderDetailViewControllerDelegate {
    func didRejectOrder(orderId: String)
    func didAcceptOrder(orderId: String)
    func didCompleteOrder(orderId: String)
}

class OrderDetailViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, MFMessageComposeViewControllerDelegate {

    // Properties
    var order: Order!
    
    var api: String!
    var parameters : [String : AnyObject]!
    
    var rejectButton: UIButton!
    var acceptButton: UIButton!
    var completeButton: UIButton!
    
    var bentoTableView: UITableView!
    
    var delegate: OrderDetailViewControllerDelegate?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
// API & Parameters
        self.api = "http://52.11.208.197:8081/api/order"
        self.parameters = ["token": User.currentUser.token!, "orderId": self.order.id]

// 
        self.title = self.order.name
        self.view.backgroundColor = UIColor(red: 0.0392, green: 0.1373, blue: 0.1765, alpha: 1.0) /* #0a232d */
        
// Customer Info
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
        
// TableView
        self.bentoTableView = UITableView(frame: CGRectMake(0, 64 + infoView.frame.height, self.view.frame.width, (self.view.frame.height - 80) - (64 + infoView.frame.height - 10)))
        self.bentoTableView.delegate = self
        self.bentoTableView.dataSource = self
        let backgroundView = UIView(frame: CGRectZero)
        backgroundView.backgroundColor = UIColor(red: 0.0392, green: 0.1373, blue: 0.1765, alpha: 1.0) /* #0a232d */
        self.bentoTableView.tableFooterView = backgroundView
        self.bentoTableView.backgroundColor = UIColor.clearColor()
        self.view.addSubview(self.bentoTableView)
        
// Actions
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
        self.rejectButton.addTarget(self, action: "promptUserActionConfirmation:", forControlEvents: .TouchUpInside)
        userActionView.addSubview(self.rejectButton)
        
        // Accept
        self.acceptButton = UIButton(frame: CGRectMake(self.view.frame.width / 2 + 5, 10, self.view.frame.width / 2 - 10, 50))
        self.acceptButton.backgroundColor = UIColor(red: 0.2275, green: 0.5255, blue: 0.8118, alpha: 1.0) /* #3a86cf */
        self.acceptButton.layer.cornerRadius = 3
        self.acceptButton.setTitle("ACCEPT", forState: .Normal)
        self.acceptButton.titleLabel?.font = UIFont(name: "OpenSans-Bold", size: 21)
        self.acceptButton.titleLabel?.textColor = UIColor.whiteColor()
        self.acceptButton.addTarget(self, action: "promptUserActionConfirmation:", forControlEvents: .TouchUpInside)
        userActionView.addSubview(self.acceptButton)
        
        // Complete
        self.completeButton = UIButton(frame: CGRectMake(5, 10, self.view.frame.width-10, 50))
        self.completeButton.backgroundColor = UIColor(red: 0.2784, green: 0.6588, blue: 0.5333, alpha: 1.0) /* #47a888 */
        self.completeButton.layer.cornerRadius = 3
        self.completeButton.setTitle("COMPLETE", forState: .Normal)
        self.completeButton.titleLabel?.font = UIFont(name: "OpenSans-Bold", size: 21)
        self.completeButton.titleLabel?.textColor = UIColor.whiteColor()
        self.completeButton.addTarget(self, action: "promptUserActionConfirmation:", forControlEvents: .TouchUpInside)
        userActionView.addSubview(self.completeButton)
        
        // check if order is accepted and show/hide buttons accordingly
        self.showHideButtons()
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
            self.completeButton.hidden = false
        }
        else {
            self.rejectButton.hidden = false
            self.acceptButton.hidden = false
            self.completeButton.hidden = true
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
        cell?.textLabel?.text = "  ( \(itemLabelString) )  \(itemNameString)"
        cell?.textLabel?.font = UIFont(name: "OpenSans-Regular", size: 14)
        cell?.backgroundColor = UIColor(red: 0.0392, green: 0.1373, blue: 0.1765, alpha: 1.0) /* #0a232d */
        
        return cell!
    }
    
//MARK On Location, Phone, and Text
    func onLocation() {
        let alertController = UIAlertController(title: "", message: "\(self.order.street)\n\(self.order.city), \(self.order.region)", preferredStyle: .Alert)
        
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
        let alertController = UIAlertController(title: "", message: "\(self.order.phone)", preferredStyle: .Alert)
        
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
        if (!MFMessageComposeViewController.canSendText()) {
            let warningAlert : UIAlertView = UIAlertView();
            warningAlert.title = "Error";
            warningAlert.message = "Your device does not support SMS.";
            warningAlert.delegate = nil;
            warningAlert.show();
            return;
        }
        
        // get only digits from phone string
        let phoneArray = self.order.phone.componentsSeparatedByCharactersInSet(NSCharacterSet.decimalDigitCharacterSet().invertedSet)
        let phoneDigitsOnlyString = phoneArray.joinWithSeparator("")
        
        let recipients: [String] = ["\(phoneDigitsOnlyString)"];
        
        let messageController = MFMessageComposeViewController()
        messageController.messageComposeDelegate = self;
        messageController.recipients = recipients;
        
        self.presentViewController(messageController, animated: true, completion: nil);
    }

    func messageComposeViewController(controller: MFMessageComposeViewController, didFinishWithResult result: MessageComposeResult) {
        if (result.rawValue == MessageComposeResultCancelled.rawValue) {
            NSLog("Message was cancelled.");
        }
        else if (result.rawValue == MessageComposeResultFailed.rawValue) {
            let warningAlert = UIAlertView();
            warningAlert.title = "Error";
            warningAlert.message = "Failed to send SMS!";
            warningAlert.delegate = nil;
            warningAlert.show();
            NSLog("Message failed.");
        }
        else {
            NSLog("Message was sent.");
        }
        
        self.dismissViewControllerAnimated(true, completion: nil);
    }


//MARK: On Order Action -> Confirm
    func promptUserActionConfirmation(sender: UIButton) {
        
        // get button title and make it lowercase
        if let action = sender.titleLabel?.text {
            
            let actionLowercaseString = action.lowercaseString
            
            let alertController = UIAlertController(title: "", message: "Are you sure you want to \(actionLowercaseString) order?", preferredStyle: .Alert)
            
            alertController.addAction(UIAlertAction(title: actionLowercaseString.firstCharacterUpperCase(), style: .Default, handler: { action in
                
                switch actionLowercaseString {
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
    }
    
//MARK: Commit Action
    func rejectOrder() {
        self.callHouston(self.api + "/reject" , parameters: self.parameters, task: "reject")
    }
    
    func acceptOrder() {
        self.callHouston(self.api + "/accept" , parameters: self.parameters, task: "accept")
    }
    
    func completeOrder() {
        self.callHouston(self.api + "/complete" , parameters: self.parameters, task: "complete")
    }
    
//MARK: Call Houston
    func callHouston(apiString: String, parameters: [String: AnyObject], task: String) {
        
        Alamofire.request(.GET, apiString, parameters: parameters)
        .responseSwiftyJSON({ (request, response, json, error) in
            
            let code = json["code"]
            let msg = json["msg"]
            
            print("code: \(code)")
            print("msg = \(msg)")
            
            if code != 0 {
                print(msg)
                return
            }
            
            let ret = json["ret"].stringValue
            print("ret: \(ret)")
            
            switch task {
            case "reject":
                if ret == "ok" {
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        
                        self.navigationController?.popViewControllerAnimated(true)
                        
                        self.delegate?.didRejectOrder(self.order.id)
                    })
                }
            case "accept":
                if ret == "ok" {
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        
                        // change the Order status in ordersArray in parent VC
                        self.delegate?.didAcceptOrder(self.order.id)
                        
                        // change status
                        
                        // change buttons
                        self.rejectButton.hidden = true
                        self.acceptButton.hidden = true
                        self.completeButton.hidden = false
                    })
                }
            default: // complete
                if ret == "ok" {
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        
                        self.navigationController?.popViewControllerAnimated(true)
                        
                        // change the Order status in ordersArray in parent VC
                        self.delegate?.didCompleteOrder(self.order.id)
                    })
                }
            }
        })
    }
}
