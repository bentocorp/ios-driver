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
        
// User Info
        // View
        let infoView = UIView(frame: CGRectMake(0, 64, self.view.frame.width, 120))
        self.view.addSubview(infoView)
        
// Actions
        // View
        let userActionView = UIView(frame: CGRectMake(0, self.view.frame.height - 70, self.view.frame.width, 70))
        self.view.addSubview(userActionView)
        
        // Accept
        let acceptButton = UIButton(frame: CGRectMake(5, 5, self.view.frame.width / 2 - 10, 60))
        acceptButton.backgroundColor = UIColor.lightGrayColor()
        acceptButton.layer.cornerRadius = 1
        acceptButton.setTitle("ACCEPT", forState: .Normal)
        acceptButton.titleLabel?.font = UIFont(name: "OpenSans-Bold", size: 17)
        acceptButton.titleLabel?.textColor = UIColor.whiteColor()
        acceptButton.addTarget(self, action: "onAccept", forControlEvents: .TouchUpInside)
        userActionView.addSubview(acceptButton)
        
        // Reject
        let rejectButton = UIButton(frame: CGRectMake(self.view.frame.width / 2 + 5, 5, self.view.frame.width / 2 - 10, 60))
        rejectButton.backgroundColor = UIColor.lightGrayColor()
        rejectButton.layer.cornerRadius = 1
        rejectButton.setTitle("REJECT", forState: .Normal)
        rejectButton.titleLabel?.font = UIFont(name: "OpenSans-Bold", size: 17)
        rejectButton.titleLabel?.textColor = UIColor.whiteColor()
        rejectButton.addTarget(self, action: "onReject", forControlEvents: .TouchUpInside)
        userActionView.addSubview(rejectButton)
        
// TableView
        self.bentoTableView = UITableView(frame: CGRectMake(0, 64 + infoView.frame.height, self.view.frame.width, (self.view.frame.height - 70) - (64 + infoView.frame.height) ))
        self.bentoTableView.delegate = self
        self.bentoTableView.dataSource = self
        let backgroundView = UIView(frame: CGRectZero)
        self.bentoTableView.tableFooterView = backgroundView
        self.bentoTableView.backgroundColor = UIColor.clearColor()
        self.view.addSubview(self.bentoTableView)

// Line Separators
        // 1
        let lineSeparatorView = UIView(frame: CGRectMake(0, 64 + infoView.frame.height, self.view.frame.width, 1))
        lineSeparatorView.backgroundColor = UIColor.lightGrayColor()
        self.view.addSubview(lineSeparatorView)
        
        // 2
        let lineSeparatorView2 = UIView(frame: CGRectMake(0, self.view.frame.height - 70, self.view.frame.width, 1))
        lineSeparatorView2.backgroundColor = UIColor.lightGrayColor()
        self.view.addSubview(lineSeparatorView2)
    }
    
    func onReject() {
        // prompt reject confirmation
        let alertController = UIAlertController(title: "", message: "Are you sure you want to reject order?", preferredStyle: .Alert)
        
        alertController.addAction(UIAlertAction(title: "OK", style: .Default, handler: { action in
            // close socket
            self.rejectOrder()
        }))
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
        
        self.presentViewController(alertController, animated: true, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
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
    
//MARK: TableView
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.order.itemArray.count // box count
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
        
        cell?.selectionStyle = .None
        cell?.textLabel?.text = "* \((order.itemArray[indexPath.section].items[indexPath.row].name)!) (\((order.itemArray[indexPath.section].items[indexPath.row].label)!))"
        
        return cell!
    }
}
