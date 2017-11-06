//
//  MeasurementCell.swift
//  Pollution
//
//  Created by Philipp Matthes on 06.10.17.
//  Copyright © 2017 Philipp Matthes. All rights reserved.
//

import Foundation
import CoreLocation
import UIKit
import MapKit

class MeasurementCell: UITableViewCell {
    
    var entry: PollutionDataEntry?
    
    @IBOutlet weak var label: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.isHidden = false
        
    }
    
    func setEntry(entry: PollutionDataEntry) {
        self.entry = entry
        let coordinateLocation = CLLocation(latitude: entry.latitude!,
                                            longitude: entry.longitude!)
        CoordinateWizard.fetchCountryAndCity(location: coordinateLocation) { country, city in
            self.label.text = "\(NSLocalizedString("location", comment: "Location")): \(city) (\(country))"
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    
}

