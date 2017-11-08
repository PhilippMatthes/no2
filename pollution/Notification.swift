//
//  Notification.swift
//  pollution
//
//  Created by Philipp Matthes on 08.11.17.
//  Copyright © 2017 Philipp Matthes. All rights reserved.
//

import Foundation

class Notification: NSObject, NSCoding  {
    var stationName: String?
    var date: String?
    
    init(stationName: String, date: String) {
        self.stationName = stationName
        self.date = date
    }
    
    convenience required init?(coder aDecoder: NSCoder) {
        guard
            let stationName = aDecoder.decodeObject(forKey: "stationName") as? String,
            let date = aDecoder.decodeObject(forKey: "date") as? String
            else {
                return nil
        }
        
        self.init(stationName: stationName, date: date)
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(stationName, forKey: "stationName")
        aCoder.encode(date, forKey: "date")
    }
    
    func equals(_ notification: Notification) -> Bool {
        return notification.stationName! == self.stationName! && notification.date! == self.date!
    }
    
    func occursIn(list: [Notification]) -> Bool {
        for notification in list {
            if notification.equals(self) {
                return true
            }
        }
        return false
    }
    
}

