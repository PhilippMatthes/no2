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
    let defaults = UserDefaults(suiteName: "group.pollution")!
    var currentType: String = Constants.units.first! {
        willSet(newCurrentType) {
            State.shared.store(currentType: newCurrentType)
        }
    }
    
    private init() {
        
    }
    
    func load() {
        if let type = DiskJockey.loadObject(ofType: String(), withIdentifier: "currentType") {
            State.shared.currentType = type
        }
    }
    
    func store(currentType: String) {
        DiskJockey.save(object: currentType, withIdentifier: "currentType")
    }
    
}
