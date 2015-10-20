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

class OrderDetailViewController: UIViewController {
    
    var order: Order?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.whiteColor()
        
        self.title = self.order?.name
        
        // reject button
        let rejectButton = UIButton(type: .Custom)
        rejectButton.setImage(UIImage(named: "Waste-64"), forState: .Normal)
        rejectButton.addTarget(self, action: "onReject", forControlEvents: .TouchUpInside)
        rejectButton.frame = CGRectMake(0, 0, 20, 20)
        
        let rejectBarButton = UIBarButtonItem(customView: rejectButton)
        self.navigationItem.rightBarButtonItem = rejectBarButton
        
        // info view
        let infoView = UIView(frame: CGRectMake(0, 64, self.view.frame.width, 120))
        self.view.addSubview(infoView)
        
        // line separator
        let lineSeparatorView = UIView(frame: CGRectMake(0, 184, self.view.frame.width, 2))
        lineSeparatorView.backgroundColor = UIColor.lightGrayColor()
        self.view.addSubview(lineSeparatorView)
        
        // Accept
        let acceptButton = UIButton(frame: CGRectMake(0, self.view.frame.height - 60, self.view.frame.width, 60))
        acceptButton.backgroundColor = UIColor.lightGrayColor()
        acceptButton.setTitle("ACCEPT", forState: .Normal)
        acceptButton.titleLabel?.font = UIFont(name: "OpenSans-Bold", size: 17)
        acceptButton.titleLabel?.textColor = UIColor.whiteColor()
        self.view.addSubview(acceptButton)
        
        // driver id
        
        // id
        print(self.order?.id)
        
        // name
        print(self.order?.name)
        
        // phone
        print(self.order?.phone)
        
        // address
        print("\(self.order?.street), \(self.order?.city)")
        
        // status
        print(self.order?.status)
        
        // bento box
        let bentosArray: [BentoBox] = (self.order?.itemArray)!
        let bentoBox: BentoBox = bentosArray[0]
        let dishInfo: DishInfo = bentoBox.items[0]
        print(dishInfo.name)
    }
    
    func onReject() {
        
        
        
        // do this to add multiple parameters
        let parameters : [ String : AnyObject] = [
            "token": User.currentUser.token!,
            "orderId": self.order!.id
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
                    self.navigationController?.popViewControllerAnimated(true)
                }
            })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}
