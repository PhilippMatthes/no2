//
//  UISearchControllerExtension.swift
//  pollution
//
//  Created by Philipp Matthes on 21.11.17.
//  Copyright © 2017 Philipp Matthes. All rights reserved.
//

import Foundation
import UIKit

enum UISearchControllerStyle {
    case whiteClean
}

extension UISearchController {
    
    func initStyle(_ style: UISearchControllerStyle, withDelegate delegate: UISearchBarDelegate) {
        self.hidesNavigationBarDuringPresentation = false
        self.searchBar.delegate = delegate
        let textFieldInsideSearchBar = self.searchBar.value(forKey: "searchField") as? UITextField
        
        switch style {
            case .whiteClean:
                self.searchBar.barStyle = .default
                self.searchBar.searchBarStyle = .default
                self.searchBar.showsCancelButton = false
                self.searchBar.tintColor = State.shared.currentColor
                self.searchBar.barTintColor = UIColor.white
                textFieldInsideSearchBar?.textColor = UIColor.gray
        }
        
        
    }
    
}
