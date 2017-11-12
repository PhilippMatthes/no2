//
//  State.swift
//  pollution
//
//  Created by Philipp Matthes on 07.11.17.
//  Copyright © 2017 Philipp Matthes. All rights reserved.
//

import Foundation
import UIKit

class State {
    
    static let shared = State()
    
    let defaults = UserDefaults(suiteName: "group.pollution")!
    var currentType: String = Constants.units.first! {
        willSet(newCurrentType) {
            State.shared.store(currentType: newCurrentType)
            State.shared.currentColor = Constants.colors[newCurrentType]!
        }
    }
    var currentColor: UIColor = Constants.colors[Constants.units.first!]!
    var numberOfMapResults: Int = 1000 {
        willSet(newNumber) {
            State.shared.store(numberOfMapResults: newNumber)
        }
    }
    
    var transferAnnotation: PollutionAnnotation?
    
    private init() {
        
    }
    
    func load() {
        if let type = DiskJockey.loadObject(ofType: String(), withIdentifier: "currentType") {
            State.shared.currentType = type
        }
        if let number = DiskJockey.loadObject(ofType: Int(), withIdentifier: "numberOfMapResults") {
            State.shared.numberOfMapResults = number
        }
    }
    
    func store(currentType: String) {
        DiskJockey.save(object: currentType, withIdentifier: "currentType")
    }
    
    func store(numberOfMapResults: Int) {
        DiskJockey.save(object: numberOfMapResults, withIdentifier: "numberOfMapResults")
    }
    
}
