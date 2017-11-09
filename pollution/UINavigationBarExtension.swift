//
//  NavigationBarExtension.swift
//  pollution
//
//  Created by Philipp Matthes on 09.11.17.
//  Copyright © 2017 Philipp Matthes. All rights reserved.
//

import Foundation
import UIKit

extension UINavigationBar {
    
    func animate(toBarTintColor color: UIColor, withDuration duration: CFTimeInterval){
        UIView.transition(with: self, duration: duration, options: .transitionCrossDissolve, animations: { () -> Void in
            self.barTintColor = color
            self.barStyle = .black
        }, completion: nil)
    }
    
}
