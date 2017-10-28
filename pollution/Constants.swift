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
    
    
    static let colorLowStroke = UIColor(rgb: 0xFFFFFF, alpha: 0.5)
    static let colorHighStroke = UIColor(rgb: 0x000000, alpha: 0.0)
    
    static let units = ["no2","co","pm10","pm25","so2","o3"]
    
    static let colors = ["no2"  : UIColor(rgb: 0xF44336, alpha: 1.0),
                         "co"   : UIColor(rgb: 0xE91E63, alpha: 1.0),
                         "pm10" : UIColor(rgb: 0x9C27B0, alpha: 1.0),
                         "pm25" : UIColor(rgb: 0x9C27B0, alpha: 1.0),
                         "so2"  : UIColor(rgb: 0x673AB7, alpha: 1.0),
                         "o3"   : UIColor(rgb: 0x3F51B5, alpha: 1.0)]
    
    //Source: Umweltbundesamt
    static let maxValues = ["no2"  : 40.0 as Double,
                            "co"   : 10000.0 as Double,
                            "pm10" : 40.0 as Double,
                            "pm25" : 25.0 as Double,
                            "so2"  : 20.0 as Double,
                            "o3"   : 80.0 as Double]
    
    static let font = UIFont(name: "Futura", size: 22.0)
    
}

extension UIColor {
    convenience init(rgb: Int, alpha: CGFloat) {
        self.init(
            red: CGFloat((rgb >> 16) & 0xFF)/255,
            green: CGFloat((rgb >> 8) & 0xFF)/255,
            blue: CGFloat(rgb & 0xFF)/255,
            alpha: alpha
        )
    }
    
    func interpolateRGBColorTo(end: UIColor, fraction: CGFloat) -> UIColor? {
        var f = max(0, fraction)
        f = min(1, fraction)
        
        guard let c1 = self.cgColor.components, let c2 = end.cgColor.components else { return nil }
        
        let r: CGFloat = CGFloat(c1[0] + (c2[0] - c1[0]) * f)
        let g: CGFloat = CGFloat(c1[1] + (c2[1] - c1[1]) * f)
        let b: CGFloat = CGFloat(c1[2] + (c2[2] - c1[2]) * f)
        let a: CGFloat = CGFloat(c1[3] + (c2[3] - c1[3]) * f)
        
        return UIColor(red: r, green: g, blue: b, alpha: a)
    }
}
