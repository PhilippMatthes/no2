//
//  TabBarController.swift
//  pollution
//
//  Created by Philipp Matthes on 02.11.17.
//  Copyright © 2017 Philipp Matthes. All rights reserved.
//

import Foundation
import UIKit
import RevealingSplashView
import SwiftRater

class TabBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Initialize a revealing Splash with with the iconImage, the initial size and the background color
        let revealingSplashView = RevealingSplashView(iconImage: UIImage(named: "NoShadowAppIcon")!,iconInitialSize: CGSize(width: 70, height: 70), backgroundColor: UIColor(rgb: 0x373737, alpha: 1.0))
        
        self.tabBar.roundCorners([.topLeft, .topRight], withRadius: Constants.cornerRadius)
        
        revealingSplashView.animationType = .twitter
        
        
        //Adds the revealing splash view as a sub view
        self.view.addSubview(revealingSplashView)
        
        let window = UIApplication.shared.keyWindow
        window?.addSubview(revealingSplashView)
        
        //Starts animation
        revealingSplashView.animate(toBackgroundColor: State.shared.currentColor, withDuration: 2.0)
        revealingSplashView.duration = 2.0
        revealingSplashView.startAnimation(){
            SwiftRater.check()
        }
    }
    
}
