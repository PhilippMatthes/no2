//
//  RevealingSplashViewExtension.swift
//  pollution
//
//  Created by Philipp Matthes on 25.11.17.
//  Copyright © 2017 Philipp Matthes. All rights reserved.
//

import Foundation
import RevealingSplashView

extension RevealingSplashView {
    
    func withPresetAnimationType() -> RevealingSplashView {
        animationType = State.shared.splashAnimationType
        return self
    }
    
}
