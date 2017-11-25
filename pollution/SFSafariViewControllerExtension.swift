//
//  SFSafariViewControllerExtension.swift
//  pollution
//
//  Created by Philipp Matthes on 25.11.17.
//  Copyright © 2017 Philipp Matthes. All rights reserved.
//

import Foundation
import SafariServices

extension SFSafariViewController {
    
    convenience init(url: URL, tintColor color: UIColor) {
        self.init(url: url)
        if #available(iOS 10.0, *) {
            self.preferredControlTintColor = color
        }
    }
    
}
