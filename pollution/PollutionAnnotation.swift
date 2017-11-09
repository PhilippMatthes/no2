//
//  PollutionAnnotation.swift
//  pollution
//
//  Created by Philipp Matthes on 26.10.17.
//  Copyright © 2017 Philipp Matthes. All rights reserved.
//

import Foundation

import MapKit
import UIKit

class PollutionAnnotation : NSObject, NSCoding, MKAnnotation {
    private var coord: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 0, longitude: 0)
    private var _title: String = String("")
    private var _subtitle: String = String("")
    
    var entry: PollutionDataEntry?
    
    override init() {
        super.init()
    }
    
    init(coord: CLLocationCoordinate2D, title: String, subtitle: String, entry: PollutionDataEntry) {
        super.init()
        self.coord = coord
        self._title = title
        self._subtitle = subtitle
        self.entry = entry
    }
    
    convenience required init?(coder aDecoder: NSCoder) {
        guard
            let longitude = aDecoder.decodeObject(forKey: "longitude") as? Double,
            let latitude = aDecoder.decodeObject(forKey: "latitude") as? Double,
            let _title = aDecoder.decodeObject(forKey: "_title") as? String,
            let _subtitle = aDecoder.decodeObject(forKey: "_subtitle") as? String
            else {
                return nil
        }
        if let entry = DiskJockey.loadObject(ofType: PollutionDataEntry(), withIdentifier: "entry") {
            let coord = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            self.init(coord: coord,
                      title: _title,
                      subtitle: _subtitle,
                      entry: entry)
        } else {
            return nil
        }
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(coord.latitude, forKey: "latitude")
        aCoder.encode(coord.longitude, forKey: "longitude")
        aCoder.encode(_title, forKey: "_title")
        aCoder.encode(_subtitle, forKey: "_subtitle")
        aCoder.encode(entry, forKey: "entry")
    }
    
    var title: String? {
        get {
            return _title
        }
        set (value) {
            self._title = value!
        }
    }
    
    var subtitle: String? {
        get {
            return _subtitle
        }
        set (value) {
            self._subtitle = value!
        }
    }
    
    var coordinate: CLLocationCoordinate2D {
        get {
            return coord
        }
    }
    
    func setCoordinate(newCoordinate: CLLocationCoordinate2D) {
        self.coord = newCoordinate
    }
}
