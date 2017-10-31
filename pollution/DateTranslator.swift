//
//  DateTranslator.swift
//  pollution
//
//  Created by Philipp Matthes on 31.10.17.
//  Copyright © 2017 Philipp Matthes. All rights reserved.
//

import Foundation


class DateTranslator {
    
    static func translateDate(fromDateFormat fromFormat: String, toDateFormat toFormat: String, withDate date: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = fromFormat
        let date = dateFormatter.date(from:date)
        dateFormatter.dateFormat = toFormat
        let dateString = dateFormatter.string(from:date!)
        return dateString
    }
    
}
