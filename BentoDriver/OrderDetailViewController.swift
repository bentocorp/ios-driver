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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        let rejectButton = UIButton(frame: CGRectMake(5, 10, self.view.frame.width / 2 - 10, 50))
        rejectButton.backgroundColor = UIColor.grayColor()
        rejectButton.layer.cornerRadius = 1
        rejectButton.setTitle("REJECT", forState: .Normal)
        rejectButton.titleLabel?.font = UIFont(name: "OpenSans-Bold", size: 21)
        rejectButton.titleLabel?.textColor = UIColor.whiteColor()
        rejectButton.addTarget(self, action: "onReject", forControlEvents: .TouchUpInside)
        userActionView.addSubview(rejectButton)
        
        // Accept
        let acceptButton = UIButton(frame: CGRectMake(self.view.frame.width / 2 + 5, 10, self.view.frame.width / 2 - 10, 50))
        acceptButton.backgroundColor = UIColor.grayColor()
        acceptButton.layer.cornerRadius = 1
        acceptButton.setTitle("ACCEPT", forState: .Normal)
        acceptButton.titleLabel?.font = UIFont(name: "OpenSans-Bold", size: 21)
        acceptButton.titleLabel?.textColor = UIColor.whiteColor()
        acceptButton.addTarget(self, action: "onAccept", forControlEvents: .TouchUpInside)
        userActionView.addSubview(acceptButton)
        
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

//MARK: User Action
    func onReject() {
        // prompt reject confirmation
        let alertController = UIAlertController(title: "", message: "Are you sure you want to reject order?", preferredStyle: .Alert)
        
        alertController.addAction(UIAlertAction(title: "Reject", style: .Default, handler: { action in
            // close socket
            self.rejectOrder()
        }))
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
        
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    func rejectOrder() {
        // do this to add multiple parameters
        let parameters : [ String : AnyObject] = [
            "token": User.currentUser.token!,
            "orderId": self.order.id
        ]
        
        Alamofire.request(.GET, "http://52.11.208.197:8081/api/order/reject", parameters: parameters)
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
                
                if ret == "ok" {
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        
                        self.navigationController?.popViewControllerAnimated(true)
                        
                        self.delegate?.didRejectOrder(self.order.id)
                    })
                }
            })
    }
    

    func onAccept() {
        // prompt reject confirmation
        let alertController = UIAlertController(title: "", message: "Are you sure you want to accept order?", preferredStyle: .Alert)
        
        alertController.addAction(UIAlertAction(title: "Accept", style: .Default, handler: { action in
            // close socket
            self.acceptOrder()
        }))
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
        
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    func acceptOrder() {
        // do this to add multiple parameters
        let parameters : [ String : AnyObject] = [
            "token": User.currentUser.token!,
            "orderId": self.order.id
        ]
        
        Alamofire.request(.GET, "http://52.11.208.197:8081/api/order/accept", parameters: parameters)
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
                
//                if ret == "ok" {
//                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
//                        
//                        self.navigationController?.popViewControllerAnimated(true)
//                        
//                        self.delegate?.didRejectOrder(self.order.id)
//                    })
//                }
            })
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
        
        // Gradient
//        let topColor: UIColor = UIColor.lightGrayColor()
//        let bottomColor: UIColor = UIColor.clearColor()
//
//        let gradientColors: [CGColor] = [topColor.CGColor, bottomColor.CGColor]
//        let gradientLocations: [Float] = [0.0, 1.0]
//
//        let gradientLayer: CAGradientLayer = CAGradientLayer()
//        gradientLayer.colors = gradientColors
//        gradientLayer.locations = gradientLocations
//        gradientLayer.frame = CGRectMake(0, 0, self.view.frame.width, 40)
//        headerView.layer.insertSublayer(gradientLayer, atIndex: 0)
        
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
}
