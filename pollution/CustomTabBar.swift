//
//  CustomTabBar.swift
//  pollution
//
//  Created by Philipp Matthes on 21.11.17.
//  Copyright © 2017 Philipp Matthes. All rights reserved.
//

import Foundation
import UIKit

class CustomTabBar: UITabBar {
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        State.shared.load()
        
        self.backgroundImage = UIImage(color: UIColor.clear)
        
        self.isTranslucent = true
        self.clipsToBounds = true
        self.tintColor = UIColor.white
        self.barTintColor = UIColor.clear
        self.backgroundColor = State.shared.currentColor.withAlphaComponent(Constants.transparency)
    }
}
