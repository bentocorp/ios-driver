//
//  BentoBox.swift
//  BentoDriver
//
//  Created by Joseph Lau on 10/12/15.
//  Copyright © 2015 Joseph Lau. All rights reserved.
//

import Foundation

public enum Temperature {
    case Hot, Cold
    
    func temperatureFromString(temperatureString: String)-> Temperature {
        switch temperatureString {
        case "hot":
            return Hot
        default:
            return Cold
        }
    }
}

public enum Type {
    case Main, Side, Add_On
    
    
}

public class BentoBox {
    
}