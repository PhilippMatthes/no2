//
//  PollutionDataEntry.swift
//  pollution
//
//  Created by Philipp Matthes on 26.10.17.
//  Copyright © 2017 Philipp Matthes. All rights reserved.
//

import Foundation

class PollutionDataEntry: Hashable {
    
    var city: String?
    var distance: Double?
    var location: String?
    var country: String?
    var latitude: Double?
    var longitude: Double?
    var measurements: [PollutionMeasurement]?
    
    init(city: String, distance: Double, location: String, country: String, measurements: [PollutionMeasurement], latitude: Double, longitude: Double) {
        self.city = city
        self.distance = distance
        self.location = location
        self.country = country
        self.measurements = measurements
        self.latitude = latitude
        self.longitude = longitude
    }
    
    init () {}
    
    public var hashValue: Int {
        return ObjectIdentifier(self).hashValue
    }
    
    static func ==(lhs: PollutionDataEntry, rhs: PollutionDataEntry) -> Bool {
        return ObjectIdentifier(lhs) == ObjectIdentifier(rhs)
    }
    
}
