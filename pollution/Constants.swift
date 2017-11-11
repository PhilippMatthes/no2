//
//  Constants.swift
//  DragTimer
//
//  Created by Philipp Matthes on 27.09.17.
//  Copyright © 2017 Philipp Matthes. All rights reserved.
//

import Foundation
import UIKit

struct Constants {
    static let cornerRadius = CGFloat(10.0)
    
    static let drawCustomMap = true
    
    static let colorLowStroke = UIColor(rgb: 0xFFFFFF, alpha: 0.5)
    static let colorHighStroke = UIColor(rgb: 0x000000, alpha: 0.0)
    
    static let units = ["no2","co","pm10","pm25","so2","o3"]
    
    static let colors = ["no2"  : UIColor(rgb: 0xF44336, alpha: 1.0),
                         "co"   : UIColor(rgb: 0xE91E63, alpha: 1.0),
                         "pm10" : UIColor(rgb: 0x9C27B0, alpha: 1.0),
                         "pm25" : UIColor(rgb: 0x9C27B0, alpha: 1.0),
                         "so2"  : UIColor(rgb: 0x673AB7, alpha: 1.0),
                         "o3"   : UIColor(rgb: 0x3F51B5, alpha: 1.0)]
    
    ///Source: Umweltbundesamt
    static let maxValues = ["no2"  : 40.0 as Double,
                            "co"   : 10000.0 as Double,
                            "pm10" : 40.0 as Double,
                            "pm25" : 25.0 as Double,
                            "so2"  : 20.0 as Double,
                            "o3"   : 80.0 as Double]
    
    static let timeList = [NSLocalizedString("1 Day", comment: "1 Day"),
                           NSLocalizedString("3 Days", comment: "3 Days"),
                           NSLocalizedString("7 Days", comment: "7 Days"),
                           NSLocalizedString("30 Days", comment: "30 Days")]
    
    static let timeSpaces = [NSLocalizedString("1 Day", comment: "1 Day"): 1,
                             NSLocalizedString("3 Days", comment: "3 Days"): 3,
                             NSLocalizedString("7 Days", comment: "7 Days"): 7,
                             NSLocalizedString("30 Days", comment: "30 Days"): 30]
    
    static let font = UIFont(name: "Futura", size: 22.0)
    
    static let information = ["no2"  : NSLocalizedString("no2info", comment: "Information about no2"),
                              "co"   : NSLocalizedString("coinfo", comment: "Information about co"),
                              "pm10" : NSLocalizedString("pm10info", comment: "Information about pm10"),
                              "pm25" : NSLocalizedString("pm25info", comment: "Information about pm25"),
                              "so2"  : NSLocalizedString("so2info", comment: "Information about so2"),
                              "o3"   : NSLocalizedString("o3info", comment: "Information about o3")]
    
}


