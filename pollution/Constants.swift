//
//  Constants.swift
//  DragTimer
//
//  Created by Philipp Matthes on 27.09.17.
//  Copyright © 2017 Philipp Matthes. All rights reserved.
//

import Foundation
import UIKit
import enum RevealingSplashView.SplashAnimationType

struct Constants {
    
    static let transparency = 0.9 as CGFloat
    
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
    
    static let supportedUnits: [String] = ["µg/m³", "ppm"]
    
    ///Source: Umweltbundesamt
    static let maxValues: [String : [String : Double]] = ["µg/m³" : ["no2" : 40.0,
                                                                    "co"   : 10000.0,
                                                                    "pm10" : 40.0,
                                                                    "pm25" : 25.0,
                                                                    "so2"  : 20.0,
                                                                    "o3"   : 80.0],
                                                          "ppm" : ["no2"  : 0.2128,
                                                                   "co"   : 30.0,
                                                                   "pm10" : 10,
                                                                   "pm25" : 7.5,
                                                                   "so2"  : 2.0,
                                                                   "o3"   : 10.0]]
    
    static let timeList = [NSLocalizedString("1 Day", comment: "1 Day"),
                           NSLocalizedString("3 Days", comment: "3 Days"),
                           NSLocalizedString("7 Days", comment: "7 Days"),
                           NSLocalizedString("30 Days", comment: "30 Days")]
    
    static let timeSpaces = [NSLocalizedString("1 Day", comment: "1 Day"): 1,
                             NSLocalizedString("3 Days", comment: "3 Days"): 3,
                             NSLocalizedString("7 Days", comment: "7 Days"): 7,
                             NSLocalizedString("30 Days", comment: "30 Days"): 30]
    
    static let notificationTimes = [NSLocalizedString("instantly", comment: ""),
                                    NSLocalizedString("daily", comment: ""),
                                    NSLocalizedString("weekly", comment: ""),
                                    NSLocalizedString("monthly", comment: ""),
                                    NSLocalizedString("never", comment: "")]
    
    static let notificationTimeIntervalsList = [0,
                                                86400,
                                                604800,
                                                18144000,
                                                Int.max]
    
    static let notificationTimeIntervals = [0           : NSLocalizedString("instantly", comment: ""),
                                            86400       : NSLocalizedString("daily", comment: ""),
                                            604800      : NSLocalizedString("weekly", comment: ""),
                                            18144000    : NSLocalizedString("monthly", comment: ""),
                                            Int.max     : NSLocalizedString("never", comment: "")]
    
    static let font = UIFont(name: "Futura", size: 22.0)
    
    static let information = ["no2"  : NSLocalizedString("no2info", comment: "Information about no2"),
                              "co"   : NSLocalizedString("coinfo", comment: "Information about co"),
                              "pm10" : NSLocalizedString("pm10info", comment: "Information about pm10"),
                              "pm25" : NSLocalizedString("pm25info", comment: "Information about pm25"),
                              "so2"  : NSLocalizedString("so2info", comment: "Information about so2"),
                              "o3"   : NSLocalizedString("o3info", comment: "Information about o3")]
    
    static let stringToAnimationType: [String : SplashAnimationType] = ["popAndZoomOut"     : .popAndZoomOut,
                                                                        "rotateOut"         : .rotateOut,
                                                                        "squeezeAndZoomOut" : .squeezeAndZoomOut,
                                                                        "swingAndZoomOut"   : .swingAndZoomOut,
                                                                        "twitter"           : .twitter,
                                                                        "woobleAndZoomOut"  : .woobleAndZoomOut]
    
    static let animationTypeToString: [SplashAnimationType : String] = [.popAndZoomOut     : "popAndZoomOut",
                                                                        .rotateOut         : "rotateOut",
                                                                        .squeezeAndZoomOut : "squeezeAndZoomOut",
                                                                        .swingAndZoomOut   : "swingAndZoomOut",
                                                                        .twitter           : "twitter",
                                                                        .woobleAndZoomOut  : "woobleAndZoomOut"]
    
    
}


