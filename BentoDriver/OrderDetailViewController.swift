//
//  OrderDetailViewController.swift
//  BentoDriver
//
//  Created by Joseph Lau on 10/9/15.
//  Copyright © 2015 Joseph Lau. All rights reserved.
//

import UIKit

class OrderDetailViewController: UIViewController {
    
    var order: Order?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.whiteColor()
        
        self.title = self.order?.name
        
        
        
        /*

        public var id: Int
        public var name: String
        public var phone: String
        
        /*-Address (Dictionary)-*/
        public var street: String
        public var residence: String?
        public var city: String
        public var region: String
        public var zipCode: String
        public var country: String
        public var coordinates: CLLocationCoordinate2D
        
        public var status: OrderStatus
        public var itemClass: String
        // public var item: T
        public var itemArray: [BentoBox]?
        public var itemString: String?
        */
        
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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
