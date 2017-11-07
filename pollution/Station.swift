//
//  Station.swift
//  pollution
//
//  Created by Philipp Matthes on 07.11.17.
//  Copyright © 2017 Philipp Matthes. All rights reserved.
//

import Foundation
import MapKit

class Station: NSObject, NSCoding  {
    var name: String?
    var latitude: Double?
    var longitude: Double?
    
    init(name: String, latitude: Double, longitude: Double) {
        self.name = name
        self.latitude = latitude
        self.longitude = longitude
    }
    
    convenience required init?(coder aDecoder: NSCoder) {
        guard
            let name = aDecoder.decodeObject(forKey: "name") as? String,
            let latitude = aDecoder.decodeObject(forKey: "latitude") as? Double,
            let longitude = aDecoder.decodeObject(forKey: "longitude") as? Double
        else {
            return nil
        }
        self.init(name: name, latitude: latitude, longitude: longitude)
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(name, forKey: "name")
        aCoder.encode(latitude, forKey: "latitude")
        aCoder.encode(longitude, forKey: "longitude")
    }
    
    func equals(station: Station) -> Bool {
        return station.name! == self.name!
    }
    
}
