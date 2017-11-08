//
//  DiskJockey.swift
//  pollution
//
//  Created by Philipp Matthes on 07.11.17.
//  Copyright © 2017 Philipp Matthes. All rights reserved.
//

import Foundation

class DiskJockey {
    
    static func loadObject<T>(ofType type: T, withIdentifier identifier: String) -> T? {
        if let decoded = UserDefaults.standard.object(forKey: identifier) as? NSData {
            if let object = NSKeyedUnarchiver.unarchiveObject(with: decoded as Data) as? T {
                return object
            }
        }
        return nil
    }
    
    static func save<T>(object: T, withIdentifier identifier: String) {
        let encodedData = NSKeyedArchiver.archivedData(withRootObject: object)
        UserDefaults.standard.set(encodedData, forKey: identifier)
    }
    
    static func loadAndExtendList<T>(withObject object: T, andIdentifier identifier: String) {
        if var list = DiskJockey.loadObject(ofType: [T](), withIdentifier: identifier) {
            list.append(object)
            DiskJockey.save(object: list, withIdentifier: identifier)
        } else {
            DiskJockey.save(object: [object], withIdentifier: identifier)
        }
    }
    
}
