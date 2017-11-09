//
//  PollutionDataEntry.swift
//  pollution
//
//  Created by Philipp Matthes on 26.10.17.
//  Copyright © 2017 Philipp Matthes. All rights reserved.
//

import Foundation

class PollutionDataEntry: NSObject, NSCoding {
    
    var city: String?
    var distance: Double?
    var location: String?
    var country: String?
    var latitude: Double?
    var longitude: Double?
    var measurements = [PollutionMeasurement]()
    
    init(city: String,
         distance: Double,
         location: String,
         country: String,
         measurements: [PollutionMeasurement],
         latitude: Double,
         longitude: Double) {
        self.city = city
        self.distance = distance
        self.location = location
        self.country = country
        self.measurements = measurements
        self.latitude = latitude
        self.longitude = longitude
    }
    
    override init () {}
    
    convenience required init?(coder aDecoder: NSCoder) {
        guard
            let city = aDecoder.decodeObject(forKey: "city") as? String,
            let distance = aDecoder.decodeObject(forKey: "distance") as? Double,
            let location = aDecoder.decodeObject(forKey: "location") as? String,
            let country = aDecoder.decodeObject(forKey: "country") as? String,
            let latitude = aDecoder.decodeObject(forKey: "latitude") as? Double,
            let longitude = aDecoder.decodeObject(forKey: "longitude") as? Double,
            let measurementsArchived = aDecoder.decodeObject(forKey: "measurements") as? NSData
            else {
                return nil
        }
        if let measurements = NSKeyedUnarchiver.unarchiveObject(with: measurementsArchived as Data) as? [PollutionMeasurement] {
            self.init(city: city,
                      distance: distance,
                      location: location,
                      country: country,
                      measurements: measurements,
                      latitude: latitude,
                      longitude: longitude)
        } else {
            return nil
        }
        
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(city, forKey: "city")
        aCoder.encode(distance, forKey: "distance")
        aCoder.encode(location, forKey: "location")
        aCoder.encode(country, forKey: "country")
        aCoder.encode(latitude, forKey: "latitude")
        aCoder.encode(longitude, forKey: "longitude")
        let measurementsArchived = NSKeyedArchiver.archivedData(withRootObject: measurements)
        aCoder.encode(measurementsArchived, forKey: "measurements")
    }
    
    override public var hashValue: Int {
        return ObjectIdentifier(self).hashValue
    }
    
    static func ==(lhs: PollutionDataEntry, rhs: PollutionDataEntry) -> Bool {
        return ObjectIdentifier(lhs) == ObjectIdentifier(rhs)
    }
    
    func getMostRecentMeasurement() -> PollutionMeasurement? {
        var mostRecentMeasurement: PollutionMeasurement?
        var mostRecentTimeDifference = Date().timeIntervalSince1970
        for measurement in measurements {
            let measurementTimeDifference = measurement.timeDifferenceInSeconds(toDate: Date())
            if  measurementTimeDifference < mostRecentTimeDifference {
                mostRecentTimeDifference = measurementTimeDifference
                mostRecentMeasurement = measurement
            }
        }
        return mostRecentMeasurement
    }
    
    func getMostRecentMeasurement(forType type: String) -> PollutionMeasurement? {
        var mostRecentMeasurement: PollutionMeasurement?
        var mostRecentTimeDifference = Date().timeIntervalSince1970
        for measurement in measurements {
            if measurement.type == type {
                let measurementTimeDifference = measurement.timeDifferenceInSeconds(toDate: Date())
                if  measurementTimeDifference < mostRecentTimeDifference {
                    mostRecentTimeDifference = measurementTimeDifference
                    mostRecentMeasurement = measurement
                }
            }
        }
        return mostRecentMeasurement
    }
}
