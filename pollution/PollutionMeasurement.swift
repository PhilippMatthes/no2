//
//  PollutionMeasurement.swift
//  pollution
//
//  Created by Philipp Matthes on 26.10.17.
//  Copyright © 2017 Philipp Matthes. All rights reserved.
//

import Foundation

class PollutionMeasurement: NSObject, NSCoding {
    
    var date: String?
    var type: String?
    var value: Double?
    var unit: String?
    
    init(date: String, type: String, value: Double, unit: String) {
        self.date = date
        self.type = type
        self.value = value
        self.unit = unit
    }
    
    override init() {
        super.init()
    }
    
    convenience required init?(coder aDecoder: NSCoder) {
        guard
            let date = aDecoder.decodeObject(forKey: "date") as? String,
            let type = aDecoder.decodeObject(forKey: "type") as? String,
            let value = aDecoder.decodeObject(forKey: "value") as? Double,
            let unit = aDecoder.decodeObject(forKey: "unit") as? String
            else {
                return nil
        }
        self.init(date: date,
                  type: type,
                  value: value,
                  unit: unit)
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(date, forKey: "date")
        aCoder.encode(type, forKey: "type")
        aCoder.encode(value, forKey: "value")
        aCoder.encode(unit, forKey: "unit")
    }
    
    func timeDifferenceInSeconds(toDate referenceDate: Date) -> Double {
        let dateFormatter = DateFormatter()
        let checkDate = String(self.date!.prefix(10))
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let date = dateFormatter.date(from: checkDate)
        return referenceDate.timeIntervalSince(date!)
    }
    
    func wasUpdatedToday() -> Bool {
        let dateFormatter = DateFormatter()
        let checkDate = String(self.date!.prefix(10))
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let date = dateFormatter.date(from: checkDate)
        return Date().timeIntervalSince(date!) <= 86400
    }
    
    func getConvertedDate() -> Date {
        let dateFormatter = DateFormatter()
        let checkDate = String(self.date!.prefix(10))
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter.date(from: checkDate)!
    }
    
    func getLocalTimeString() -> String {
        let cutOff = String(self.date!.dropFirst(11))
        let time = String(cutOff.prefix(5))

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "H:mm"
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        
        let dt = dateFormatter.date(from: time)
        dateFormatter.timeZone = TimeZone.current
        dateFormatter.dateFormat = "H:mm"
        
        return dateFormatter.string(from: dt!)
    }
}
