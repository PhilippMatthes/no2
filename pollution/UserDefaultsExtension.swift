//
//  UserDefaultsExtension.swift
//  pollution
//
//  Created by Philipp Matthes on 07.11.17.
//  Copyright © 2017 Philipp Matthes. All rights reserved.
//

import Foundation

enum ListStates {
    case wasUpdated
    case wasAdded
}

extension UserDefaults {
    
    static func loadObject<T>(ofType type: T, withIdentifier identifier: String) -> T? {
        State.shared.defaults.synchronize()
        if let decoded = State.shared.defaults.object(forKey: identifier) as? NSData {
            if let object = NSKeyedUnarchiver.unarchiveObject(with: decoded as Data) as? T {
                return object
            }
        }
        return nil
    }
    
    static func save<T>(object: T, withIdentifier identifier: String) {
        let encodedData = NSKeyedArchiver.archivedData(withRootObject: object)
        State.shared.defaults.set(encodedData, forKey: identifier)
        State.shared.defaults.synchronize()
    }
    
    static func loadAndExtendList<T>(withObject object: T, andIdentifier identifier: String) {
        if var list = UserDefaults.loadObject(ofType: [T](), withIdentifier: identifier) {
            list.append(object)
            UserDefaults.save(object: list, withIdentifier: identifier)
        } else {
            UserDefaults.save(object: [object], withIdentifier: identifier)
        }
    }
    
    static func updateStationList(withStation station: Station) -> ListStates {
        NSKeyedArchiver.setClassName("Station", for: Station.self)
        NSKeyedUnarchiver.setClass(Station.self, forClassName: "Station")
        let stations = UserDefaults.loadObject(ofType: [Station](), withIdentifier: "stations")
        if var stations = stations {
            for stationInList in stations {
                if stationInList.equals(station: station) {
                    let index = stations.index(of: stationInList)!
                    stations[index] = station
                    UserDefaults.save(object: stations, withIdentifier: "stations")
                    return .wasUpdated
                }
            }
        }
        UserDefaults.loadAndExtendList(withObject: station, andIdentifier: "stations")
        return .wasAdded
    }
    
    static func callFromStations(stationWithName stationName: String) -> Station? {
        NSKeyedArchiver.setClassName("Station", for: Station.self)
        NSKeyedUnarchiver.setClass(Station.self, forClassName: "Station")
        let stations = UserDefaults.loadObject(ofType: [Station](), withIdentifier: "stations")
        if let stations = stations {
            for station in stations {
                if station.name! == stationName {
                    return station
                }
            }
        }
        return nil
    }
    
}
