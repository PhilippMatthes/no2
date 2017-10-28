//
//  PollutionMeasurement.swift
//  pollution
//
//  Created by Philipp Matthes on 26.10.17.
//  Copyright © 2017 Philipp Matthes. All rights reserved.
//

import Foundation

class PollutionMeasurement {
    
    var date: String?
    var type: String?
    var value: Double?
    var unit: String?
    var source: String?
    var rate: String?

    init(date: String, type: String, value: Double, unit: String, source: String, rate: String) {
        self.date = date
        self.type = type
        self.value = value
        self.unit = unit
        self.source = source
        self.rate = rate
    }
    
    init() {}
}
