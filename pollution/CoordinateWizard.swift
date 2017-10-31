//
//  CoordinateWizard.swift
//  pollution
//
//  Created by Philipp Matthes on 01.11.17.
//  Copyright © 2017 Philipp Matthes. All rights reserved.
//

import Foundation
import MapKit

class CoordinateWizard {
    
    static func fetchCountryAndCity(location: CLLocation, completion: @escaping (String, String) -> ()) {
        CLGeocoder().reverseGeocodeLocation(location) { placemarks, error in
            if let error = error {
                print(error)
            } else if let country = placemarks?.first?.country,
                let city = placemarks?.first?.locality {
                completion(country, city)
            }
        }
    }
    
    
}
