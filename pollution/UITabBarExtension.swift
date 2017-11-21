//
//  TabBarExtension.swift
//  pollution
//
//  Created by Philipp Matthes on 02.11.17.
//  Copyright © 2017 Philipp Matthes. All rights reserved.
//

import Foundation
import UIKit

extension UITabBar {
    func setTintColor(ofUnselectedItemsWithColor unselectedColor: UIColor, andSelectedItemsWithColor selectedColor: UIColor) {
        if let items = items {
            for item in items {
                item.selectedImage = item.image?.alpha(1.0).withRenderingMode(.alwaysOriginal)
                item.image =  item.selectedImage?.alpha(0.5).withRenderingMode(.alwaysOriginal)
                item.setTitleTextAttributes([NSAttributedStringKey.foregroundColor : unselectedColor], for: .normal)
                item.setTitleTextAttributes([NSAttributedStringKey.foregroundColor : selectedColor], for: .selected)
            }
        }
    }
    
    func animate(toSelectedItemTintColor color: UIColor, withDuration duration: CFTimeInterval){
        UIView.animate(withDuration: 1, animations: { () -> Void in
            self.tintColor = color
        }) { (success) -> Void in
            self.tintColor = color
        }
    }
    
    func animate(toBarTintColor color: UIColor, withDuration duration: CFTimeInterval){
        UIView.transition(with: self, duration: duration, options: .transitionCrossDissolve, animations: { () -> Void in
            self.barTintColor = color
            self.barStyle = .black
        }, completion: nil)
    }
}
