//
//  IntExtension.swift
//  pollution
//
//  Created by Philipp Matthes on 27.11.17.
//  Copyright © 2017 Philipp Matthes. All rights reserved.
//

import Foundation

extension Int {
    
    func outOfRange(inList list : [Any]) -> Bool{
        return self > list.endIndex || self < list.startIndex
    }
    
}
