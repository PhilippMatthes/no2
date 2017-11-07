//
//  State.swift
//  pollution
//
//  Created by Philipp Matthes on 07.11.17.
//  Copyright © 2017 Philipp Matthes. All rights reserved.
//

import Foundation

class State {
    
    static let shared = State()
    
    private init() {}
    
    var currentType = Constants.units.first!
    
}
