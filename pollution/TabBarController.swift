//
//  TabBarController.swift
//  pollution
//
//  Created by Philipp Matthes on 02.11.17.
//  Copyright © 2017 Philipp Matthes. All rights reserved.
//

import Foundation
import UIKit

class TabBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        tabBar.clipsToBounds = true
        tabBar.tintColor = UIColor.white
        tabBar.barTintColor = Constants.colors[State.shared.currentType]
        tabBar.backgroundColor = UIColor.clear
    }
    
}
