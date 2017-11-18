//
//  CustomCircleRenderer.swift
//  pollution
//
//  Created by Philipp Matthes on 01.11.17.
//  Copyright © 2017 Philipp Matthes. All rights reserved.
//

import Foundation
import MapKit

class CustomCircleRenderer: MKCircleRenderer {
    
    var gradientFillColor: UIColor?
    
    init(withOverlay overlay: MKOverlay, withGradientFillColor gradientFillColor: UIColor) {
        super.init(overlay: overlay)
        self.gradientFillColor = gradientFillColor
    }
    
    override func fillPath(_ path: CGPath, in context: CGContext) {
        let rect: CGRect = path.boundingBox
        context.addPath(path)
        context.clip()
        let gradientLocations: [CGFloat]  = [1.0,1.0,1.0,1.0]
        let gradientColors: [CGColor] = [gradientFillColor!.cgColor,
                                         gradientFillColor!.cgColor,
                                         gradientFillColor!.withAlphaComponent(0.05).cgColor,
                                         gradientFillColor!.withAlphaComponent(0).cgColor]
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        guard let gradient = CGGradient(colorsSpace: colorSpace, colors: gradientColors as CFArray, locations: gradientLocations) else {return}
        
        let gradientCenter = CGPoint(x: rect.midX, y: rect.midY)
        let gradientRadius = min(rect.size.width, rect.size.height) / 2
        context.drawRadialGradient(gradient, startCenter: gradientCenter, startRadius: 0, endCenter: gradientCenter, endRadius: gradientRadius, options: .drawsAfterEndLocation)
    }
}

