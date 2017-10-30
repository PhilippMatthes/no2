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
    
    static let timeSpaces = ["1 Day": 0,
                             "3 Days": 2,
                             "1 Week": 6,
                             "1 Month": 29,
                             "1 Year": 355]
    
    static let font = UIFont(name: "Futura", size: 22.0)
    
    static let information = ["no2"  : "(Source: Wikipedia.org) For the public, chronic exposure to NO2 can cause respiratory effects including airway inflammation in healthy people and increased respiratory symptoms in people with asthma. NO2 creates ozone which causes eye irritation and exacerbates respiratory conditions, leading to increased visits to emergency departments and hospital admissions for respiratory issues, especially asthma. The effects of toxicity on health have been examined using questionnaires and inperson interviews in an effort to understand the relationship between NO2 and asthma. The influence of indoor air pollutants on health is important because the majority of people in the world spend more than 80% of their time indoors. The amount of time spent indoors depends upon on several factors including geographical region, job activities, and gender among other variables. Additionally, because home insulation is improving, this can result in greater retention of indoor air pollutants, such as NO2.[28] With respect to geographic region, the prevalence of asthma has ranged from 2 to 20% with no clear indication as to what’s driving the difference. This may be a result of the \"hygiene hypothesis\" or \"western lifestyle\" that captures the notions of homes that are well insulated and with fewer inhabitants. Another study examined the relationship between nitrogen exposure in the home and respiratory symptoms and found a statistically significant odds ratio of 2.23 (95% CI: 1.06, 4.72) among those with a medical diagnosis of asthma and gas stove exposure. A major source of indoor exposure to NO2 is from the use of gas stoves for cooking or heating in homes. According to the 2000 census, over half of US households use gas stoves and indoor exposure levels of NO2 are, on average, at least three times higher in homes with gas stoves compared to electric stoves with the highest levels being in multifamily homes. Exposure to NO2 is especially harmful for children with asthma. Research has shown that children with asthma who live in homes with gas stoves have greater risk of respiratory symptoms such as wheezing, cough and chest tightness. Additionally, gas stove use was associated with reduced lung function in girls with asthma, although this association was not found in boys. Using ventilation when operating gas stoves may reduce the risk of respiratory symptoms in children with asthma. In a cohort study with inner-city minority African American Baltimore children to determine if there was a relationship between NO2 and asthma for children aged 2 to 6 years old, with an existing medical diagnosis of asthma, and one asthma related visit. Families of lower socioeconomic status were more likely to have gas stoves in their homes. The study concluded that that higher levels of NO2 within a home were linked to a greater level of respiratory symptoms among the study population. This further exemplifies that NO2 toxicity is dangerous for children.",
                              
                              "co"   : "(Source: Wikipedia.org) Carbon monoxide (CO) is a colorless, odorless, and tasteless gas that is slightly less dense than air. It is toxic to hemoglobic animals (both invertebrate and vertebrate, including humans) when encountered in concentrations above about 35 ppm, although it is also produced in normal animal metabolism in low quantities, and is thought to have some normal biological functions. In the atmosphere, it is spatially variable and short lived, having a role in the formation of ground-level ozone. Carbon monoxide consists of one carbon atom and one oxygen atom, connected by a triple bond that consists of two covalent bonds as well as one dative covalent bond. It is the simplest oxocarbon and is isoelectronic with the cyanide anion, the nitrosonium cation and molecular nitrogen. In coordination complexes the carbon monoxide ligand is called carbonyl.",
                              
                              "pm10" : "",
                              "pm25" : "",
                              "so2"  : "",
                              "o3"   : ""]
    
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
