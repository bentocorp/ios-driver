//
//  BentoBox.swift
//  BentoDriver
//
//  Created by Joseph Lau on 10/12/15.
//  Copyright © 2015 Joseph Lau. All rights reserved.
//

import Foundation
import SwiftyJSON

public class BentoBox {
    public var items: [DishInfo] = []
    
    init(json: JSON) {
        for dishJSON in json["items"].arrayValue {
            items.append(DishInfo(json: dishJSON))
        }
    }
}









