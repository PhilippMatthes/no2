//
//  DiskJockey.swift
//  pollution
//
//  Created by Philipp Matthes on 07.11.17.
//  Copyright © 2017 Philipp Matthes. All rights reserved.
//

import Foundation

class DiskJockey {
    
    static func getStations() -> [Station]? {
        if let decoded = UserDefaults.standard.object(forKey: "stations") as? NSData {
            if let array = NSKeyedUnarchiver.unarchiveObject(with: decoded as Data) as? [Station] {
                return array
            }
        }
        return nil
    }
    
    static func setStations(to stations: [Station]) {
        let encodedData = NSKeyedArchiver.archivedData(withRootObject: stations)
        UserDefaults.standard.set(encodedData, forKey: "stations")
    }
    
    static func extendStationsBy(station: Station) {
        if var stations = DiskJockey.getStations() {
            stations.append(station)
            DiskJockey.setStations(to: stations)
        } else {
            DiskJockey.setStations(to: [station])
        }
    }
    
}
