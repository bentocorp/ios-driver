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

protocol OrderDetailViewControllerDelegate {
    func didRejectOrder(orderId: Int)
    func didAcceptOrder(orderId: Int)
    func didCompleteOrder(orderId: Int)
}

class OrderDetailViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var delegate: OrderDetailViewControllerDelegate?
    var order: Order!
    var bentoTableView: UITableView!
    var rejectButton: UIButton!
    var acceptButton: UIButton!
    var completeButton: UIButton!
    var api: String!
    var parameters : [ String : AnyObject]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
// API & Parameters
        self.api = "http://52.11.208.197:8081/api/order"
        self.parameters = ["token": User.currentUser.token!, "orderId": self.order.id]

        
        self.title = self.order.name
        self.view.backgroundColor = UIColor.whiteColor()
        
// Customer Info
        // View
        let infoView = UIView(frame: CGRectMake(0, 64, self.view.frame.width, 120))
        self.view.addSubview(infoView)
        
        // name
        
        // address -> street, city, state, zip code
        
        // phone -> text/call/copy
        
        // status
        
// Actions
        // View
        let userActionView = UIView(frame: CGRectMake(0, self.view.frame.height - 70, self.view.frame.width, 70))
        userActionView.backgroundColor = UIColor.lightGrayColor()
        self.view.addSubview(userActionView)
        
        // Reject
        self.rejectButton = UIButton(frame: CGRectMake(5, 10, self.view.frame.width / 2 - 10, 50))
        self.rejectButton.backgroundColor = UIColor.redColor()
        self.rejectButton.layer.cornerRadius = 1
        self.rejectButton.setTitle("REJECT", forState: .Normal)
        self.rejectButton.titleLabel?.font = UIFont(name: "OpenSans-Bold", size: 21)
        self.rejectButton.titleLabel?.textColor = UIColor.whiteColor()
        self.rejectButton.addTarget(self, action: "promptUserActionConfirmation:", forControlEvents: .TouchUpInside)
        userActionView.addSubview(self.rejectButton)
        
        // Accept
        self.acceptButton = UIButton(frame: CGRectMake(self.view.frame.width / 2 + 5, 10, self.view.frame.width / 2 - 10, 50))
        self.acceptButton.backgroundColor = UIColor.blueColor()
        self.acceptButton.layer.cornerRadius = 1
        self.acceptButton.setTitle("ACCEPT", forState: .Normal)
        self.acceptButton.titleLabel?.font = UIFont(name: "OpenSans-Bold", size: 21)
        self.acceptButton.titleLabel?.textColor = UIColor.whiteColor()
        self.acceptButton.addTarget(self, action: "promptUserActionConfirmation:", forControlEvents: .TouchUpInside)
        userActionView.addSubview(self.acceptButton)
        
        // Complete
        self.completeButton = UIButton(frame: CGRectMake(5, 10, self.view.frame.width - 10, 50))
        self.completeButton.backgroundColor = UIColor.greenColor()
        self.completeButton.layer.cornerRadius = 1
        self.completeButton.setTitle("COMPLETE", forState: .Normal)
        self.completeButton.titleLabel?.font = UIFont(name: "OpenSans-Bold", size: 21)
        self.completeButton.titleLabel?.textColor = UIColor.whiteColor()
        self.completeButton.addTarget(self, action: "promptUserActionConfirmation:", forControlEvents: .TouchUpInside)
        userActionView.addSubview(self.completeButton)
        
        // check if order is accepted and show/hide buttons accordingly
        self.showHideButtons()
        
// TableView
        self.bentoTableView = UITableView(frame: CGRectMake(0, 64 + infoView.frame.height, self.view.frame.width, (self.view.frame.height - 70) - (64 + infoView.frame.height)))
        self.bentoTableView.delegate = self
        self.bentoTableView.dataSource = self
        let backgroundView = UIView(frame: CGRectZero)
        self.bentoTableView.tableFooterView = backgroundView
        self.bentoTableView.backgroundColor = UIColor.clearColor()
        self.view.addSubview(self.bentoTableView)

// Line Separators
        // 1
//        let lineSeparatorView = UIView(frame: CGRectMake(0, 64 + infoView.frame.height, self.view.frame.width, 10))
        
        
        // 2
//        let lineSeparatorView2 = UIView(frame: CGRectMake(0, self.view.frame.height - 70, self.view.frame.width, 1))
//        lineSeparatorView2.backgroundColor = UIColor.lightGrayColor()
//        self.view.addSubview(lineSeparatorView2)
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
        headerView.backgroundColor = UIColor.grayColor()
        headerView.alpha = 0.75
        
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
        cell?.textLabel?.textColor = UIColor.darkGrayColor()
        cell?.textLabel?.text = "• (\(itemLabelString)) \(itemNameString)"
        cell?.textLabel?.font = UIFont(name: "OpenSans-Regular", size: 14)
        
        return cell!
    }

//MARK: On Action -> Confirm
    func promptUserActionConfirmation(sender:UIButton) {
        
        // get button title and make it lowercase
        let action = sender.titleLabel?.text?.lowercaseString
        
        let alertController = UIAlertController(title: "", message: action, preferredStyle: .Alert)
        
        alertController.addAction(UIAlertAction(title: "Are you sure you want to \(action!.firstCharacterUpperCase()) order?",
            style: .Default, handler: { action in
            
            switch action {
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
                        
                        // change the Order status in ordersArray in parent VC
                        self.delegate?.didCompleteOrder(self.order.id)
                    })
                }
            }
        })
    }
}
