//
//  CLLocationExtension.swift
//  pollution
//
//  Created by Philipp Matthes on 01.11.17.
//  Copyright © 2017 Philipp Matthes. All rights reserved.
//

import Foundation
import MapKit

extension CLLocation {
    func fetchCountryAndCity(completion: @escaping (String?, String?) -> ()) {
        print("Fetching country and city")
        CLGeocoder().reverseGeocodeLocation(self) { placemarks, error in
            if let error = error {
                print(error)
                completion(nil, nil)
            } else if let country = placemarks?.first?.country,
                let city = placemarks?.first?.locality {
                completion(country, city)
            }
        }
    }
}
