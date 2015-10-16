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

/*

Bento boxes contains an array of dishes(DishInfo)

"items" : [
{
    "id" : 30,
    "label" : "B",
    "name" : "Kimchi Fried Rice",
    "type" : "main"
},
{
    "id" : 41,
    "label" : "D",
    "name" : "Jasmine Rice",
    "type" : "side"
},
{
    "id" : 59,
    "label" : "Y",
    "name" : "Kale & Carrot Curry Salad",
    "type" : "side"
},
{
    "id" : 32,
    "label" : "D",
    "name" : "Miso Udon Noodles",
    "type" : "side"
},
{
    "id" : 61,
    "label" : "C",
    "name" : "Miso Marinated Mushrooms",
    "type" : "side"
}
]

*/
