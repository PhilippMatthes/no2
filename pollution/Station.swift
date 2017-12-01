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
    var entries = [PollutionDataEntry]()
    var city: String?
    var country: String?
    
    var isReady: Bool = true
    
    var intraday: Bool = true
    
    var pushNotificationAfterDate: Date?
    var pushNotificationIntervalInSeconds: Int?
    
    init(name: String, latitude: Double, longitude: Double, entries: [PollutionDataEntry], city: String?, country: String?) {
        self.name = name
        self.latitude = latitude
        self.longitude = longitude
        self.entries = entries
        self.city = city
        self.country = country
        pushNotificationAfterDate = Date()
        pushNotificationIntervalInSeconds = Int.max
    }
    
    init(name: String, latitude: Double, longitude: Double, entries: [PollutionDataEntry], city: String?, country: String?, pushNotificationAfterDate: Date, pushNotificationIntervalInSeconds: Int) {
        self.name = name
        self.latitude = latitude
        self.longitude = longitude
        self.entries = entries
        self.city = city
        self.country = country
        self.pushNotificationAfterDate = pushNotificationAfterDate
        self.pushNotificationIntervalInSeconds = pushNotificationIntervalInSeconds
    }
    
    convenience required init?(coder aDecoder: NSCoder) {
        guard
            let name = aDecoder.decodeObject(forKey: "name") as? String,
            let latitude = aDecoder.decodeObject(forKey: "latitude") as? Double,
            let longitude = aDecoder.decodeObject(forKey: "longitude") as? Double,
            let entriesArchived = aDecoder.decodeObject(forKey: "entries") as? NSData,
            let city = aDecoder.decodeObject(forKey: "city") as? String?,
            let country = aDecoder.decodeObject(forKey: "country") as? String?
            else {
                return nil
            }
        NSKeyedUnarchiver.setClass(PollutionDataEntry.self, forClassName: "PollutionDataEntry")
        if let entries = NSKeyedUnarchiver.unarchiveObject(with: entriesArchived as Data) as? [PollutionDataEntry] {
            if let pushNotificationAfterDate = aDecoder.decodeObject(forKey: "pushNotificationAfterDate") as? Date,
                let pushNotificationIntervalInSeconds = aDecoder.decodeObject(forKey: "pushNotificationIntervalInSeconds") as? Int {
                self.init(name: name,
                          latitude: latitude,
                          longitude: longitude,
                          entries: entries,
                          city: city,
                          country: country,
                          pushNotificationAfterDate: pushNotificationAfterDate,
                          pushNotificationIntervalInSeconds: pushNotificationIntervalInSeconds)
            } else {
               self.init(name: name,
                         latitude: latitude,
                         longitude: longitude,
                         entries: entries,
                         city: city,
                         country: country)
            }
        } else {
            return nil
        }
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(name, forKey: "name")
        aCoder.encode(latitude, forKey: "latitude")
        aCoder.encode(longitude, forKey: "longitude")
        NSKeyedArchiver.setClassName("PollutionDataEntry", for: PollutionDataEntry.self)
        let entriesArchived = NSKeyedArchiver.archivedData(withRootObject: entries)
        aCoder.encode(entriesArchived, forKey: "entries")
        aCoder.encode(city, forKey: "city")
        aCoder.encode(country, forKey: "country")
        aCoder.encode(pushNotificationAfterDate, forKey: "pushNotificationAfterDate")
        aCoder.encode(pushNotificationIntervalInSeconds, forKey: "pushNotificationIntervalInSeconds")
    }
    
    func equals(station: Station) -> Bool {
        return station.name! == self.name!
    }
    
    func getDataIfNecessary(withTimeSpanInDays days: Int, intraday: Bool, completionHandler: @escaping () -> ()) {
        
        self.isReady = false
        
        let mostRecentDate = Date()
        
        self.intraday = intraday
        
        let toDate = Calendar.current.date(byAdding: .day, value: -days, to: mostRecentDate)!
        
        DispatchQueue.global(qos: .default).async {
            guard
                let first = self.entries.first,
                let location = first.location
                else {
                    completionHandler()
                    return
            }
            HiddenDatabaseCaller.makeLocalRequest(forLocation: location,                                                   withLimit: 10000, toDate: toDate, fromDate: mostRecentDate) {
                entries in
                self.entries = entries
                _ = UserDefaults.updateStationList(withStation: self)
                self.isReady = true
                completionHandler()
            }
        }
    }
    
}
