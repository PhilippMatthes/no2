//
//  ColorCircle.swift
//  pollution
//
//  Created by Philipp Matthes on 26.10.17.
//  Copyright © 2017 Philipp Matthes. All rights reserved.
//

import Foundation
import MapKit

class ColorCircle: MKCircle {
    
    var color: UIColor?
    var _coordinate = CLLocationCoordinate2D()
    var _radius = CLLocationDistance()
    
    override var coordinate: CLLocationCoordinate2D {
        get {
            return _coordinate
        }
        set {
            self._coordinate = newValue
        }
    }
    
    override var radius: CLLocationDistance {
        get {
            return self._radius
        }
        set {
            self._radius = newValue
        }
    }
    
    init(center: CLLocationCoordinate2D, radius: Double, color: UIColor) {
        super.init()
        self.coordinate = center
        self.radius = radius
        self.color = color
    }
    
    
    
}
