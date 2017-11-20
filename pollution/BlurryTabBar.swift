//
//  BlurryTabBar.swift
//  pollution
//
//  Created by Philipp Matthes on 20.11.17.
//  Copyright © 2017 Philipp Matthes. All rights reserved.
//

import Foundation


import UIKit

class BlurryTabBar: UITabBar {
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
//        let frost = UIVisualEffectView(effect: UIBlurEffect(style: .light))
//        frost.frame = bounds
//        frost.autoresizingMask = .flexibleWidth
//        insertSubview(frost, at: 0)
        
        State.shared.load()
        
        self.isTranslucent = false
        self.clipsToBounds = true
        self.tintColor = UIColor.white
        self.barTintColor = Constants.colors[State.shared.currentType]
        self.backgroundColor = UIColor.clear
    }
}
