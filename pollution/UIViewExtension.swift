//
//  UIViewExtension.swift
//  pollution
//
//  Created by Philipp Matthes on 01.11.17.
//  Copyright © 2017 Philipp Matthes. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
    func animateButtonPress(withBorderColor color: UIColor, width: Double, andDuration duration: Double) {
        let borderWidth:CABasicAnimation = CABasicAnimation(keyPath: "borderWidth")
        borderWidth.fromValue = 0
        borderWidth.toValue = width
        borderWidth.duration = duration
        self.layer.borderWidth = 0.0
        self.layer.borderColor = color.cgColor as CGColor
        self.layer.add(borderWidth, forKey: "Width")
        self.layer.borderWidth = 4.0
    }
    
    func animateButtonRelease(withBorderColor color: UIColor, width: Double, andDuration duration: Double) {
        let borderWidth:CABasicAnimation = CABasicAnimation(keyPath: "borderWidth")
        borderWidth.fromValue = width
        borderWidth.toValue = 0
        borderWidth.duration = duration
        self.layer.borderWidth = 4.0
        self.layer.borderColor = color.cgColor as CGColor
        self.layer.add(borderWidth, forKey: "Width")
        self.layer.borderWidth = 0.0
    }
    
    func animateClick(withBorderColor color: UIColor, width: Double, andDuration duration: Double) {
        let halfDuration = duration/2
        animateButtonPress(withBorderColor: color, width: width, andDuration: halfDuration)
        DispatchQueue.main.asyncAfter(deadline: .now() + halfDuration) {
            self.animateButtonRelease(withBorderColor: color, width: width, andDuration: halfDuration)
        }
    }
    
    func animate(toBackgroundColor color: UIColor, withDuration duration: CFTimeInterval){
        UIView.animate(withDuration: 1, animations: { () -> Void in
            self.layer.backgroundColor = color.cgColor
        }) { (success) -> Void in
            self.layer.backgroundColor = color.cgColor
        }
    }
    
    func roundCorners(_ corners : UIRectCorner, withRadius radius: CGFloat) {
        let rectShape = CAShapeLayer()
        rectShape.bounds = self.frame
        rectShape.position = self.center
        rectShape.path = UIBezierPath(roundedRect: self.bounds,
                                      byRoundingCorners: corners,
                                      cornerRadii: CGSize(width: radius, height: radius)).cgPath
        self.layer.mask = rectShape
    }
}
