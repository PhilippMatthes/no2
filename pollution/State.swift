//
//  State.swift
//  pollution
//
//  Created by Philipp Matthes on 07.11.17.
//  Copyright © 2017 Philipp Matthes. All rights reserved.
//

import Foundation
import UIKit
import RevealingSplashView

class State {
    
    static let shared = State()
    
    let defaults = UserDefaults(suiteName: "group.pollution")!
    var currentType: String = Constants.units.first! {
        willSet(newCurrentType) {
            State.shared.store(currentType: newCurrentType)
            State.shared.currentColor = Constants.colors[newCurrentType]!
        }
    }
    var currentUnit: String = Constants.supportedUnits.first! {
        willSet(newCurrentUnit) {
            State.shared.store(currentUnit: newCurrentUnit)
        }
    }
    var currentColor: UIColor = Constants.colors[Constants.units.first!]!
    var numberOfMapResults: Int = 1000 {
        willSet(newNumber) {
            State.shared.store(numberOfMapResults: newNumber)
        }
    }
    var splashAnimationType: SplashAnimationType = .twitter {
        willSet(newAnimationType) {
            State.shared.store(animationType: newAnimationType)
        }
    }
    var cornerRadius: CGFloat = CGFloat(10.0) {
        willSet(newCornerRadius) {
            State.shared.store(cornerRadius: newCornerRadius)
        }
    }
    var isHeatmapOn: Bool = true {
        willSet(change) {
            State.shared.store(isHeatmapOn: change)
        }
    }
    
    var transferAnnotation: PollutionAnnotation?
    
    private init() {
        
    }
    
    func load() {
        if let type = UserDefaults.loadObject(ofType: String(), withIdentifier: "currentType") {
            State.shared.currentType = type
        }
        if let unit = UserDefaults.loadObject(ofType: String(), withIdentifier: "currentUnit") {
            State.shared.currentUnit = unit
        }
        if let number = UserDefaults.loadObject(ofType: Int(), withIdentifier: "numberOfMapResults") {
            State.shared.numberOfMapResults = number
        }
        if let animationType = UserDefaults.loadObject(ofType: String(), withIdentifier: "animationType") {
            State.shared.splashAnimationType = Constants.stringToAnimationType[animationType]!
        }
        if let cornerRadius = UserDefaults.loadObject(ofType: CGFloat(), withIdentifier: "cornerRadius") {
            State.shared.cornerRadius = cornerRadius
        }
        if let isHeatmapOn = UserDefaults.loadObject(ofType: Bool(), withIdentifier: "isHeatmapOn") {
            State.shared.isHeatmapOn = isHeatmapOn
        }
    }
    
    func store(currentType: String) {
        UserDefaults.save(object: currentType, withIdentifier: "currentType")
    }
    
    func store(currentUnit: String) {
        UserDefaults.save(object: currentUnit, withIdentifier: "currentUnit")
    }
    
    func store(numberOfMapResults: Int) {
        UserDefaults.save(object: numberOfMapResults, withIdentifier: "numberOfMapResults")
    }
    
    func store(animationType: SplashAnimationType) {
        let stringAnimationType = Constants.animationTypeToString[animationType]!
        UserDefaults.save(object: stringAnimationType, withIdentifier: "animationType")
    }
    
    func store(cornerRadius: CGFloat) {
        UserDefaults.save(object: cornerRadius, withIdentifier: "cornerRadius")
    }
    
    func store(isHeatmapOn: Bool) {
        UserDefaults.save(object: isHeatmapOn, withIdentifier: "isHeatmapOn")
    }
    
}
