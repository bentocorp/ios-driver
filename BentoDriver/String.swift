//
//  String.swift
//  BentoDriver
//
//  Created by Joseph Lau on 10/20/15.
//  Copyright © 2015 Joseph Lau. All rights reserved.
//

import Foundation

extension String {
    
    func firstCharacterUpperCase() -> String {
        let lowercaseString = self.lowercaseString
        
        return lowercaseString.stringByReplacingCharactersInRange(lowercaseString.startIndex...lowercaseString.startIndex, withString: String(lowercaseString[lowercaseString.startIndex]).uppercaseString)
    }
}